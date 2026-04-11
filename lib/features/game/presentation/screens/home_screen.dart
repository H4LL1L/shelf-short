import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../application/game_hub_controller.dart';
import '../widgets/decorative_background.dart';
import 'game_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.hub});

  final GameHubController hub;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: hub,
      builder: (context, _) {
        if (!hub.isReady) {
          return const Scaffold(
            body: DecorativeBackground(
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final profile = hub.progressController.profile;
        final missions = hub.progressController.dailyMissions;
        final achievements = hub.progressController.achievements;
        final claimable = hub.progressController.claimableMissionCount;

        return Scaffold(
          body: DecorativeBackground(
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton.filledTonal(
                              onPressed: () => _showSettingsSheet(context),
                              icon: const Icon(Icons.tune_rounded),
                              tooltip: 'Settings',
                            ),
                          ],
                        ),
                        Text(
                          'Shelf Rush',
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.headlineLarge?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary,
                                  ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tap smart. Build combos. Grow your store legend.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.textMuted,
                              ),
                        ),
                        const SizedBox(height: 14),
                        _ProfilePanel(
                          coins: profile.coins,
                          totalStars: profile.totalStars,
                          playerLevel: profile.playerLevel,
                          dailyStreak: profile.dailyStreak,
                          highestLevel: profile.highestUnlockedLevel,
                          bestScore: profile.bestScore,
                          unlockedAchievements:
                              hub.progressController.unlockedAchievementCount,
                          claimableMissions: claimable,
                        ),
                        const SizedBox(height: 12),
                        _LevelMapCard(
                          highestUnlockedLevel: profile.highestUnlockedLevel,
                          lastPlayedLevel: profile.lastPlayedLevel,
                          levelStars: profile.levelStars,
                          onLevelSelected: (level) => _startFreshRun(
                            context,
                            level: level,
                            askIfReplacing: hub.hasRestorableRun,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (hub.hasRestorableRun)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: ElevatedButton.icon(
                              onPressed: () => _resumeRun(context),
                              icon: const Icon(Icons.play_circle_fill_rounded),
                              label: const Text('Resume Active Run'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                              ),
                            ),
                          ),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _startFreshRun(
                                  context,
                                  level: 1,
                                  askIfReplacing: hub.hasRestorableRun,
                                ),
                                child: const Text('Start New Run'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _startFreshRun(
                                  context,
                                  level: profile.highestUnlockedLevel,
                                  askIfReplacing: hub.hasRestorableRun,
                                ),
                                child: Text(
                                  'Jump To L${profile.highestUnlockedLevel}',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _RuleCard(
                          lines: const [
                            '1. Drag top product from one shelf to another.',
                            '2. Drop only into empty shelf slots or same-top product.',
                            '3. A shelf with 3 or 4 same products closes and clears.',
                            '4. Clear the level before the timer expires.',
                            '5. If no valid move remains, the run is lost.',
                          ],
                        ),
                        const SizedBox(height: 12),
                        _SectionHeader(
                          title: 'Daily Missions',
                          trailing: 'Claimable: $claimable',
                        ),
                        if (claimable > 0)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () {
                                final reward = hub.claimAllMissionRewards();
                                if (reward > 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'All missions claimed: +$reward coins.',
                                      ),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.task_alt_rounded),
                              label: const Text('Claim All'),
                            ),
                          ),
                        const SizedBox(height: 8),
                        for (final mission in missions)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _MissionCard(
                              title: mission.title,
                              description: mission.description,
                              progress: mission.progress,
                              goal: mission.goal,
                              reward: mission.rewardCoins,
                              claimed: mission.isClaimed,
                              onClaim: mission.isCompleted && !mission.isClaimed
                                  ? () {
                                      final reward =
                                          hub.claimMissionReward(mission.id);
                                      if (reward > 0) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              '+$reward coins mission reward collected.',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  : null,
                            ),
                          ),
                        const SizedBox(height: 6),
                        _SectionHeader(
                          title: 'Achievements',
                          trailing:
                              'Unlocked: ${hub.progressController.unlockedAchievementCount}/${achievements.length}',
                        ),
                        const SizedBox(height: 8),
                        for (final achievement in achievements.take(4))
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _AchievementCard(
                              title: achievement.title,
                              description: achievement.description,
                              reward: achievement.rewardCoins,
                              unlocked: achievement.isUnlocked,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _startFreshRun(
    BuildContext context, {
    required int level,
    required bool askIfReplacing,
  }) async {
    if (askIfReplacing) {
      final approved = await _confirmReplaceRun(context);
      if (!approved || !context.mounted) {
        return;
      }
    }

    hub.startLevel(level: level);
    _openGameScreen(context);
  }

  void _resumeRun(BuildContext context) {
    final resumed = hub.resumeActiveRun();
    if (!resumed) {
      return;
    }
    _openGameScreen(context);
  }

  void _openGameScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GameScreen(hub: hub),
      ),
    );
  }

  Future<bool> _confirmReplaceRun(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Replace Active Run?'),
          content: const Text(
            'Starting a new run will discard your paused shelf progress.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Start New'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<void> _showSettingsSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.panel,
      builder: (context) {
        return AnimatedBuilder(
          animation: hub,
          builder: (context, _) {
            final settings = hub.progressController.settings;
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    value: settings.soundEnabled,
                    onChanged: (_) => hub.toggleSound(),
                    title: const Text('Sound Effects'),
                  ),
                  SwitchListTile(
                    value: settings.hapticEnabled,
                    onChanged: (_) => hub.toggleHaptic(),
                    title: const Text('Haptic Feedback'),
                  ),
                  SwitchListTile(
                    value: settings.reducedMotion,
                    onChanged: (_) => hub.toggleReducedMotion(),
                    title: const Text('Reduced Motion'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _RuleCard extends StatelessWidget {
  const _RuleCard({required this.lines});

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.panel.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.panelStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How To Play',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 10),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                line,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
        ],
      ),
    );
  }
}

class _ProfilePanel extends StatelessWidget {
  const _ProfilePanel({
    required this.coins,
    required this.totalStars,
    required this.playerLevel,
    required this.dailyStreak,
    required this.highestLevel,
    required this.bestScore,
    required this.unlockedAchievements,
    required this.claimableMissions,
  });

  final int coins;
  final int totalStars;
  final int playerLevel;
  final int dailyStreak;
  final int highestLevel;
  final int bestScore;
  final int unlockedAchievements;
  final int claimableMissions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.panel.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.panelStrong),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _InfoPill(icon: Icons.monetization_on, label: 'Coins', value: '$coins'),
              const SizedBox(width: 8),
              _InfoPill(
                icon: Icons.star_rounded,
                label: 'Total Stars',
                value: '$totalStars',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _InfoPill(icon: Icons.auto_awesome, label: 'Player Lv', value: '$playerLevel'),
              const SizedBox(width: 8),
              _InfoPill(icon: Icons.local_fire_department, label: 'Streak', value: '$dailyStreak'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _InfoPill(icon: Icons.emoji_events, label: 'Best Score', value: '$bestScore'),
              const SizedBox(width: 8),
              _InfoPill(icon: Icons.stars_rounded, label: 'Unlocked Lvl', value: '$highestLevel'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _InfoPill(
                icon: Icons.workspace_premium_rounded,
                label: 'Badges',
                value: '$unlockedAchievements',
              ),
              const SizedBox(width: 8),
              _InfoPill(
                icon: Icons.assignment_turned_in_rounded,
                label: 'Claimable',
                value: '$claimableMissions',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LevelMapCard extends StatelessWidget {
  const _LevelMapCard({
    required this.highestUnlockedLevel,
    required this.lastPlayedLevel,
    required this.levelStars,
    required this.onLevelSelected,
  });

  final int highestUnlockedLevel;
  final int lastPlayedLevel;
  final Map<String, int> levelStars;
  final ValueChanged<int> onLevelSelected;

  @override
  Widget build(BuildContext context) {
    var previewCount = highestUnlockedLevel + 8;
    if (previewCount < 12) {
      previewCount = 12;
    }
    if (previewCount > 30) {
      previewCount = 30;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.panel.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.panelStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Level Map',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap an unlocked level to start from there.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 2),
          Text(
            'The highlighted tile is your last played level.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List<Widget>.generate(previewCount, (index) {
              final level = index + 1;
              final unlocked = level <= highestUnlockedLevel;
              final isLastPlayed = unlocked && level == lastPlayedLevel;
              final stars = levelStars['$level'] ?? 0;

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: unlocked ? () => onLevelSelected(level) : null,
                  child: Ink(
                      width: 76,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: isLastPlayed
                            ? AppColors.accent.withValues(alpha: 0.14)
                            : unlocked
                                ? AppColors.panelStrong.withValues(alpha: 0.55)
                                : AppColors.panelStrong.withValues(alpha: 0.3),
                        border: Border.all(
                          color: isLastPlayed
                              ? AppColors.accent.withValues(alpha: 0.8)
                              : unlocked
                                  ? AppColors.primary.withValues(alpha: 0.18)
                                  : AppColors.textMuted.withValues(alpha: 0.2),
                        ),
                        boxShadow: isLastPlayed
                            ? [
                                BoxShadow(
                                  color: AppColors.accent.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                        gradient: isLastPlayed
                            ? LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppColors.accent.withValues(alpha: 0.2),
                                  AppColors.accent.withValues(alpha: 0.05),
                                ],
                              )
                            : null,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'L$level',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      fontSize: 12,
                                      fontWeight:
                                          isLastPlayed ? FontWeight.w800 : null,
                                      color: unlocked
                                          ? AppColors.textMain
                                          : AppColors.textMuted,
                                    ),
                              ),
                              if (!unlocked) ...[
                                const SizedBox(width: 2),
                                const Icon(
                                  Icons.lock_outline_rounded,
                                  size: 10,
                                  color: AppColors.textMuted,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List<Widget>.generate(3, (i) {
                              return Icon(
                                i < stars && unlocked
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                size: 13,
                                color: i < stars && unlocked
                                    ? AppColors.warning
                                    : AppColors.textMuted,
                              );
                            }),
                          ),
                        ],
                      ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.panelStrong.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 17, color: AppColors.primary),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.trailing});

  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        Text(
          trailing,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({
    required this.title,
    required this.description,
    required this.progress,
    required this.goal,
    required this.reward,
    required this.claimed,
    required this.onClaim,
  });

  final String title;
  final String description;
  final int progress;
  final int goal;
  final int reward;
  final bool claimed;
  final VoidCallback? onClaim;

  @override
  Widget build(BuildContext context) {
    final ratio = goal == 0 ? 0.0 : (progress / goal).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.panel.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.panelStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Text(
                '+$reward',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(description, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            borderRadius: BorderRadius.circular(12),
            backgroundColor: AppColors.panelStrong,
            color: AppColors.accent,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '$progress / $goal',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const Spacer(),
              if (claimed)
                const Text('Claimed')
              else
                TextButton(
                  onPressed: onClaim,
                  child: const Text('Claim'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({
    required this.title,
    required this.description,
    required this.reward,
    required this.unlocked,
  });

  final String title;
  final String description;
  final int reward;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: unlocked
            ? AppColors.panelStrong.withValues(alpha: 0.5)
            : AppColors.panel.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: unlocked ? AppColors.success : AppColors.panelStrong,
        ),
      ),
      child: Row(
        children: [
          Icon(
            unlocked ? Icons.workspace_premium_rounded : Icons.lock_outline,
            color: unlocked ? AppColors.success : AppColors.textMuted,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '+$reward',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                ),
          ),
        ],
      ),
    );
  }
}
