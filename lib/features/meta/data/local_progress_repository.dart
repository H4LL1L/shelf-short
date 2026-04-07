import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/entities/achievement_badge.dart';
import '../domain/entities/app_settings.dart';
import '../domain/entities/daily_mission.dart';
import '../domain/entities/player_profile.dart';
import '../domain/entities/progress_snapshot.dart';
import '../domain/services/progression_engine.dart';
import 'progress_repository.dart';

class LocalProgressRepository implements ProgressRepository {
  LocalProgressRepository({ProgressionEngine? progressionEngine})
      : _progressionEngine = progressionEngine ?? const ProgressionEngine();

  final ProgressionEngine _progressionEngine;

  static const String _profileKey = 'meta_profile_json';
  static const String _settingsKey = 'meta_settings_json';
  static const String _missionsKey = 'meta_missions_json';
  static const String _missionsDayKey = 'meta_missions_day';
  static const String _achievementsKey = 'meta_achievements_json';

  @override
  Future<ProgressSnapshot> load() async {
    final prefs = await SharedPreferences.getInstance();

    final profile = _readProfile(prefs.getString(_profileKey));
    final settings = _readSettings(prefs.getString(_settingsKey));
    final missions = _readMissions(prefs.getString(_missionsKey));
    final missionsDay = prefs.getString(_missionsDayKey);
    final achievements = _readAchievements(prefs.getString(_achievementsKey));

    final safeAchievements = achievements.isEmpty
        ? _progressionEngine.createDefaultAchievements()
        : achievements;

    return ProgressSnapshot(
      profile: profile,
      settings: settings,
      dailyMissions: missions,
      missionsDay: missionsDay,
      achievements: safeAchievements,
    );
  }

  @override
  Future<void> save(ProgressSnapshot snapshot) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_profileKey, jsonEncode(snapshot.profile.toJson()));
    await prefs.setString(_settingsKey, jsonEncode(snapshot.settings.toJson()));

    final missionsJson =
        snapshot.dailyMissions.map((item) => item.toJson()).toList();
    await prefs.setString(_missionsKey, jsonEncode(missionsJson));

    if (snapshot.missionsDay != null) {
      await prefs.setString(_missionsDayKey, snapshot.missionsDay!);
    }

    final achievementsJson =
        snapshot.achievements.map((item) => item.toJson()).toList();
    await prefs.setString(_achievementsKey, jsonEncode(achievementsJson));
  }

  PlayerProfile _readProfile(String? raw) {
    if (raw == null || raw.isEmpty) {
      return PlayerProfile.initial();
    }

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return PlayerProfile.fromJson(map);
    } catch (_) {
      return PlayerProfile.initial();
    }
  }

  AppSettings _readSettings(String? raw) {
    if (raw == null || raw.isEmpty) {
      return AppSettings.initial();
    }

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return AppSettings.fromJson(map);
    } catch (_) {
      return AppSettings.initial();
    }
  }

  List<DailyMission> _readMissions(String? raw) {
    if (raw == null || raw.isEmpty) {
      return const <DailyMission>[];
    }

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((item) => DailyMission.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const <DailyMission>[];
    }
  }

  List<AchievementBadge> _readAchievements(String? raw) {
    if (raw == null || raw.isEmpty) {
      return const <AchievementBadge>[];
    }

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((item) =>
              AchievementBadge.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const <AchievementBadge>[];
    }
  }
}
