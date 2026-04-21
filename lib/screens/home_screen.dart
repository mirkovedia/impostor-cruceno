import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants.dart';
import '../core/app_routes.dart';
import '../widgets/camba_character.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryText = isDark ? AppColors.greyMedium : AppColors.crucenoTextSecondary;
    final btnOutlineBorder = isDark
        ? AppColors.white.withValues(alpha: 0.3)
        : AppColors.crucenoGreen.withValues(alpha: 0.3);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0A2E14),
                    Color(0xFF0D1F0D),
                    AppColors.background,
                    Color(0xFF1A0A0A),
                  ],
                  stops: [0.0, 0.3, 0.7, 1.0],
                )
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.crucenoGreen,
                    Color(0xFF00A83F),
                    AppColors.crucenoBg,
                    AppColors.crucenoBg,
                  ],
                  stops: [0.0, 0.12, 0.28, 1.0],
                ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Spacer(flex: 2),
                // Personaje camba
                const CambaCharacter(
                  size: 130,
                  animated: true,
                  suspicious: true,
                ).animate()
                    .fadeIn(duration: 600.ms)
                    .scale(
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1.0, 1.0),
                      duration: 700.ms,
                      curve: Curves.elasticOut,
                    ),
                const SizedBox(height: 12),
                // Titulo principal
                Text(
                  AppStrings.appName,
                  style: GoogleFonts.poppins(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.green : AppColors.crucenoGreen,
                    letterSpacing: 2.0,
                    height: 1.1,
                    shadows: [
                      Shadow(
                        color: isDark
                            ? AppColors.gold
                            : AppColors.crucenoGreen.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(duration: 700.ms)
                    .slideY(begin: -0.3, end: 0, duration: 700.ms),
                const SizedBox(height: 8),
                // Subtitulo
                Text(
                  AppStrings.subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: secondaryText,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate(delay: 400.ms)
                    .fadeIn(duration: 500.ms),
                const SizedBox(height: 20),
                // Linea decorativa bandera verde-blanco-verde
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 30, height: 3,
                      decoration: BoxDecoration(
                        color: AppColors.crucenoGreen,
                        borderRadius: BorderRadius.circular(2)),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 30, height: 3,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.white : AppColors.crucenoGreen.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2)),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 30, height: 3,
                      decoration: BoxDecoration(
                        color: AppColors.crucenoGreen,
                        borderRadius: BorderRadius.circular(2)),
                    ),
                  ],
                )
                    .animate(delay: 600.ms)
                    .fadeIn(duration: 500.ms)
                    .scaleX(begin: 0.0, end: 1.0, duration: 600.ms),
                const Spacer(flex: 2),
                // Boton JUGAR
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.setup);
                    },
                    icon: const Icon(Icons.play_arrow_rounded, size: 28),
                    label: Text(
                      AppStrings.play,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.0,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.crucenoGreen,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDefaults.cardRadius),
                      ),
                      elevation: 8,
                      shadowColor: AppColors.crucenoGreen.withValues(alpha: 0.4),
                    ),
                  ),
                )
                    .animate(delay: 700.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.2, end: 0)
                    .then(delay: 500.ms)
                    .shimmer(
                      duration: 1800.ms,
                      color: AppColors.gold.withValues(alpha: 0.3),
                    ),
                const SizedBox(height: 16),
                // Boton Como jugar
                _buildOutlinedButton(
                  label: AppStrings.howToPlay,
                  icon: Icons.help_outline_rounded,
                  borderColor: btnOutlineBorder,
                  textColor: isDark ? AppColors.white : AppColors.crucenoGreen,
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.howToPlay);
                  },
                )
                    .animate(delay: 850.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.2, end: 0),
                const SizedBox(height: 12),
                // Boton Configuracion
                _buildOutlinedButton(
                  label: AppStrings.settings,
                  icon: Icons.settings_rounded,
                  borderColor: btnOutlineBorder,
                  textColor: isDark ? AppColors.white : AppColors.crucenoGreen,
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.settings);
                  },
                )
                    .animate(delay: 1000.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.2, end: 0),
                const Spacer(flex: 3),
                // Version
                Text(
                  'v1.0.0',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: secondaryText.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOutlinedButton({
    required String label,
    required IconData icon,
    required Color borderColor,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor,
          side: BorderSide(color: borderColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDefaults.cardRadius),
          ),
        ),
      ),
    );
  }
}
