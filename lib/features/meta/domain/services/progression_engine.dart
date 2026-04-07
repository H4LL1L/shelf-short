import 'dart:math';

import '../entities/achievement_badge.dart';
import '../entities/daily_mission.dart';

class ProgressionEngine {
  const ProgressionEngine();

  List<DailyMission> createDailyMissions({
    required DateTime day,
    required int playerLevel,
  }) {
    final templates = _missionTemplates;
    final seed = (day.year * 10000) + (day.month * 100) + day.day;
    final random = Random(seed);
    final pool = List<_MissionTemplate>.from(templates)..shuffle(random);

    final scale = max(1, 1 + ((playerLevel - 1) ~/ 4));

    return List<DailyMission>.generate(3, (index) {
      final template = pool[index % pool.length];
      return DailyMission(
        id: '${_dayKey(day)}_${template.type.name}_$index',
        title: template.title,
        description: template.description,
        goal: template.baseGoal * scale,
        progress: 0,
        rewardCoins: template.baseReward + ((scale - 1) * 20),
        type: template.type,
        isClaimed: false,
      );
    });
  }

  List<AchievementBadge> createDefaultAchievements() {
    return const [
      AchievementBadge(
        id: 'first_win',
        title: 'First Victory',
        description: 'Win your first level.',
        metric: AchievementMetric.wins,
        goal: 1,
        rewardCoins: 80,
        isUnlocked: false,
      ),
      AchievementBadge(
        id: 'wins_10',
        title: 'Winning Habit',
        description: 'Win 10 levels.',
        metric: AchievementMetric.wins,
        goal: 10,
        rewardCoins: 220,
        isUnlocked: false,
      ),
      AchievementBadge(
        id: 'triples_120',
        title: 'Shelf Alchemist',
        description: 'Clear 120 triples.',
        metric: AchievementMetric.triples,
        goal: 120,
        rewardCoins: 320,
        isUnlocked: false,
      ),
      AchievementBadge(
        id: 'coins_3000',
        title: 'Store Tycoon',
        description: 'Earn 3000 coins in total.',
        metric: AchievementMetric.coinsEarned,
        goal: 3000,
        rewardCoins: 400,
        isUnlocked: false,
      ),
      AchievementBadge(
        id: 'level_12',
        title: 'Aisle Veteran',
        description: 'Reach level 12.',
        metric: AchievementMetric.highestLevel,
        goal: 12,
        rewardCoins: 500,
        isUnlocked: false,
      ),
    ];
  }

  String dayKey(DateTime date) => _dayKey(date);

  String _dayKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

class _MissionTemplate {
  const _MissionTemplate({
    required this.type,
    required this.title,
    required this.description,
    required this.baseGoal,
    required this.baseReward,
  });

  final MissionType type;
  final String title;
  final String description;
  final int baseGoal;
  final int baseReward;
}

const List<_MissionTemplate> _missionTemplates = [
  _MissionTemplate(
    type: MissionType.winLevels,
    title: 'Win Streak',
    description: 'Complete levels successfully.',
    baseGoal: 2,
    baseReward: 100,
  ),
  _MissionTemplate(
    type: MissionType.clearTriples,
    title: 'Combo Crafter',
    description: 'Clear triple matches.',
    baseGoal: 12,
    baseReward: 120,
  ),
  _MissionTemplate(
    type: MissionType.useShuffle,
    title: 'Shelf Reorganizer',
    description: 'Use shuffle tactically.',
    baseGoal: 2,
    baseReward: 90,
  ),
  _MissionTemplate(
    type: MissionType.earnCoins,
    title: 'Cash Collector',
    description: 'Earn coins from gameplay.',
    baseGoal: 250,
    baseReward: 110,
  ),
  _MissionTemplate(
    type: MissionType.clearTriples,
    title: 'Precision Picker',
    description: 'Clear many triples in one day.',
    baseGoal: 18,
    baseReward: 150,
  ),
];
