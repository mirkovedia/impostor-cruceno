import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../core/constants.dart';
import '../core/app_routes.dart';
import '../models/room.dart';
import '../models/category.dart';
import '../providers/room_provider.dart';
import '../providers/game_provider.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  bool _wasPlaying = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final roomProvider = context.watch<RoomProvider>();
    final room = roomProvider.room;

    if (room == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Sala',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text('Conectando...',
                style: GoogleFonts.poppins(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
            ],
          ),
        ),
      );
    }

    // Detectar cambio de fase: cuando el host inicia el juego
    if (room.status == RoomStatus.playing && !_wasPlaying) {
      _wasPlaying = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.onlineReveal);
        }
      });
    }

    final isHost = roomProvider.isHost;
    final qrData = 'IMPOSTOR:${room.code}';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _showLeaveDialog(context, roomProvider);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Sala ${room.code}',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _showLeaveDialog(context, roomProvider),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.copy_rounded, size: 20),
              tooltip: 'Copiar código',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: room.code));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Código ${room.code} copiado')),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // QR + codigo
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text('Compartí este QR',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    )),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 160,
                      backgroundColor: AppColors.white,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.circle,
                        color: AppColors.crucenoGreen,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.circle,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(room.code,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 6,
                        color: theme.colorScheme.primary,
                      )),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms),
            // Lista de jugadores
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(Icons.people_rounded,
                    size: 18,
                    color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Jugadores (${room.players.length}/12)',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  if (room.players.length < 3)
                    Text('Mínimo 3',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.red,
                        fontWeight: FontWeight.w500,
                      )),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: room.players.length,
                itemBuilder: (_, i) {
                  final player = room.players[i];
                  final isMe = player.deviceId == roomProvider.deviceId;
                  return _PlayerTile(
                    player: player,
                    isMe: isMe,
                    theme: theme,
                  ).animate(delay: Duration(milliseconds: 100 * i))
                      .fadeIn(duration: 300.ms)
                      .slideX(begin: 0.05, end: 0);
                },
              ),
            ),
            // Boton iniciar (solo host)
            if (isHost)
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: room.players.length >= 3
                        ? () => _showCategoryPicker(context, roomProvider)
                        : null,
                    icon: const Icon(Icons.play_arrow_rounded, size: 28),
                    label: Text(
                      'INICIAR PARTIDA',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.crucenoGreen,
                      foregroundColor: AppColors.white,
                      disabledBackgroundColor:
                          theme.colorScheme.onSurface.withValues(alpha: 0.12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                      elevation: 4,
                    ),
                  ),
                ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
              )
            else
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2)),
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
                      Text('Esperando al host...',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        )),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showLeaveDialog(BuildContext context, RoomProvider provider) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text('Salir de la sala',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text(
          provider.isHost
              ? 'Si salís, la sala se cerrará para todos.'
              : '¿Seguro que querés salir de la sala?',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Quedarme',
              style: GoogleFonts.poppins(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.leaveRoom();
              Navigator.of(context).popUntil(
                (route) => route.isFirst);
            },
            child: Text('Salir',
              style: GoogleFonts.poppins(
                color: AppColors.red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showCategoryPicker(BuildContext context, RoomProvider roomProvider) {
    final theme = Theme.of(context);
    final categories = context.read<GameProvider>().categories;

    if (categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay categorías disponibles')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _CategoryPickerSheet(
        categories: categories,
        onSelected: (category) {
          Navigator.pop(ctx);
          roomProvider.startGame(category);
        },
      ),
    );
  }
}

class _PlayerTile extends StatelessWidget {
  final RoomPlayer player;
  final bool isMe;
  final ThemeData theme;

  const _PlayerTile({
    required this.player,
    required this.isMe,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isMe
            ? theme.colorScheme.primary.withValues(alpha: 0.08)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMe
              ? theme.colorScheme.primary.withValues(alpha: 0.3)
              : theme.colorScheme.onSurface.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: isMe
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.1),
            child: Text(
              player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: isMe
                    ? AppColors.white
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(player.name,
                      style: GoogleFonts.poppins(
                        fontWeight: isMe ? FontWeight.w600 : FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      )),
                    if (isMe) ...[
                      const SizedBox(width: 6),
                      Text('(vos)',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        )),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (player.isHost)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('HOST',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gold,
                )),
            ),
        ],
      ),
    );
  }
}

class _CategoryPickerSheet extends StatelessWidget {
  final List<Category> categories;
  final void Function(Category) onSelected;

  const _CategoryPickerSheet({
    required this.categories,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          Text('Elegí una categoría',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            )),
          const SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (_, i) {
                final cat = categories[i];
                return ListTile(
                  leading: Text(cat.icon, style: const TextStyle(fontSize: 28)),
                  title: Text(cat.name,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                  subtitle: Text('${cat.words.length} palabras',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    )),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                  onTap: () => onSelected(cat),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
