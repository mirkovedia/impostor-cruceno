import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants.dart';
import '../core/app_routes.dart';
import '../models/game_state.dart';
import '../providers/game_provider.dart';
import '../services/audio_service.dart';
import '../services/haptic_service.dart';
import '../widgets/reveal_card.dart';

/// Pantalla de revelacion de roles con cuenta regresiva dramatica.
class RevealScreen extends StatefulWidget {
  const RevealScreen({super.key});

  @override
  State<RevealScreen> createState() => _RevealScreenState();
}

class _RevealScreenState extends State<RevealScreen> {
  bool _isRevealed = false;
  bool _isCountingDown = false;
  int _countdown = AppDefaults.revealCountdown;
  Timer? _countdownTimer;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _onCardTap() {
    if (_isRevealed || _isCountingDown) return;
    final provider = context.read<GameProvider>();
    provider.revealCurrentPlayer();
    provider.playSound(GameSound.reveal);
    provider.triggerHaptic(HapticType.medium);
    setState(() => _isRevealed = true);
  }

  void _onNextPlayer() {
    setState(() {
      _isCountingDown = true;
      _countdown = AppDefaults.revealCountdown;
    });
    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _countdown--);
      final provider = context.read<GameProvider>();
      provider.playSound(GameSound.countdown);
      provider.triggerHaptic(HapticType.light);
      if (_countdown <= 0) {
        timer.cancel();
        _proceedToNext();
      }
    });
  }

  void _proceedToNext() {
    final provider = context.read<GameProvider>();
    provider.nextPlayerReveal();
    final state = provider.gameState;
    if (state != null && state.phase == GamePhase.clues) {
      Navigator.pushReplacementNamed(
        context, AppRoutes.clues);
    } else {
      setState(() {
        _isRevealed = false;
        _isCountingDown = false;
        _countdown = AppDefaults.revealCountdown;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameProvider>().gameState;
    if (state == null) return const SizedBox.shrink();

    final player = state.currentPlayer;
    final total = state.players.length;
    final current = state.currentPlayerIndex + 1;
    // Progreso de revelacion
    final progress = current / total;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.2,
              colors: [
                AppColors.surface,
                AppColors.background,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                // Barra de progreso superior
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: AppColors.greyLight,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(
                      AppColors.green),
                  ),
                ),
                const SizedBox(height: 8),
                // Indicador de jugador
                Text(
                  'Jugador $current de $total',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.greyMedium),
                ).animate().fadeIn(),
                const Spacer(),
                // Nombre del jugador
                Text(
                  player.name,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white),
                ).animate().fadeIn(duration: 500.ms),
                const SizedBox(height: 32),
                // Carta o cuenta regresiva
                if (_isCountingDown)
                  _buildCountdownOverlay()
                else
                  RevealCard(
                    isImpostor: player.isImpostor,
                    secretWord: state.secretWord,
                    categoryName:
                        state.selectedCategory.name,
                    isRevealed: _isRevealed,
                    onTap: _onCardTap,
                  ),
                const Spacer(),
                // Boton siguiente
                if (_isRevealed && !_isCountingDown)
                  SizedBox(
                    width: double.infinity, height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _onNextPlayer,
                      icon: const Icon(
                        Icons.arrow_forward_rounded),
                      label: Text(AppStrings.readyNext,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            AppDefaults.cardRadius)),
                      ),
                    ),
                  ).animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.3, end: 0),
                const SizedBox(height: 16),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  /// Overlay de cuenta regresiva con numeros grandes dorados
  Widget _buildCountdownOverlay() {
    return SizedBox(
      height: 250,
      child: Center(
        child: Text(
          '$_countdown',
          key: ValueKey(_countdown),
          style: GoogleFonts.poppins(
            fontSize: 100,
            fontWeight: FontWeight.w800,
            color: AppColors.gold,
          ),
        ).animate()
            .scale(
              begin: const Offset(1.5, 1.5),
              end: const Offset(0.8, 0.8),
              duration: 800.ms,
              curve: Curves.easeOut)
            .fadeOut(delay: 600.ms, duration: 200.ms),
      ),
    );
  }
}
