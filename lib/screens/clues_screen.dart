import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants.dart';
import '../core/app_routes.dart';
import '../providers/game_provider.dart';
import '../services/audio_service.dart';
import '../services/haptic_service.dart';
import '../widgets/countdown_timer.dart';

/// Pantalla de pistas con soporte multi-ronda.
/// Muestra indicador de ronda, temporizador y lista de jugadores.
class CluesScreen extends StatefulWidget {
  const CluesScreen({super.key});

  @override
  State<CluesScreen> createState() => _CluesScreenState();
}

class _CluesScreenState extends State<CluesScreen> {
  /// Clave para forzar recreacion del timer entre rondas
  int _timerKey = 0;

  void _onTimerFinished() {
    final provider = context.read<GameProvider>();
    provider.playSound(GameSound.timerEnd);
    provider.triggerHaptic(HapticType.heavy);
    _handleEndRound();
  }

  void _onNextPlayer() {
    final provider = context.read<GameProvider>();
    provider.triggerHaptic(HapticType.light);
    provider.nextPlayerClue();
  }

  void _handleEndRound() {
    final provider = context.read<GameProvider>();
    final goToVoting = provider.endCluesRound();
    if (goToVoting) {
      Navigator.pushReplacementNamed(
        context, AppRoutes.voting);
    } else {
      setState(() => _timerKey++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameProvider>().gameState;
    if (state == null) return const SizedBox.shrink();

    final currentRound = state.currentRound;
    final totalRounds = state.totalRounds;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              // Indicador de ronda
              _buildRoundIndicator(
                currentRound, totalRounds),
              const SizedBox(height: 16),
              // Temporizador
              CountdownTimer(
                key: ValueKey(_timerKey),
                totalSeconds: state.roundTimeSeconds,
                onFinished: _onTimerFinished,
              ),
              const SizedBox(height: 16),
              // Banner de instruccion
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.green
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(
                    AppDefaults.cardRadius),
                  border: Border.all(
                    color: AppColors.green
                        .withValues(alpha: 0.3))),
                child: Text(
                  AppStrings.clueInstruction,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.green),
                ),
              ).animate().fadeIn(),
              const SizedBox(height: 16),
              // Jugador actual
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 10, height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.green,
                      shape: BoxShape.circle),
                  ).animate(
                    onPlay: (c) => c.repeat(
                      reverse: true))
                      .scale(
                        begin: const Offset(0.7, 0.7),
                        end: const Offset(1.3, 1.3),
                        duration: 600.ms),
                  const SizedBox(width: 10),
                  Text(
                    '${AppStrings.turnOf} '
                    '${state.currentPlayer.name}',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Lista de jugadores
              Expanded(
                child: ListView.builder(
                  itemCount: state.players.length,
                  itemBuilder: (context, index) {
                    final player = state.players[index];
                    final isCurrent =
                        index == state.currentPlayerIndex;
                    return _buildPlayerRow(
                      player.name,
                      isCurrent,
                      player.hasGivenClue);
                  },
                ),
              ),
              const SizedBox(height: 12),
              // Botones de accion
              Row(children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _onNextPlayer,
                      icon: const Icon(
                        Icons.skip_next_rounded,
                        size: 20),
                      label: Text(AppStrings.nextPlayer,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            AppDefaults.cardRadius))),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _handleEndRound,
                      icon: const Icon(
                        Icons.check_circle_outline,
                        size: 20),
                      label: Text(AppStrings.endRound,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.white,
                        side: BorderSide(
                          color: AppColors.white
                              .withValues(alpha: 0.3)),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            AppDefaults.cardRadius))),
                    ),
                  ),
                ),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  /// Indicador visual de ronda con puntos
  Widget _buildRoundIndicator(int current, int total) {
    return Column(children: [
      Text(
        '${AppStrings.roundOf} $current de $total',
        style: GoogleFonts.poppins(
          fontSize: 16, fontWeight: FontWeight.w600,
          color: AppColors.gold),
      ),
      const SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(total, (i) {
          final isActive = i < current;
          final isCurrent = i == current - 1;
          return Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 4),
            width: isCurrent ? 28 : 12,
            height: 12,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.green
                  : AppColors.greyLight,
              borderRadius: BorderRadius.circular(6)),
          );
        }),
      ),
    ]).animate().fadeIn(duration: 400.ms);
  }

  /// Fila de jugador en la lista de pistas
  Widget _buildPlayerRow(
      String name, bool isCurrent, bool hasGivenClue) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(
        horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isCurrent
            ? AppColors.green.withValues(alpha: 0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isCurrent
            ? Border.all(
                color: AppColors.green, width: 2)
            : null,
      ),
      child: Row(children: [
        if (isCurrent)
          Container(
            width: 10, height: 10,
            margin: const EdgeInsets.only(right: 12),
            decoration: const BoxDecoration(
              color: AppColors.green,
              shape: BoxShape.circle),
          )
        else
          const SizedBox(width: 22),
        Expanded(
          child: Text(name,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: isCurrent
                  ? FontWeight.w600
                  : FontWeight.w400)),
        ),
        if (hasGivenClue)
          const Icon(Icons.check_circle,
            color: AppColors.green, size: 20),
      ]),
    );
  }
}
