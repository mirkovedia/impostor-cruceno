import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants.dart';

/// Tarjeta con animación de giro 3D para revelar la palabra secreta.
/// Muestra "TOCAR PARA VER" en el frente y la palabra o "IMPOSTOR" en el reverso.
class RevealCard extends StatefulWidget {
  final bool isImpostor;
  final String secretWord;
  final String categoryName;
  final bool isRevealed;
  final VoidCallback? onTap;

  const RevealCard({
    super.key,
    required this.isImpostor,
    required this.secretWord,
    required this.categoryName,
    this.isRevealed = false,
    this.onTap,
  });

  @override
  State<RevealCard> createState() => _RevealCardState();
}

class _RevealCardState extends State<RevealCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Si ya está revelada al construir, mostrar el reverso directamente
    if (widget.isRevealed) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(RevealCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRevealed && !oldWidget.isRevealed) {
      _controller.forward();
    } else if (!widget.isRevealed && oldWidget.isRevealed) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Maneja el toque: ejecuta la animación y notifica al padre
  void _handleTap() {
    if (widget.isRevealed) return;
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          // Ángulo de rotación en radianes (0 a pi)
          final angle = _animation.value * math.pi;
          // Determinar si mostrar el frente o el reverso
          final showFront = angle < math.pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Perspectiva 3D
              ..rotateY(angle),
            child: showFront
                ? _buildFront()
                : Transform(
                    alignment: Alignment.center,
                    // Espejamos el reverso para que el texto no se vea invertido
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _buildBack(),
                  ),
          );
        },
      ),
    );
  }

  /// Cara frontal: "TOCAR PARA VER" con ícono de pregunta
  Widget _buildFront() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.grey,
        borderRadius: BorderRadius.circular(AppDefaults.cardRadiusLarge),
        border: Border.all(color: AppColors.greyLight, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.help_outline_rounded,
            size: 64,
            color: AppColors.gold,
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.touchToReveal,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
              letterSpacing: 1.0,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Cara trasera: muestra "IMPOSTOR" o la palabra secreta según el rol
  Widget _buildBack() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: widget.isImpostor
            ? AppColors.red.withValues(alpha: 0.15)
            : AppColors.green.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDefaults.cardRadiusLarge),
        border: Border.all(
          color: widget.isImpostor ? AppColors.red : AppColors.green,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: widget.isImpostor
            ? _buildImpostorContent()
            : _buildCivilianContent(),
      ),
    );
  }

  /// Contenido para el impostor: texto rojo grande + subtítulo
  List<Widget> _buildImpostorContent() {
    return [
      Icon(
        Icons.warning_amber_rounded,
        size: 48,
        color: AppColors.red,
      ),
      const SizedBox(height: 12),
      Text(
        AppStrings.impostor,
        style: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: AppColors.red,
          letterSpacing: 2.0,
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 8),
      Text(
        AppStrings.impostorSubtitle,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.white.withValues(alpha: 0.7),
        ),
        textAlign: TextAlign.center,
      ),
    ];
  }

  /// Contenido para civiles: palabra secreta grande + nombre de categoría
  List<Widget> _buildCivilianContent() {
    return [
      Icon(
        Icons.visibility_rounded,
        size: 48,
        color: AppColors.green,
      ),
      const SizedBox(height: 12),
      Text(
        widget.secretWord,
        style: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: AppColors.white,
          letterSpacing: 1.0,
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 8),
      Text(
        widget.categoryName,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.gold,
        ),
        textAlign: TextAlign.center,
      ),
    ];
  }
}
