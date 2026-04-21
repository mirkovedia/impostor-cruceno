import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants.dart';
import '../models/category.dart';

/// Tarjeta de selección de categoría con ícono emoji, nombre,
/// conteo de palabras y estado seleccionado (borde verde + check).
class CategoryCard extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.category,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.green.withValues(alpha: 0.1)
              : AppColors.grey,
          borderRadius: BorderRadius.circular(AppDefaults.cardRadius),
          border: Border.all(
            color: isSelected ? AppColors.green : AppColors.greyLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            // Contenido principal de la tarjeta
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIcon(),
                const SizedBox(height: 10),
                _buildName(),
                const SizedBox(height: 4),
                _buildWordCount(),
              ],
            ),
            // Checkmark superpuesto cuando está seleccionado
            if (isSelected) _buildCheckOverlay(),
          ],
        ),
      ),
    );
  }

  /// Emoji grande de la categoría
  Widget _buildIcon() {
    return Text(
      category.icon,
      style: const TextStyle(fontSize: 36),
    );
  }

  /// Nombre de la categoría
  Widget _buildName() {
    return Text(
      category.name,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isSelected ? AppColors.green : AppColors.white,
      ),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Subtítulo con cantidad de palabras disponibles
  Widget _buildWordCount() {
    final count = category.words.length;
    return Text(
      '$count palabras',
      style: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.greyMedium,
      ),
    );
  }

  /// Ícono de check verde superpuesto en la esquina superior derecha
  Widget _buildCheckOverlay() {
    return Positioned(
      top: 0,
      right: 0,
      child: Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: AppColors.green,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check,
          size: 16,
          color: AppColors.white,
        ),
      ),
    );
  }
}
