import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../core/app_routes.dart';
import '../providers/room_provider.dart';
import '../providers/game_provider.dart';
import '../services/audio_service.dart';
import '../services/haptic_service.dart';
import '../widgets/reveal_card.dart';

class OnlineRevealScreen extends StatefulWidget {
  const OnlineRevealScreen({super.key});

  @override
  State<OnlineRevealScreen> createState() => _OnlineRevealScreenState();
}

class _OnlineRevealScreenState extends State<OnlineRevealScreen> {
  bool _revealed = false;
  String? _lastPhase;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final roomProvider = context.watch<RoomProvider>();
    final gameProvider = context.read<GameProvider>();
    final room = roomProvider.room;

    if (room == null) return const SizedBox.shrink();

    // Detectar transicion a fase clues
    if (room.phase != _lastPhase) {
      _lastPhase = room.phase;
      if (room.phase == 'clues') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.pushReplacementNamed(context, AppRoutes.onlineClues);
          }
        });
        return const SizedBox.shrink();
      }
    }

    final myPlayer = roomProvider.myPlayer;
    if (myPlayer == null) return const SizedBox.shrink();

    final isImpostor = myPlayer.isImpostor;
    final secretWord = room.secretWord ?? '';
    final categoryName = room.selectedCategoryName ?? '';
    final allRevealed = room.players.every((p) => p.hasRevealed);
    final revealedCount = room.players.where((p) => p.hasRevealed).length;

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
                theme.colorScheme.surface,
                theme.scaffoldBackgroundColor,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: revealedCount / room.players.length,
                      minHeight: 4,
                      backgroundColor: theme.colorScheme.onSurface
                          .withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$revealedCount de ${room.players.length} han visto su rol',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.5)),
                  ).animate().fadeIn(),
                  const Spacer(),
                  Text(myPlayer.name,
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface),
                  ).animate().fadeIn(duration: 500.ms),
                  const SizedBox(height: 32),
                  RevealCard(
                    isImpostor: isImpostor,
                    secretWord: secretWord,
                    categoryName: categoryName,
                    isRevealed: _revealed,
                    onTap: () {
                      if (_revealed) return;
                      setState(() => _revealed = true);
                      gameProvider.playSound(GameSound.reveal);
                      gameProvider.triggerHaptic(HapticType.medium);
                      roomProvider.markRevealed();
                    },
                  ),
                  const Spacer(),
                  if (_revealed && !allRevealed)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: theme.colorScheme.primary
                              .withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.primary),
                          ),
                          const SizedBox(width: 12),
                          Text('Esperando que todos vean su rol...',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            )),
                        ],
                      ),
                    ).animate().fadeIn(duration: 300.ms)
                  else if (_revealed && allRevealed && roomProvider.isHost)
                    SizedBox(
                      width: double.infinity, height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () => roomProvider.advancePlayer(),
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: Text('COMENZAR RONDA DE PISTAS',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.crucenoGreen,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ).animate().fadeIn(duration: 400.ms)
                        .slideY(begin: 0.3, end: 0)
                  else if (_revealed && allRevealed)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text('El host va a iniciar las pistas...',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        )),
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
