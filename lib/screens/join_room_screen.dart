import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../core/app_routes.dart';
import '../providers/room_provider.dart';

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _codeController = TextEditingController();
  bool _isLoading = false;
  bool _scanned = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _joinWithCode(String code) async {
    if (code.trim().length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresá un código válido')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final roomProvider = context.read<RoomProvider>();
    final success = await roomProvider.joinRoom(
      code: code.trim(),
      playerName: roomProvider.savedPlayerName,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pushReplacementNamed(context, AppRoutes.lobby);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(roomProvider.errorMessage ?? 'No se pudo unir'),
        ),
      );
      _scanned = false;
    }
  }

  void _onQrDetected(BarcodeCapture capture) {
    if (_scanned || _isLoading) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    final raw = barcode.rawValue!;
    // Formato esperado: "IMPOSTOR:CODIGO" o solo el codigo
    final code = raw.startsWith('IMPOSTOR:')
        ? raw.substring('IMPOSTOR:'.length)
        : raw;

    if (code.length >= 4) {
      _scanned = true;
      _joinWithCode(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Unirse a sala',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w400),
          indicatorColor: theme.colorScheme.primary,
          tabs: const [
            Tab(icon: Icon(Icons.qr_code_scanner_rounded), text: 'Escanear QR'),
            Tab(icon: Icon(Icons.keyboard_rounded), text: 'Código manual'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildScannerTab(theme),
          _buildManualTab(theme),
        ],
      ),
    );
  }

  Widget _buildScannerTab(ThemeData theme) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text('Uniéndose a la sala...',
              style: GoogleFonts.poppins(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
          ],
        ),
      );
    }

    return Stack(
      children: [
        MobileScanner(onDetect: _onQrDetected),
        Positioned(
          bottom: 40,
          left: 24, right: 24,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'Apuntá la cámara al código QR de la sala',
              style: GoogleFonts.poppins(
                color: AppColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
        ),
      ],
    );
  }

  Widget _buildManualTab(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),
          Icon(Icons.meeting_room_rounded,
            size: 64,
            color: theme.colorScheme.primary.withValues(alpha: 0.5))
              .animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 24),
          Text('Código de sala',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            )),
          const SizedBox(height: 8),
          TextField(
            controller: _codeController,
            textAlign: TextAlign.center,
            maxLength: 8,
            textCapitalization: TextCapitalization.characters,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: 6,
            ),
            decoration: InputDecoration(
              hintText: 'ABC123',
              hintStyle: GoogleFonts.poppins(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                letterSpacing: 6),
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
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _isLoading
                  ? null
                  : () => _joinWithCode(_codeController.text),
              icon: _isLoading
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.white))
                  : const Icon(Icons.login_rounded),
              label: Text(
                _isLoading ? 'Uniéndose...' : 'UNIRSE',
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
              ),
            ),
          ).animate(delay: 400.ms).fadeIn(duration: 400.ms),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
