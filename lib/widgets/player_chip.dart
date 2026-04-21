import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants.dart';
import '../models/player.dart';

/// Chip que muestra el nombre de un jugador con avatar, estado de selección
/// y opcionalmente un badge con la cantidad de votos recibidos.
class PlayerChip extends StatelessWidget {
  final Player player;
  final bool isSelected;
  final VoidCallback? onTap;
  final int? voteCount;

  const PlayerChip({
    super.key,
    required this.player,
    this.isSelected = false,
    this.onTap,
    this.voteCount,
  });

  /// Colores asignados cíclicamente según el índice del jugador
  static const List<Color> _avatarColors = [
    Color(0xFF4CAF50),
    Color(0xFF2196F3),
    Color(0xFFFF9800),
    Color(0xFFE91E63),
    Color(0xFF9C27B0),
    Color(0xFF00BCD4),
    Color(0xFFFF5722),
    Color(0xFF3F51B5),
    Color(0xFF8BC34A),
    Color(0xFFFFC107),
    Color(0xFF795548),
    Color(0xFF607D8B),
  ];

  Color get _avatarColor =>
      _avatarColors[player.index % _avatarColors.length];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.gold.withValues(alpha: 0.15)
              : AppColors.grey,
          borderRadius: BorderRadius.circular(AppDefaults.cardRadius),
          border: Border.all(
            color: isSelected ? AppColors.gold : AppColors.greyLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAvatar(),
            const SizedBox(width: 8),
            _buildName(),
            if (voteCount != null && voteCount! > 0) ...[
              const SizedBox(width: 8),
              _buildVoteBadge(),
            ],
          ],
        ),
      ),
    );
  }

  /// Avatar circular con la inicial del jugador
  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 14,
      backgroundColor: _avatarColor,
      child: Text(
        player.name.isNotEmpty
            ? player.name[0].toUpperCase()
            : '?',
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
      ),
    );
  }

  /// Nombre del jugador
  Widget _buildName() {
    return Text(
      player.name,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        color: isSelected ? AppColors.gold : AppColors.white,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Badge pequeño que muestra la cantidad de votos
  Widget _buildVoteBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.red,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$voteCount',
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
      ),
    );
  }
}
