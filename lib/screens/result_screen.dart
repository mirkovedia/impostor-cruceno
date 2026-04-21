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

/// Pantalla de resultado con revelacion dramatica y estadisticas.
class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _soundPlayed = false;

  void _playResultSound() {
    if (_soundPlayed) return;
    _soundPlayed = true;
    final provider = context.read<GameProvider>();
    final state = provider.gameState;
    if (state == null) return;
    if (state.civiliansWin) {
      provider.playSound(GameSound.victory);
      provider.triggerHaptic(HapticType.success);
    } else {
      provider.playSound(GameSound.defeat);
      provider.triggerHaptic(HapticType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameProvider>().gameState;
    if (state == null) return const SizedBox.shrink();

    _playResultSound();

    final impostors = state.impostors;
    final civiliansWin = state.civiliansWin;
    final voteResults = state.voteResults;
    final maxVotes = voteResults.values.isEmpty
        ? 1
        : voteResults.values.reduce(
            (a, b) => a > b ? a : b).clamp(1, 999);

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              const SizedBox(height: 32),
              // Texto introductorio
              Text(AppStrings.impostorWas,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppColors.greyMedium),
              ).animate()
                  .fadeIn(duration: 800.ms),
              const SizedBox(height: 16),
              // Nombres del impostor
              ...impostors.map((imp) => Text(
                imp.name,
                style: GoogleFonts.poppins(
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  color: AppColors.red),
              ).animate()
                  .fadeIn(delay: 1500.ms, duration: 600.ms)
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1.0, 1.0))),
              const SizedBox(height: 24),
              // Banner de resultado
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: civiliansWin
                      ? AppColors.green
                          .withValues(alpha: 0.15)
                      : AppColors.red
                          .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(
                    AppDefaults.cardRadiusLarge),
                  border: Border.all(
                    color: civiliansWin
                        ? AppColors.green
                        : AppColors.red,
                    width: 2)),
                child: Text(
                  civiliansWin
                      ? '${AppStrings.civiliansWin} 🎉'
                      : '${AppStrings.impostorWins} 😈',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: civiliansWin
                        ? AppColors.green
                        : AppColors.red)),
              ).animate()
                  .fadeIn(delay: 2200.ms, duration: 600.ms)
                  .shake(delay: 2800.ms),
              const SizedBox(height: 24),
              // Palabra secreta
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.grey,
                  borderRadius: BorderRadius.circular(
                    AppDefaults.cardRadius),
                  border: Border.all(
                    color: AppColors.gold
                        .withValues(alpha: 0.3))),
                child: Column(children: [
                  Text('La palabra era:',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.greyMedium)),
                  const SizedBox(height: 4),
                  Text(state.secretWord,
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.gold)),
                ]),
              ).animate()
                  .fadeIn(delay: 2500.ms, duration: 500.ms),
              const SizedBox(height: 20),
              // Tarjeta de estadisticas
              _buildStatsCard(
                state, voteResults, maxVotes),
              const SizedBox(height: 28),
              // Botones de accion
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<GameProvider>()
                        .resetGame();
                    Navigator.pushReplacementNamed(
                      context, AppRoutes.setup);
                  },
                  icon: const Icon(
                    Icons.replay_rounded, size: 20),
                  label: Text(AppStrings.playAgain,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
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
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity, height: 52,
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.read<GameProvider>()
                        .resetGame();
                    Navigator.pushNamedAndRemoveUntil(
                      context, AppRoutes.home,
                      (_) => false);
                  },
                  icon: const Icon(
                    Icons.home_rounded, size: 20),
                  label: Text(AppStrings.mainMenu,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
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
              const SizedBox(height: 16),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(
    GameState state,
    Map<String, int> voteResults,
    int maxVotes,
  ) {
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppDefaults.cardRadius)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Estadisticas',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600)),
            const Divider(color: AppColors.greyLight),
            _statRow('Categoria',
              '${state.selectedCategory.icon} '
              '${state.selectedCategory.name}'),
            _statRow('Palabra secreta',
              state.secretWord),
            _statRow('Tiempo por ronda',
              '${state.roundTimeSeconds}s'),
            _statRow('Rondas jugadas',
              '${state.totalRounds}'),
            const SizedBox(height: 12),
            Text('Desglose de votos',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...state.players.map<Widget>((p) {
              final votes = voteResults[p.id] ?? 0;
              final barWidth = maxVotes > 0
                  ? votes / maxVotes : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  SizedBox(
                    width: 90,
                    child: Row(children: [
                      Flexible(
                        child: Text(p.name,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: p.isImpostor
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: p.isImpostor
                                ? AppColors.red
                                : null)),
                      ),
                      if (p.isImpostor)
                        const Text(' *',
                          style: TextStyle(
                            color: AppColors.red,
                            fontSize: 11)),
                    ]),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: barWidth,
                        minHeight: 16,
                        backgroundColor:
                            AppColors.greyLight,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(
                          p.isImpostor
                              ? AppColors.red
                              : AppColors.gold)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('$votes',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
                ]),
              );
            }),
          ],
        ),
      ),
    ).animate()
        .fadeIn(delay: 3000.ms, duration: 600.ms)
        .slideY(begin: 0.2);
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 13)),
          Text(value,
            style: GoogleFonts.poppins(fontSize: 13)),
        ],
      ),
    );
  }
}
