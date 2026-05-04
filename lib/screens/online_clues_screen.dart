import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../core/app_routes.dart';
import '../models/room.dart';
import '../providers/room_provider.dart';
import '../providers/game_provider.dart';
import '../services/audio_service.dart';

class OnlineCluesScreen extends StatefulWidget {
  const OnlineCluesScreen({super.key});

  @override
  State<OnlineCluesScreen> createState() => _OnlineCluesScreenState();
}

class _OnlineCluesScreenState extends State<OnlineCluesScreen> {
  Timer? _timer;
  int _secondsLeft = 0;
  bool _timerStarted = false;
  String? _lastPhase;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimerIfNeeded(Room room) {
    if (_timerStarted) return;
    _timerStarted = true;
    _secondsLeft = room.roundTimeSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final roomProvider = context.watch<RoomProvider>();
    final gameProvider = context.read<GameProvider>();
    final room = roomProvider.room;

    if (room == null) return const SizedBox.shrink();

    // Detectar transicion a votacion
    if (room.phase != _lastPhase) {
      _lastPhase = room.phase;
      if (room.phase == 'voting') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.pushReplacementNamed(context, AppRoutes.onlineVoting);
          }
        });
        return const SizedBox.shrink();
      }
    }

    _startTimerIfNeeded(room);

    final currentPlayer = room.currentPlayer;
    final myPlayer = roomProvider.myPlayer;
    final isMyTurn = currentPlayer?.deviceId == roomProvider.deviceId;
    final minutes = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsLeft % 60).toString().padLeft(2, '0');

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
                  // Ronda y timer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Ronda ${room.currentRound}/${room.totalRounds}',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _secondsLeft <= 10
                              ? AppColors.red.withValues(alpha: 0.1)
                              : theme.colorScheme.onSurface
                                  .withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.timer_outlined, size: 16,
                              color: _secondsLeft <= 10
                                  ? AppColors.red
                                  : theme.colorScheme.onSurface
                                      .withValues(alpha: 0.5)),
                            const SizedBox(width: 4),
                            Text('$minutes:$seconds',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _secondsLeft <= 10
                                    ? AppColors.red
                                    : theme.colorScheme.onSurface,
                              )),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Instruccion
                  Text(AppStrings.clueInstruction,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(duration: 400.ms),
                  const SizedBox(height: 8),
                  if (myPlayer != null && !myPlayer.isImpostor)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.crucenoGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.crucenoGreen.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        'Tu palabra: ${room.secretWord ?? ""}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.crucenoGreen,
                        ),
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 400.ms)
                  else if (myPlayer != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.red.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        'Sos el IMPOSTOR - inventá algo',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.red,
                        ),
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                  const Spacer(),
                  // Turno actual
                  if (currentPlayer != null) ...[
                    Text(
                      isMyTurn ? 'TU TURNO' : 'Turno de',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.5)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isMyTurn ? 'Decí tu pista en voz alta' : currentPlayer.name,
                      style: GoogleFonts.poppins(
                        fontSize: isMyTurn ? 18 : 32,
                        fontWeight: FontWeight.w700,
                        color: isMyTurn
                            ? AppColors.gold
                            : theme.colorScheme.onSurface,
                      ),
                    ).animate().fadeIn(duration: 400.ms),
                  ],
                  const Spacer(),
                  // Lista de jugadores con estado
                  _buildPlayerList(room, roomProvider, theme),
                  const SizedBox(height: 16),
                  // Boton avanzar (solo para el jugador actual o host)
                  if (isMyTurn)
                    SizedBox(
                      width: double.infinity, height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          gameProvider.playSound(GameSound.tick);
                          roomProvider.markClueGiven();
                          roomProvider.advancePlayer();
                        },
                        icon: const Icon(Icons.check_rounded),
                        label: Text('YA DI MI PISTA',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.crucenoGreen,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ).animate().fadeIn(duration: 300.ms)
                        .slideY(begin: 0.2, end: 0)
                  else if (roomProvider.isHost && _secondsLeft <= 0)
                    SizedBox(
                      width: double.infinity, height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () => roomProvider.advancePlayer(),
                        icon: const Icon(Icons.skip_next_rounded),
                        label: Text('PASAR A VOTACIÓN',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: AppColors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ).animate().fadeIn(duration: 300.ms),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerList(Room room, RoomProvider provider, ThemeData theme) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: room.players.length,
        itemBuilder: (_, i) {
          final player = room.players[i];
          final isCurrent = i == room.currentPlayerIndex;
          final hasGiven = player.hasGivenClue;
          return Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isCurrent
                  ? theme.colorScheme.primary.withValues(alpha: 0.15)
                  : hasGiven
                      ? AppColors.crucenoGreen.withValues(alpha: 0.08)
                      : theme.colorScheme.onSurface.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isCurrent
                    ? theme.colorScheme.primary.withValues(alpha: 0.4)
                    : Colors.transparent,
                width: isCurrent ? 2 : 0,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  player.name,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                    color: isCurrent
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                  ),
                ),
                if (hasGiven)
                  Icon(Icons.check_circle, size: 14,
                    color: AppColors.crucenoGreen.withValues(alpha: 0.7)),
              ],
            ),
          );
        },
      ),
    );
  }
}
