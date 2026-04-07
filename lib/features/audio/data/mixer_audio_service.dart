import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

import '../application/game_audio_service.dart';
import '../domain/entities/sound_cue.dart';

class MixerAudioService implements GameAudioService {
  MixerAudioService({double masterVolume = 0.75}) : _masterVolume = masterVolume;

  bool _isReady = false;
  bool _enabled = true;
  final double _masterVolume;

  final Map<AudioChannel, double> _channelVolumes = <AudioChannel, double>{
    AudioChannel.ui: 0.8,
    AudioChannel.gameplay: 0.9,
    AudioChannel.meta: 0.7,
  };

  @override
  Future<void> initialize() async {
    if (_isReady) {
      return;
    }

    _isReady = true;
  }

  @override
  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  @override
  Future<void> play(SoundCue cue) async {
    if (!_enabled) {
      return;
    }

    final config = _cueConfig[cue];
    if (config == null) {
      return;
    }

    final volume =
        (_channelVolumes[config.channel] ?? 1.0) * _masterVolume * config.gain;

    try {
      final player = AudioPlayer();
      await player.setVolume(volume.clamp(0.0, 1.0));
      await player.setReleaseMode(ReleaseMode.release);
      await player.play(AssetSource(config.assetPath));
      unawaited(player.onPlayerComplete.first.then((_) => player.dispose()));
    } catch (_) {
      await SystemSound.play(SystemSoundType.click);
    }
  }
}

class _CueConfig {
  const _CueConfig({
    required this.assetPath,
    required this.channel,
    this.gain = 1.0,
  });

  final String assetPath;
  final AudioChannel channel;
  final double gain;
}

const Map<SoundCue, _CueConfig> _cueConfig = <SoundCue, _CueConfig>{
  SoundCue.levelStart: _CueConfig(
    assetPath: 'audio/ui_click.wav',
    channel: AudioChannel.ui,
    gain: 0.9,
  ),
  SoundCue.tileTap: _CueConfig(
    assetPath: 'audio/ui_click.wav',
    channel: AudioChannel.ui,
    gain: 0.8,
  ),
  SoundCue.match: _CueConfig(
    assetPath: 'audio/match.wav',
    channel: AudioChannel.gameplay,
  ),
  SoundCue.combo: _CueConfig(
    assetPath: 'audio/combo.wav',
    channel: AudioChannel.gameplay,
    gain: 1.1,
  ),
  SoundCue.shuffle: _CueConfig(
    assetPath: 'audio/shuffle.wav',
    channel: AudioChannel.gameplay,
  ),
  SoundCue.undo: _CueConfig(
    assetPath: 'audio/ui_click.wav',
    channel: AudioChannel.ui,
    gain: 0.7,
  ),
  SoundCue.pause: _CueConfig(
    assetPath: 'audio/ui_click.wav',
    channel: AudioChannel.ui,
    gain: 0.7,
  ),
  SoundCue.resume: _CueConfig(
    assetPath: 'audio/ui_click.wav',
    channel: AudioChannel.ui,
    gain: 0.7,
  ),
  SoundCue.win: _CueConfig(
    assetPath: 'audio/win.wav',
    channel: AudioChannel.meta,
    gain: 1.2,
  ),
  SoundCue.lose: _CueConfig(
    assetPath: 'audio/lose.wav',
    channel: AudioChannel.meta,
    gain: 1.0,
  ),
  SoundCue.missionClaim: _CueConfig(
    assetPath: 'audio/mission.wav',
    channel: AudioChannel.meta,
  ),
  SoundCue.boosterPurchase: _CueConfig(
    assetPath: 'audio/ui_click.wav',
    channel: AudioChannel.meta,
    gain: 0.9,
  ),
};
