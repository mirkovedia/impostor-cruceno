import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants.dart';
import '../providers/game_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final theme = Theme.of(context);

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
          _buildSectionHeader('Apariencia', theme),
          _buildThemeSelector(context, provider, theme),
          _sectionDivider(theme),
          _buildSectionHeader('Audio y Vibracion', theme),
          SwitchListTile(
            title: Text(AppStrings.sound,
              style: GoogleFonts.poppins()),
            subtitle: Text('Efectos de sonido',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
            secondary: Icon(
              provider.isSoundEnabled
                  ? Icons.volume_up
                  : Icons.volume_off,
              color: theme.colorScheme.primary),
            value: provider.isSoundEnabled,
            activeTrackColor: theme.colorScheme.primary,
            onChanged: (_) => provider.toggleSound(),
          ),
          SwitchListTile(
            title: Text(AppStrings.vibration,
              style: GoogleFonts.poppins()),
            subtitle: Text('Feedback haptico',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
            secondary: Icon(Icons.vibration,
              color: theme.colorScheme.primary),
            value: provider.isVibrationEnabled,
            activeTrackColor: theme.colorScheme.primary,
            onChanged: (_) => provider.toggleVibration(),
          ),
          _sectionDivider(theme),
          _buildSectionHeader('Notificaciones', theme),
          _buildNotificationSection(context, provider, theme),
          _sectionDivider(theme),
          _buildSectionHeader('Valores por defecto', theme),
          _buildTimeSlider(provider, theme),
          _buildImpostorSelector(provider),
          _sectionDivider(theme),
          _buildSectionHeader('Peligroso', theme),
          _buildResetTile(context),
          _sectionDivider(theme),
          _buildSectionHeader('Acerca de', theme),
          _buildAboutSection(theme),
        ],
      ),
    );
  }

  Widget _buildThemeSelector(
      BuildContext context, GameProvider provider, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tema de color',
            style: GoogleFonts.poppins(
              fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          Row(
            children: [
              _themeOption(
                context: context,
                provider: provider,
                type: AppThemeType.cruceno,
                label: 'Cruceño',
                icon: Icons.flag_rounded,
                colors: [AppColors.crucenoGreen, AppColors.white, AppColors.crucenoGreen],
                isSelected: provider.themeType == AppThemeType.cruceno,
              ),
              const SizedBox(width: 10),
              _themeOption(
                context: context,
                provider: provider,
                type: AppThemeType.dark,
                label: 'Oscuro',
                icon: Icons.dark_mode,
                colors: [AppColors.background, AppColors.grey, AppColors.surface],
                isSelected: provider.themeType == AppThemeType.dark,
              ),
              const SizedBox(width: 10),
              _themeOption(
                context: context,
                provider: provider,
                type: AppThemeType.light,
                label: 'Claro',
                icon: Icons.light_mode,
                colors: [AppColors.white, AppColors.surfaceLight, AppColors.white],
                isSelected: provider.themeType == AppThemeType.light,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _themeOption({
    required BuildContext context,
    required GameProvider provider,
    required AppThemeType type,
    required String label,
    required IconData icon,
    required List<Color> colors,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: () => provider.setThemeType(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.1)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.12),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              // Mini bandera de colores
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: colors.map((c) => Container(
                  width: 14, height: 14,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.1), width: 0.5),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 8),
              Icon(icon, size: 18,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.5)),
              const SizedBox(height: 4),
              Text(label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: isSelected
                      ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionDivider(ThemeData theme) {
    return Divider(
      indent: 16, endIndent: 16,
      color: theme.dividerColor);
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(title,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.secondary,
          letterSpacing: 0.5)),
    );
  }

  Widget _buildNotificationSection(
      BuildContext context, GameProvider provider, ThemeData theme) {
    const dayNames = {
      DateTime.monday: 'Lunes',
      DateTime.tuesday: 'Martes',
      DateTime.wednesday: 'Miércoles',
      DateTime.thursday: 'Jueves',
      DateTime.friday: 'Viernes',
      DateTime.saturday: 'Sábado',
      DateTime.sunday: 'Domingo',
    };

    return Column(
      children: [
        SwitchListTile(
          title: Text('Recordatorios',
            style: GoogleFonts.poppins()),
          subtitle: Text(
            provider.isNotificationsEnabled
                ? 'Te recordaremos jugar cada semana'
                : 'Activá para recibir recordatorios',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
          secondary: Icon(
            provider.isNotificationsEnabled
                ? Icons.notifications_active
                : Icons.notifications_off_outlined,
            color: provider.isNotificationsEnabled
                ? AppColors.gold : theme.colorScheme.onSurface.withValues(alpha: 0.3)),
          value: provider.isNotificationsEnabled,
          activeTrackColor: AppColors.gold,
          onChanged: (_) => provider.toggleNotifications(),
        ),
        if (provider.isNotificationsEnabled) ...[
          ListTile(
            leading: Icon(Icons.calendar_today,
              color: theme.colorScheme.primary, size: 20),
            title: Text('Día del recordatorio',
              style: GoogleFonts.poppins(fontSize: 14)),
            trailing: DropdownButton<int>(
              value: provider.reminderDay,
              underline: const SizedBox.shrink(),
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface),
              items: dayNames.entries.map((e) => DropdownMenuItem(
                value: e.key,
                child: Text(e.value),
              )).toList(),
              onChanged: (v) {
                if (v != null) provider.setReminderDay(v);
              },
            ),
          ),
          ListTile(
            leading: Icon(Icons.access_time,
              color: theme.colorScheme.primary, size: 20),
            title: Text('Hora del recordatorio',
              style: GoogleFonts.poppins(fontSize: 14)),
            trailing: DropdownButton<int>(
              value: provider.reminderHour,
              underline: const SizedBox.shrink(),
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface),
              items: List.generate(24, (i) => DropdownMenuItem(
                value: i,
                child: Text('${i.toString().padLeft(2, '0')}:00'),
              )),
              onChanged: (v) {
                if (v != null) provider.setReminderHour(v);
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTimeSlider(GameProvider provider, ThemeData theme) {
    return ListTile(
      leading: Icon(Icons.timer,
        color: theme.colorScheme.primary),
      title: Text('Tiempo de ronda',
        style: GoogleFonts.poppins()),
      subtitle: Slider(
        value: provider.defaultRoundTime.toDouble(),
        min: AppDefaults.minRoundTime.toDouble(),
        max: AppDefaults.maxRoundTime.toDouble(),
        divisions: 10,
        activeColor: theme.colorScheme.primary,
        inactiveColor: theme.colorScheme.onSurface.withValues(alpha: 0.12),
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
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
      onTap: () => _showResetDialog(context),
    );
  }

  Widget _buildAboutSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        Text(AppStrings.appName,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary)),
        const SizedBox(height: 4),
        Text('v1.0.0',
          style: GoogleFonts.poppins(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
        const SizedBox(height: 8),
        Text('Proyecto universitario',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
        const SizedBox(height: 4),
        const Text('Hecho en Santa Cruz 🇧🇴'),
      ]),
    );
  }

  void _showResetDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
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
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5)))),
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
