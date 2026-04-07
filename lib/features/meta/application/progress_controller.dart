import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/progress_repository.dart';
import '../domain/entities/achievement_badge.dart';
import '../domain/entities/app_settings.dart';
import '../domain/entities/daily_mission.dart';
import '../domain/entities/player_profile.dart';
import '../domain/entities/progress_snapshot.dart';
import '../domain/services/progression_engine.dart';

class ProgressController extends ChangeNotifier {
  ProgressController({
    required ProgressRepository repository,
    ProgressionEngine? progressionEngine,
    DateTime Function()? now,
  })  : _repository = repository,
        _progressionEngine = progressionEngine ?? const ProgressionEngine(),
        _now = now ?? DateTime.now;

  final ProgressRepository _repository;
  final ProgressionEngine _progressionEngine;
  final DateTime Function() _now;

  bool _isLoading = false;
  bool _isReady = false;
  ProgressSnapshot _snapshot = ProgressSnapshot.initial();

  bool get isLoading => _isLoading;
  bool get isReady => _isReady;

  PlayerProfile get profile => _snapshot.profile;
  AppSettings get settings => _snapshot.settings;
  List<DailyMission> get dailyMissions => _snapshot.dailyMissions;
  List<AchievementBadge> get achievements => _snapshot.achievements;

  int get unlockedAchievementCount =>
      achievements.where((item) => item.isUnlocked).length;

  int get claimableMissionCount =>
      dailyMissions.where((item) => item.isCompleted && !item.isClaimed).length;

  Future<void> initialize() async {
    if (_isReady || _isLoading) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    final loaded = await _repository.load();
    _snapshot = loaded;

    _ensureDefaults();
    _refreshMissionsIfNeeded();

    _isLoading = false;
    _isReady = true;
    notifyListeners();

    await _repository.save(_snapshot);
  }

  void toggleSound() {
    _snapshot = _snapshot.copyWith(
      settings:
          _snapshot.settings.copyWith(soundEnabled: !_snapshot.settings.soundEnabled),
    );
    _persistAndNotify();
  }

  void toggleHaptic() {
    _snapshot = _snapshot.copyWith(
      settings:
          _snapshot.settings.copyWith(hapticEnabled: !_snapshot.settings.hapticEnabled),
    );
    _persistAndNotify();
  }

  void toggleReducedMotion() {
    _snapshot = _snapshot.copyWith(
      settings:
          _snapshot.settings.copyWith(reducedMotion: !_snapshot.settings.reducedMotion),
    );
    _persistAndNotify();
  }

  bool spendCoins(int amount) {
    if (amount <= 0 || profile.coins < amount) {
      return false;
    }

    _snapshot = _snapshot.copyWith(
      profile: profile.copyWith(coins: profile.coins - amount),
    );
    _persistAndNotify();
    return true;
  }

  void recordLevelStarted(int level) {
    final safeLevel = level < 1 ? 1 : level;
    if (profile.lastPlayedLevel == safeLevel) {
      return;
    }

    _snapshot = _snapshot.copyWith(
      profile: profile.copyWith(lastPlayedLevel: safeLevel),
    );
    _persistAndNotify();
  }

  void recordTriplesCleared(int count) {
    if (count <= 0) {
      return;
    }

    _snapshot = _snapshot.copyWith(
      profile: profile.copyWith(
        totalTriplesCleared: profile.totalTriplesCleared + count,
      ),
      dailyMissions: _incrementMissions(
        missionType: MissionType.clearTriples,
        amount: count,
      ),
    );

    _addXp(count * 8);
    _evaluateAchievementsAndReward();
    _persistAndNotify();
  }

  void recordShuffleUsed(int count) {
    if (count <= 0) {
      return;
    }

    _snapshot = _snapshot.copyWith(
      profile: profile.copyWith(totalShufflesUsed: profile.totalShufflesUsed + count),
      dailyMissions: _incrementMissions(
        missionType: MissionType.useShuffle,
        amount: count,
      ),
    );
    _persistAndNotify();
  }

