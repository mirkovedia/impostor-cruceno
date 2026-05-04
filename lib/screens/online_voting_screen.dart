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

class OnlineVotingScreen extends StatefulWidget {
  const OnlineVotingScreen({super.key});

  @override
  State<OnlineVotingScreen> createState() => _OnlineVotingScreenState();
}

class _OnlineVotingScreenState extends State<OnlineVotingScreen> {
  String? _selectedId;
  String? _lastPhase;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final roomProvider = context.watch<RoomProvider>();
    final room = roomProvider.room;

    if (room == null) return const SizedBox.shrink();

    // Detectar transicion a resultado
    if (room.phase != _lastPhase) {
      _lastPhase = room.phase;
      if (room.phase == 'result') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.pushReplacementNamed(context, AppRoutes.onlineResult);
          }
        });
        return const SizedBox.shrink();
      }
    }

    final myPlayer = roomProvider.myPlayer;
    if (myPlayer == null) return const SizedBox.shrink();

    final hasVoted = myPlayer.votedForId != null;
    final votedCount = room.players.where((p) => p.votedForId != null).length;
    final othersToVote = room.players
        .where((p) => p.deviceId != roomProvider.deviceId)
        .toList();

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.scaffoldBackgroundColor,
                theme.colorScheme.surface,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Progreso de votos
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: votedCount / room.players.length,
                      minHeight: 4,
                      backgroundColor: theme.colorScheme.onSurface
                          .withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.gold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('$votedCount de ${room.players.length} han votado',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.5))),
                  const SizedBox(height: 24),
                  Icon(Icons.how_to_vote_rounded,
                    size: 40,
                    color: AppColors.gold),
                  const SizedBox(height: 8),
                  Text(
                    hasVoted
                        ? 'Ya votaste'
                        : AppStrings.whoIsImpostor,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(duration: 400.ms),
                  const SizedBox(height: 24),
                  if (!hasVoted)
                    Expanded(
                      child: ListView.builder(
                        itemCount: othersToVote.length,
                        itemBuilder: (_, i) {
                          final player = othersToVote[i];
                          final isSelected = _selectedId == player.id;
                          return GestureDetector(
                            onTap: () {
                              setState(() => _selectedId = player.id);
                              context.read<GameProvider>()
                                  .triggerHaptic(HapticType.light);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.red.withValues(alpha: 0.1)
                                    : theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.red
                                      : theme.colorScheme.onSurface
                                          .withValues(alpha: 0.1),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: isSelected
                                        ? AppColors.red
                                        : theme.colorScheme.onSurface
                                            .withValues(alpha: 0.1),
                                    child: Text(
                                      player.name.isNotEmpty
                                          ? player.name[0].toUpperCase()
                                          : '?',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w700,
                                        color: isSelected
                                            ? AppColors.white
                                            : theme.colorScheme.onSurface
                                                .withValues(alpha: 0.5),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Text(player.name,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      color: theme.colorScheme.onSurface,
                                    )),
                                  const Spacer(),
                                  if (isSelected)
                                    Icon(Icons.check_circle_rounded,
                                      color: AppColors.red),
                                ],
                              ),
                            ),
                          ).animate(delay: Duration(milliseconds: 100 * i))
                              .fadeIn(duration: 300.ms)
                              .slideX(begin: 0.05, end: 0);
                        },
                      ),
                    )
                  else
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_outline_rounded,
                              size: 64,
                              color: AppColors.crucenoGreen
                                  .withValues(alpha: 0.5)),
                            const SizedBox(height: 16),
                            Text('Esperando los demás votos...',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                              )),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: 24, height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.colorScheme.primary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Boton votar
                  if (!hasVoted)
                    SizedBox(
                      width: double.infinity, height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _selectedId != null
                            ? () {
                                context.read<GameProvider>()
                                    .playSound(GameSound.vote);
                                context.read<GameProvider>()
                                    .triggerHaptic(HapticType.heavy);
                                roomProvider.submitVote(_selectedId!);
                              }
                            : null,
                        icon: const Icon(Icons.gavel_rounded),
                        label: Text('VOTAR',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          )),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.red,
                          foregroundColor: AppColors.white,
                          disabledBackgroundColor: theme.colorScheme.onSurface
                              .withValues(alpha: 0.12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 300.ms),
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
