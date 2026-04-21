import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants.dart';
import '../core/app_routes.dart';

/// Pantalla principal del juego con diseño dramático y festivo.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A2E14),
              Color(0xFF0D1F0D),
              AppColors.background,
              Color(0xFF1A0A0A),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Spacer(flex: 2),
                // Emoji decorativo
                const Text('🕵️', style: TextStyle(fontSize: 56))
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .scale(
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1.0, 1.0),
                      duration: 600.ms,
                      curve: Curves.elasticOut,
                    ),
                const SizedBox(height: 16),
                // Título principal con brillo dorado
                Text(
                  AppStrings.appName,
                  style: GoogleFonts.poppins(
                    fontSize: 46,
                    fontWeight: FontWeight.w900,
                    color: AppColors.green,
                    letterSpacing: 2.0,
                    height: 1.1,
                    shadows: [
                      const Shadow(
                        color: AppColors.gold,
                        blurRadius: 20,
                        offset: Offset(0, 2),
                      ),
                      Shadow(
                        color: AppColors.green.withValues(alpha: 0.4),
                        blurRadius: 40,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(duration: 700.ms)
                    .slideY(begin: -0.3, end: 0, duration: 700.ms),
                const SizedBox(height: 12),
                // Subtítulo en itálica
                Text(
                  AppStrings.subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: AppColors.greyMedium,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate(delay: 400.ms)
                    .fadeIn(duration: 500.ms),
                const SizedBox(height: 24),
                // Línea decorativa dorada
                Container(
                  width: 80,
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.gold.withValues(alpha: 0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                )
                    .animate(delay: 600.ms)
                    .fadeIn(duration: 500.ms)
                    .scaleX(begin: 0.0, end: 1.0, duration: 600.ms),
                const Spacer(flex: 2),
                // Botón JUGAR grande con shimmer
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
                      backgroundColor: AppColors.green,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDefaults.cardRadius,
                        ),
                      ),
                      elevation: 8,
                      shadowColor: AppColors.green.withValues(alpha: 0.4),
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
                // Botón Cómo jugar
                _buildOutlinedButton(
                  label: AppStrings.howToPlay,
                  icon: Icons.help_outline_rounded,
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.howToPlay);
                  },
                )
                    .animate(delay: 850.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.2, end: 0),
                const SizedBox(height: 12),
                // Botón Configuración
                _buildOutlinedButton(
                  label: AppStrings.settings,
                  icon: Icons.settings_rounded,
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.settings);
                  },
                )
                    .animate(delay: 1000.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.2, end: 0),
                const Spacer(flex: 3),
                // Versión
                Text(
                  'v1.0.0',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.greyMedium.withValues(alpha: 0.5),
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

  /// Botón delineado reutilizable para opciones secundarias
  Widget _buildOutlinedButton({
    required String label,
    required IconData icon,
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
          foregroundColor: AppColors.white,
          side: BorderSide(
            color: AppColors.white.withValues(alpha: 0.3),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDefaults.cardRadius),
          ),
        ),
      ),
    );
  }
}
