import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants.dart';
import '../providers/game_provider.dart';

/// Pantalla de configuracion con secciones organizadas.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.settings,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _buildSectionHeader('Apariencia'),
          SwitchListTile(
            title: Text(AppStrings.darkMode,
              style: GoogleFonts.poppins()),
            subtitle: Text('Tema de la aplicacion',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.greyMedium)),
            secondary: Icon(
              provider.isDarkMode
                  ? Icons.dark_mode
                  : Icons.light_mode,
              color: AppColors.gold),
            value: provider.isDarkMode,
            activeTrackColor: AppColors.green,
            onChanged: (_) => provider.toggleDarkMode(),
          ).animate().fadeIn(duration: 300.ms),
          _sectionDivider(),
          _buildSectionHeader('Audio y Vibracion'),
          SwitchListTile(
            title: Text(AppStrings.sound,
              style: GoogleFonts.poppins()),
            subtitle: Text('Efectos de sonido',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.greyMedium)),
            secondary: Icon(
              provider.isSoundEnabled
                  ? Icons.volume_up
                  : Icons.volume_off,
              color: AppColors.green),
            value: provider.isSoundEnabled,
            activeTrackColor: AppColors.green,
            onChanged: (_) => provider.toggleSound(),
          ),
          SwitchListTile(
            title: Text(AppStrings.vibration,
              style: GoogleFonts.poppins()),
            subtitle: Text('Feedback haptico',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.greyMedium)),
            secondary: const Icon(Icons.vibration,
              color: AppColors.green),
            value: provider.isVibrationEnabled,
            activeTrackColor: AppColors.green,
            onChanged: (_) =>
                provider.toggleVibration(),
          ),
          _sectionDivider(),
          _buildSectionHeader('Valores por defecto'),
          _buildTimeSlider(provider),
          _buildImpostorSelector(provider),
          _sectionDivider(),
          _buildSectionHeader('Peligroso'),
          _buildResetTile(context),
          _sectionDivider(),
          _buildSectionHeader('Acerca de'),
          _buildAboutSection(),
        ],
      ),
    );
  }

  Widget _sectionDivider() {
    return const Divider(
      indent: 16, endIndent: 16,
      color: AppColors.greyLight);
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(title,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.gold,
          letterSpacing: 0.5)),
    );
  }

  Widget _buildTimeSlider(GameProvider provider) {
    return ListTile(
      leading: const Icon(Icons.timer,
        color: AppColors.green),
      title: Text('Tiempo de ronda',
        style: GoogleFonts.poppins()),
      subtitle: Slider(
        value: provider.defaultRoundTime.toDouble(),
        min: AppDefaults.minRoundTime.toDouble(),
        max: AppDefaults.maxRoundTime.toDouble(),
        divisions: 10,
        activeColor: AppColors.green,
        inactiveColor: AppColors.greyLight,
        label: '${provider.defaultRoundTime}s',
        onChanged: (v) =>
            provider.defaultRoundTime = v.round(),
      ),
      trailing: Text(
        '${provider.defaultRoundTime}s',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildImpostorSelector(GameProvider provider) {
    return ListTile(
      leading: const Icon(Icons.person_off,
        color: AppColors.red),
      title: Text('Impostores por defecto',
        style: GoogleFonts.poppins()),
      trailing: SegmentedButton<int>(
        segments: const [
          ButtonSegment(value: 1, label: Text('1')),
          ButtonSegment(value: 2, label: Text('2')),
        ],
        selected: {provider.defaultImpostors},
        onSelectionChanged: (v) =>
            provider.defaultImpostors = v.first,
      ),
    );
  }

  Widget _buildResetTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.restore,
        color: AppColors.red),
      title: Text(AppStrings.resetSettings,
        style: GoogleFonts.poppins()),
      subtitle: Text(
        'Volver a los valores originales',
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: AppColors.greyMedium)),
      onTap: () => _showResetDialog(context),
    );
  }

  Widget _buildAboutSection() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        Text(AppStrings.appName,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.green)),
        const SizedBox(height: 4),
        Text('v1.0.0',
          style: GoogleFonts.poppins(
            color: AppColors.greyMedium)),
        const SizedBox(height: 8),
        Text('Proyecto universitario',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppColors.greyMedium)),
        const SizedBox(height: 4),
        const Text('Hecho en Santa Cruz 🇧🇴'),
      ]),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Resetear configuracion',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600)),
        content: Text(
          'Se restauraran todos los valores por defecto.',
          style: GoogleFonts.poppins(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar',
              style: GoogleFonts.poppins(
                color: AppColors.greyMedium))),
          TextButton(
            onPressed: () {
              context.read<GameProvider>()
                  .resetSettings();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Configuracion reseteada')));
            },
            child: Text('Resetear',
              style: GoogleFonts.poppins(
                color: AppColors.red,
                fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