  void recordMatchFinished({
    required bool won,
    required int level,
    required int score,
    required int starsEarned,
  }) {
    final today = _progressionEngine.dayKey(_now());
    final previousDay = profile.lastPlayedDay;

    final nextStreak = _resolveStreak(previousDay: previousDay, today: today);

    var nextProfile = profile.copyWith(
      totalGames: profile.totalGames + 1,
      totalWins: profile.totalWins + (won ? 1 : 0),
      totalLosses: profile.totalLosses + (won ? 0 : 1),
      bestScore: score > profile.bestScore ? score : profile.bestScore,
      lastPlayedLevel: level,
      highestUnlockedLevel: won
          ? _max(profile.highestUnlockedLevel, level + 1)
          : profile.highestUnlockedLevel,
      dailyStreak: nextStreak,
      lastPlayedDay: today,
      levelStars: profile.levelStars,
    );

    var missions = _snapshot.dailyMissions;
    var coinsEarned = 0;

    if (won) {
      final starMap = Map<String, int>.from(nextProfile.levelStars);
      final existingStars = starMap['$level'] ?? 0;
      starMap['$level'] = _max(existingStars, starsEarned);

      nextProfile = nextProfile.copyWith(levelStars: starMap);

      final reward = _winReward(
        level: level,
        score: score,
        starsEarned: starsEarned,
      );
      coinsEarned += reward;
      missions = _incrementMissions(
        missionType: MissionType.winLevels,
        amount: 1,
        source: missions,
      );
      missions = _incrementMissions(
        missionType: MissionType.earnCoins,
        amount: reward,
        source: missions,
      );
    }

    nextProfile = nextProfile.copyWith(
      coins: nextProfile.coins + coinsEarned,
      totalCoinsEarned: nextProfile.totalCoinsEarned + coinsEarned,
    );

    _snapshot = _snapshot.copyWith(profile: nextProfile, dailyMissions: missions);

    _addXp(won ? 120 : 45);
    _evaluateAchievementsAndReward();
    _persistAndNotify();
  }

  int claimMissionReward(String missionId) {
    final index = _snapshot.dailyMissions.indexWhere((item) => item.id == missionId);
    if (index < 0) {
      return 0;
    }

    final mission = _snapshot.dailyMissions[index];
    if (!mission.isCompleted || mission.isClaimed) {
      return 0;
    }

    final missions = List<DailyMission>.from(_snapshot.dailyMissions);
    missions[index] = mission.copyWith(isClaimed: true);

    final reward = mission.rewardCoins;
    _snapshot = _snapshot.copyWith(
      dailyMissions: missions,
      profile: profile.copyWith(
        coins: profile.coins + reward,
        totalCoinsEarned: profile.totalCoinsEarned + reward,
      ),
    );

    _snapshot = _snapshot.copyWith(
      dailyMissions: _incrementMissions(
        missionType: MissionType.earnCoins,
        amount: reward,
      ),
    );

    _evaluateAchievementsAndReward();
    _persistAndNotify();
    return reward;
  }

  int claimAllMissionRewards() {
    final missions = List<DailyMission>.from(_snapshot.dailyMissions);
    var totalReward = 0;

    for (var i = 0; i < missions.length; i++) {
      final mission = missions[i];
      if (mission.isCompleted && !mission.isClaimed) {
        totalReward += mission.rewardCoins;
        missions[i] = mission.copyWith(isClaimed: true);
      }
    }

    if (totalReward == 0) {
      return 0;
    }

    _snapshot = _snapshot.copyWith(
      dailyMissions: missions,
      profile: profile.copyWith(
        coins: profile.coins + totalReward,
        totalCoinsEarned: profile.totalCoinsEarned + totalReward,
      ),
    );

    _snapshot = _snapshot.copyWith(
      dailyMissions: _incrementMissions(
        missionType: MissionType.earnCoins,
        amount: totalReward,
      ),
    );

    _evaluateAchievementsAndReward();
    _persistAndNotify();
    return totalReward;
  }

  void _ensureDefaults() {
    if (_snapshot.achievements.isEmpty) {
      _snapshot = _snapshot.copyWith(
        achievements: _progressionEngine.createDefaultAchievements(),
      );
    }
  }

