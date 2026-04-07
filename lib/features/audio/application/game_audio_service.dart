import '../domain/entities/sound_cue.dart';

abstract class GameAudioService {
  Future<void> initialize();

  void setEnabled(bool enabled);

  Future<void> play(SoundCue cue);
}

class NoopGameAudioService implements GameAudioService {
  const NoopGameAudioService();

  @override
  Future<void> initialize() async {}

  @override
  Future<void> play(SoundCue cue) async {}

  @override
  void setEnabled(bool enabled) {}
}
