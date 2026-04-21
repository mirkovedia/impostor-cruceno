import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.appName,
              style: GoogleFonts.poppins(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: AppColors.green,
                letterSpacing: 2.0,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1.0, 1.0),
                  duration: 800.ms,
                  curve: Curves.elasticOut,
                ),
            const SizedBox(height: 24),
            Text(
              'Cargando...',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.greyMedium,
              ),
            ).animate(delay: 600.ms).fadeIn(duration: 400.ms),
          ],
        ),
      ),
    );
  }
}