  void _refreshMissionsIfNeeded() {
    final today = _progressionEngine.dayKey(_now());
    if (_snapshot.missionsDay == today && _snapshot.dailyMissions.isNotEmpty) {
      return;
    }

    _snapshot = _snapshot.copyWith(
      missionsDay: today,
      dailyMissions: _progressionEngine.createDailyMissions(
        day: _now(),
        playerLevel: profile.playerLevel,
      ),
    );
  }

  List<DailyMission> _incrementMissions({
    required MissionType missionType,
    required int amount,
    List<DailyMission>? source,
  }) {
    final missions = source ?? _snapshot.dailyMissions;

    return missions.map((mission) {
      if (mission.type != missionType || mission.isClaimed || amount <= 0) {
        return mission;
      }

      final nextProgress = _min(mission.goal, mission.progress + amount);
      return mission.copyWith(progress: nextProgress);
    }).toList(growable: false);
  }

  void _addXp(int amount) {
    if (amount <= 0) {
      return;
    }

    var nextXp = profile.xp + amount;
    var nextLevel = profile.playerLevel;

    while (nextXp >= _xpForLevel(nextLevel)) {
      nextXp -= _xpForLevel(nextLevel);
      nextLevel += 1;
    }

    _snapshot = _snapshot.copyWith(
      profile: profile.copyWith(playerLevel: nextLevel, xp: nextXp),
    );
  }

  void _evaluateAchievementsAndReward() {
    var totalReward = 0;
    final nextAchievements = <AchievementBadge>[];

    for (final achievement in _snapshot.achievements) {
      if (achievement.isUnlocked) {
        nextAchievements.add(achievement);
        continue;
      }

      final metricValue = _metricValue(achievement.metric);
      final shouldUnlock = metricValue >= achievement.goal;
      if (shouldUnlock) {
        totalReward += achievement.rewardCoins;
      }

      nextAchievements.add(
        achievement.copyWith(isUnlocked: shouldUnlock || achievement.isUnlocked),
      );
    }

    var nextProfile = profile;
    if (totalReward > 0) {
      nextProfile = nextProfile.copyWith(
        coins: nextProfile.coins + totalReward,
        totalCoinsEarned: nextProfile.totalCoinsEarned + totalReward,
      );

      final missions = _incrementMissions(
        missionType: MissionType.earnCoins,
        amount: totalReward,
      );
      _snapshot = _snapshot.copyWith(dailyMissions: missions);
    }

    _snapshot = _snapshot.copyWith(
      profile: nextProfile,
      achievements: nextAchievements,
    );
  }

  int _metricValue(AchievementMetric metric) {
    switch (metric) {
      case AchievementMetric.wins:
        return profile.totalWins;
      case AchievementMetric.triples:
        return profile.totalTriplesCleared;
      case AchievementMetric.coinsEarned:
        return profile.totalCoinsEarned;
      case AchievementMetric.highestLevel:
        return profile.highestUnlockedLevel;
    }
  }

  int _resolveStreak({required String? previousDay, required String today}) {
    if (previousDay == null) {
      return 1;
    }

    if (previousDay == today) {
      return profile.dailyStreak;
    }

    final current = DateTime.parse(today);
    final previous = DateTime.parse(previousDay);

    final difference = current.difference(previous).inDays;
    if (difference == 1) {
      return profile.dailyStreak + 1;
    }

    return 1;
  }

  int _xpForLevel(int level) {
    return 120 + ((level - 1) * 30);
  }

  int _winReward({
    required int level,
    required int score,
    required int starsEarned,
  }) {
    final levelBonus = 40 + (level * 8);
    final scoreBonus = (score / 30).round();
    final starBonus = starsEarned * 30;
    return levelBonus + scoreBonus + starBonus;
  }

  void _persistAndNotify() {
    notifyListeners();
    unawaited(_repository.save(_snapshot));
  }

  int _max(int a, int b) => a > b ? a : b;

  int _min(int a, int b) => a < b ? a : b;
}
