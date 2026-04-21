import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

enum GameSound {
  reveal,
  tick,
  timerEnd,
  vote,
  victory,
  defeat,
  countdown,
}

class AudioService {
  final Map<GameSound, AudioPlayer> _players = {};
  bool enabled = true;

  static const _soundFiles = {
    GameSound.reveal: 'sounds/reveal.wav',
    GameSound.tick: 'sounds/tick.wav',
    GameSound.timerEnd: 'sounds/timer_end.wav',
    GameSound.vote: 'sounds/vote.wav',
    GameSound.victory: 'sounds/victory.wav',
    GameSound.defeat: 'sounds/defeat.wav',
    GameSound.countdown: 'sounds/countdown.wav',
  };

  Future<void> preload() async {
    for (final entry in _soundFiles.entries) {
      try {
        final player = AudioPlayer();
        await player.setSource(AssetSource(entry.value));
        await player.setVolume(0.5);
        _players[entry.key] = player;
      } catch (e) {
        debugPrint('[AudioService] Error precargando ${entry.key}: $e');
      }
    }
  }

  Future<void> play(GameSound sound) async {
    if (!enabled) return;
    try {
      final player = _players[sound];
      if (player != null) {
        await player.stop();
        await player.seek(Duration.zero);
        await player.resume();
      } else {
        final newPlayer = AudioPlayer();
        final file = _soundFiles[sound];
        if (file != null) {
          await newPlayer.play(AssetSource(file));
          _players[sound] = newPlayer;
        }
      }
    } catch (e) {
      debugPrint('[AudioService] Error reproduciendo $sound: $e');
    }
  }

  void dispose() {
    for (final player in _players.values) {
      player.dispose();
    }
    _players.clear();
  }
}
