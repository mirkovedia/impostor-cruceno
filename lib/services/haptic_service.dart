import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter/foundation.dart';

enum HapticType {
  light,
  medium,
  heavy,
  success,
  error,
}

class HapticService {
  bool enabled = true;
  bool _hasVibrator = false;

  Future<void> init() async {
    try {
      _hasVibrator = await Vibration.hasVibrator();
    } catch (e) {
      debugPrint('[HapticService] Error verificando vibrador: $e');
      _hasVibrator = false;
    }
  }

  Future<void> trigger(HapticType type) async {
    if (!enabled) return;
    try {
      switch (type) {
        case HapticType.light:
          await HapticFeedback.lightImpact();
        case HapticType.medium:
          await HapticFeedback.mediumImpact();
        case HapticType.heavy:
          await HapticFeedback.heavyImpact();
        case HapticType.success:
          if (_hasVibrator) {
            await Vibration.vibrate(duration: 100, amplitude: 128);
          } else {
            await HapticFeedback.mediumImpact();
          }
        case HapticType.error:
          if (_hasVibrator) {
            await Vibration.vibrate(pattern: [0, 80, 60, 80], intensities: [0, 200, 0, 200]);
          } else {
            await HapticFeedback.heavyImpact();
          }
      }
    } catch (e) {
      debugPrint('[HapticService] Error en vibración: $e');
    }
  }
}
