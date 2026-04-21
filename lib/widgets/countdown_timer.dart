import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants.dart';

/// Widget de cuenta regresiva que muestra el tiempo en formato MM:SS.
/// Cambia a rojo cuando quedan menos de 30 segundos y pulsa cuando
/// quedan menos de 10 segundos.
class CountdownTimer extends StatefulWidget {
  final int totalSeconds;
  final VoidCallback? onFinished;
  final TextStyle? textStyle;

  const CountdownTimer({
    super.key,
    required this.totalSeconds,
    this.onFinished,
    this.textStyle,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.totalSeconds;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds <= 0) {
        _timer?.cancel();
        return;
      }
      setState(() {
        _remainingSeconds--;
      });
      if (_remainingSeconds <= 0) {
        _timer?.cancel();
        widget.onFinished?.call();
      }
    });
  }

  /// Formatea los segundos restantes a MM:SS
  String get _formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  /// Color del texto según el tiempo restante
  Color get _timerColor {
    if (_remainingSeconds <= 30) return AppColors.red;
    return AppColors.white;
  }

  /// Determina si se debe aplicar la animación de pulso
  bool get _shouldPulse => _remainingSeconds <= 10 && _remainingSeconds > 0;

  @override
  Widget build(BuildContext context) {
    final baseStyle = widget.textStyle ??
        GoogleFonts.poppins(
          fontSize: 48,
          fontWeight: FontWeight.w700,
        );

    final timerText = Text(
      _formattedTime,
      style: baseStyle.copyWith(color: _timerColor),
    );

    // Animación de pulso cuando quedan menos de 10 segundos
    if (_shouldPulse) {
      return timerText
          .animate(
            onPlay: (controller) => controller.repeat(reverse: true),
          )
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.1, 1.1),
            duration: 500.ms,
          );
    }

    return timerText;
  }
}
