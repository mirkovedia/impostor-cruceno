import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../providers/room_provider.dart';
import '../providers/game_provider.dart';
import '../services/audio_service.dart';
import '../services/haptic_service.dart';

class OnlineResultScreen extends StatefulWidget {
  const OnlineResultScreen({super.key});

  @override
  State<OnlineResultScreen> createState() => _OnlineResultScreenState();
}

class _OnlineResultScreenState extends State<OnlineResultScreen> {
  bool _soundPlayed = false;

  void _playResultSoundOnce(bool civiliansWin) {
    if (_soundPlayed) return;
    _soundPlayed = true;
    final gameProvider = context.read<GameProvider>();
    if (civiliansWin) {
      gameProvider.playSound(GameSound.victory);
      gameProvider.triggerHaptic(HapticType.success);
    } else {
      gameProvider.playSound(GameSound.defeat);
      gameProvider.triggerHaptic(HapticType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final roomProvider = context.watch<RoomProvider>();
    final room = roomProvider.room;

    if (room == null) return const SizedBox.shrink();

    final civiliansWin = room.civiliansWin;
    final impostors = room.impostors;
    final voteResults = room.voteResults;
    final maxVotes = voteResults.values.isEmpty
        ? 1
        : voteResults.values.reduce((a, b) => a > b ? a : b).clamp(1, 999);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _playResultSoundOnce(civiliansWin);
    });

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Icono resultado
                Icon(
                  civiliansWin
                      ? Icons.celebration_rounded
                      : Icons.sentiment_very_dissatisfied_rounded,
                  size: 64,
                  color: civiliansWin ? AppColors.gold : AppColors.red,
                ).animate()
                    .scale(
                      begin: const Offset(0.3, 0.3),
                      end: const Offset(1.0, 1.0),
                      duration: 600.ms,
                      curve: Curves.elasticOut)
                    .fadeIn(duration: 300.ms),
                const SizedBox(height: 16),
                // Resultado
                Text(
                  civiliansWin
                      ? AppStrings.civiliansWin
                      : AppStrings.impostorWins,
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: civiliansWin ? AppColors.gold : AppColors.red,
                  ),
                  textAlign: TextAlign.center,
                ).animate(delay: 400.ms).fadeIn(duration: 500.ms),
                const SizedBox(height: 24),
                // Impostor era...
                Text(AppStrings.impostorWas,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface
                        .withValues(alpha: 0.5))),
                const SizedBox(height: 8),
                ...impostors.map((imp) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.red.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.person_off_rounded,
                        color: AppColors.red),
                      const SizedBox(width: 10),
                      Text(imp.name,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.red,
                        )),
                    ],
                  ),
                ).animate(delay: 800.ms).fadeIn(duration: 500.ms)
                    .slideY(begin: 0.2, end: 0)),
                const SizedBox(height: 16),
                // Palabra secreta
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text('La palabra era',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5))),
                      Text(room.secretWord ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        )),
                      Text(
                        '${room.selectedCategoryIcon ?? ""} ${room.selectedCategoryName ?? ""}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.4)),
                      ),
                    ],
                  ),
                ).animate(delay: 1200.ms).fadeIn(duration: 400.ms),
                const SizedBox(height: 24),
                // Votos
                Text('Resultados de la votación',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface)),
                const SizedBox(height: 12),
                ...room.players.map((player) {
                  final votes = voteResults[player.id] ?? 0;
                  final fraction = votes / maxVotes;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 80,
                          child: Text(player.name,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: player.isImpostor
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: player.isImpostor
                                  ? AppColors.red
                                  : theme.colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: fraction,
                              minHeight: 16,
                              backgroundColor: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.06),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                player.isImpostor
                                    ? AppColors.red
                                    : theme.colorScheme.primary),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('$votes',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 32),
                // Botones
                SizedBox(
                  width: double.infinity, height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      roomProvider.leaveRoom();
                      Navigator.of(context).popUntil(
                        (route) => route.isFirst);
                    },
                    icon: const Icon(Icons.home_rounded),
                    label: Text(AppStrings.mainMenu,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ).animate(delay: 1600.ms).fadeIn(duration: 400.ms),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
