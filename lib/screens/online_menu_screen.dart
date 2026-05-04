import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../core/app_routes.dart';
import '../providers/room_provider.dart';

class OnlineMenuScreen extends StatefulWidget {
  const OnlineMenuScreen({super.key});

  @override
  State<OnlineMenuScreen> createState() => _OnlineMenuScreenState();
}

class _OnlineMenuScreenState extends State<OnlineMenuScreen> {
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final roomProvider = context.read<RoomProvider>();
    _nameController.text = roomProvider.savedPlayerName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String get _playerName => _nameController.text.trim();

  bool get _isNameValid => _playerName.length >= 2;

  Future<void> _createRoom() async {
    if (!_isNameValid) {
      _showNameError();
      return;
    }

    setState(() => _isLoading = true);
    final roomProvider = context.read<RoomProvider>();
    final success = await roomProvider.createRoom(hostName: _playerName);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pushNamed(context, AppRoutes.lobby);
    } else {
      _showError(roomProvider.errorMessage ?? 'Error desconocido');
    }
  }

  void _goToJoin() {
    if (!_isNameValid) {
      _showNameError();
      return;
    }
    context.read<RoomProvider>().savePlayerName(_playerName);
    Navigator.pushNamed(context, AppRoutes.joinRoom);
  }

  void _showNameError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Escribí tu nombre (mínimo 2 letras)')),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Modo Online',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),
            Icon(Icons.wifi_rounded,
              size: 64,
              color: theme.colorScheme.primary)
                .animate().fadeIn(duration: 500.ms)
                .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1)),
            const SizedBox(height: 24),
            Text('Tu nombre',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              )),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              textAlign: TextAlign.center,
              maxLength: 15,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: 'Ej: Camba123',
                hintStyle: GoogleFonts.poppins(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                counterText: '',
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary, width: 2),
                ),
              ),
            ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _createRoom,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.white))
                    : const Icon(Icons.add_rounded, size: 24),
                label: Text(
                  _isLoading ? 'Creando...' : 'CREAR SALA',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.crucenoGreen,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                  shadowColor: AppColors.crucenoGreen.withValues(alpha: 0.3),
                ),
              ),
            ).animate(delay: 400.ms)
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.1, end: 0),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _goToJoin,
                icon: const Icon(Icons.qr_code_scanner_rounded, size: 24),
                label: Text(
                  'UNIRSE A SALA',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  side: BorderSide(
                    color: theme.colorScheme.primary.withValues(alpha: 0.4),
                    width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ).animate(delay: 550.ms)
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.1, end: 0),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
