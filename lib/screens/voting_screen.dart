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
import '../widgets/player_chip.dart';

/// Pantalla de votacion interactiva con transicion entre votantes.
class VotingScreen extends StatefulWidget {
  const VotingScreen({super.key});

  @override
  State<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> {
  String? _selectedPlayerId;
  bool _showPassDevice = false;
  String _nextVoterName = '';

  void _onVote() {
    if (_selectedPlayerId == null) return;
    final provider = context.read<GameProvider>();
    provider.playSound(GameSound.vote);
    provider.triggerHaptic(HapticType.medium);

    // Calcular nombre del próximo votante antes de mutar estado
    final currentState = provider.gameState;
    final nextIndex = (currentState?.currentPlayerIndex ?? 0) + 1;
    final nextName = currentState != null &&
            nextIndex < currentState.players.length
        ? currentState.players[nextIndex].name
        : '';

    provider.submitVote(_selectedPlayerId!);

    final state = provider.gameState;
    if (state != null && state.phase == GamePhase.result) {
      Navigator.pushReplacementNamed(
        context, AppRoutes.result);
    } else if (state != null) {
      setState(() {
        _nextVoterName = nextName;
        _showPassDevice = true;
        _selectedPlayerId = null;
      });
      Future.delayed(
        const Duration(milliseconds: 1200), () {
        if (mounted) {
          setState(() => _showPassDevice = false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameProvider>().gameState;
    if (state == null) return const SizedBox.shrink();

    // Pantalla de transicion entre votantes
    if (_showPassDevice) {
      return _buildPassDeviceScreen();
    }

    final currentPlayer = state.currentPlayer;
    final otherPlayers = state.players
        .where((p) => p.id != currentPlayer.id).toList();

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              const Spacer(flex: 1),
              // Titulo con emoji
              Text(
                AppStrings.whoIsImpostor,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700),
              ).animate().fadeIn(),
              const SizedBox(height: 4),
              const Text('🕵️',
                style: TextStyle(fontSize: 36)),
              const SizedBox(height: 16),
              // Badge del votante actual
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.green
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.green
                        .withValues(alpha: 0.5))),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.how_to_vote,
                      color: AppColors.green, size: 18),
                    const SizedBox(width: 8),
                    Text('Vota: ${currentPlayer.name}',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.green)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Pasa el celular a ${currentPlayer.name}',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.greyMedium,
                  fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 24),
              // Grid de jugadores
              Expanded(
                child: GridView.builder(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.5),
                  itemCount: otherPlayers.length,
                  itemBuilder: (context, index) {
                    final player = otherPlayers[index];
                    return PlayerChip(
                      player: player,
                      isSelected:
                          _selectedPlayerId == player.id,
                      onTap: () {
                        context.read<GameProvider>()
                            .triggerHaptic(HapticType.light);
                        setState(() =>
                            _selectedPlayerId = player.id);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Boton de confirmacion
              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton.icon(
                  onPressed: _selectedPlayerId != null
                      ? _onVote : null,
                  icon: const Icon(
                    Icons.check_circle, size: 22),
                  label: Text('CONFIRMAR VOTO',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _selectedPlayerId != null
                            ? AppColors.red
                            : AppColors.greyLight,
                    foregroundColor: AppColors.white,
                    disabledBackgroundColor:
                        AppColors.greyLight,
                    disabledForegroundColor:
                        AppColors.greyMedium,
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

  /// Pantalla intermedia para pasar el dispositivo
  Widget _buildPassDeviceScreen() {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.phone_android,
                size: 48, color: AppColors.gold),
              const SizedBox(height: 24),
              Text('Pasa el celular a',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppColors.greyMedium)),
              const SizedBox(height: 8),
              Text(_nextVoterName,
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.green)),
            ],
          ).animate()
              .fadeIn(duration: 300.ms)
              .scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1.0, 1.0)),
        ),
      ),
    );
  }
}
