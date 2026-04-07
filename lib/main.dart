import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/audio/data/mixer_audio_service.dart';
import 'features/game/application/game_controller.dart';
import 'features/game/application/game_hub_controller.dart';
import 'features/game/data/local_run_session_repository.dart';
import 'features/game/presentation/screens/home_screen.dart';
import 'features/meta/application/progress_controller.dart';
import 'features/meta/data/local_progress_repository.dart';
import 'features/telemetry/data/local_telemetry_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final hub = GameHubController(
    gameController: GameController(),
    progressController: ProgressController(
      repository: LocalProgressRepository(),
    ),
    runSessionRepository: LocalRunSessionRepository(),
    audioService: MixerAudioService(),
    telemetryService: LocalTelemetryService(),
  );
  await hub.initialize();

  runApp(ShelfRushApp(hub: hub));
}

class ShelfRushApp extends StatelessWidget {
  const ShelfRushApp({super.key, required this.hub});

  final GameHubController hub;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shelf Rush',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: HomeScreen(hub: hub),
    );
  }
}
