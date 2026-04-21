import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants.dart';

/// Botón reutilizable con variantes primario (fondo verde) y secundario (borde).
/// Soporta estados de carga, deshabilitado, e ícono opcional.
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isLoading;
  final IconData? icon;
  final bool isDisabled;
  final double? width;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isPrimary = true,
    this.isLoading = false,
    this.icon,
    this.isDisabled = false,
    this.width,
  });

  bool get _isEnabled => !isDisabled && !isLoading && onPressed != null;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 52,
      child: Opacity(
        opacity: _isEnabled ? 1.0 : 0.5,
        child: isPrimary
            ? _buildPrimaryButton()
            : _buildSecondaryButton(),
      ),
    )
        .animate()
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.0, 1.0),
          duration: 150.ms,
        );
  }

  /// Botón primario con fondo verde
  Widget _buildPrimaryButton() {
    return ElevatedButton(
      onPressed: _isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.green,
        foregroundColor: AppColors.white,
        disabledBackgroundColor: AppColors.green.withValues(alpha: 0.5),
        disabledForegroundColor: AppColors.white.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDefaults.cardRadius),
        ),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24),
      ),
      child: _buildContent(AppColors.white),
    );
  }

  /// Botón secundario con borde y fondo transparente
  Widget _buildSecondaryButton() {
    return OutlinedButton(
      onPressed: _isEnabled ? onPressed : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.white,
        side: BorderSide(
          color: _isEnabled
              ? AppColors.white
              : AppColors.white.withValues(alpha: 0.5),
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDefaults.cardRadius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24),
      ),
      child: _buildContent(AppColors.white),
    );
  }

  /// Contenido interno: indicador de carga, ícono opcional y texto
  Widget _buildContent(Color color) {
    if (isLoading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    final textWidget = Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );

    if (icon == null) return textWidget;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        textWidget,
      ],
    );
  }
}
