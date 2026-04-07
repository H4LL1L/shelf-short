import 'achievement_badge.dart';
import 'app_settings.dart';
import 'daily_mission.dart';
import 'player_profile.dart';

class ProgressSnapshot {
  const ProgressSnapshot({
    required this.profile,
    required this.settings,
    required this.dailyMissions,
    required this.missionsDay,
    required this.achievements,
  });

  factory ProgressSnapshot.initial() {
    return ProgressSnapshot(
      profile: PlayerProfile.initial(),
      settings: AppSettings.initial(),
      dailyMissions: const <DailyMission>[],
      missionsDay: null,
      achievements: const <AchievementBadge>[],
    );
  }

  final PlayerProfile profile;
  final AppSettings settings;
  final List<DailyMission> dailyMissions;
  final String? missionsDay;
  final List<AchievementBadge> achievements;

  ProgressSnapshot copyWith({
    PlayerProfile? profile,
    AppSettings? settings,
    List<DailyMission>? dailyMissions,
    String? missionsDay,
    List<AchievementBadge>? achievements,
  }) {
    return ProgressSnapshot(
      profile: profile ?? this.profile,
      settings: settings ?? this.settings,
      dailyMissions: dailyMissions ?? this.dailyMissions,
      missionsDay: missionsDay ?? this.missionsDay,
      achievements: achievements ?? this.achievements,
    );
  }
}
