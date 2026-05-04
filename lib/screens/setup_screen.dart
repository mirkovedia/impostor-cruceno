import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants.dart';
import '../core/app_routes.dart';
import '../models/category.dart';
import '../models/game_config.dart';
import '../providers/game_provider.dart';
import '../widgets/category_card.dart';

/// Pantalla de configuracion de nueva partida.
class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final List<TextEditingController> _nameControllers = [];
  final Set<String> _selectedCategoryIds = {};
  int _impostorCount = 1;
  int _roundTime = AppDefaults.defaultRoundTime;
  int _numberOfRounds = AppDefaults.defaultRounds;

  static const List<Color> _playerColors = [
    Color(0xFF4CAF50), Color(0xFF2196F3), Color(0xFFFF9800),
    Color(0xFFE91E63), Color(0xFF9C27B0), Color(0xFF00BCD4),
    Color(0xFFFF5722), Color(0xFF3F51B5), Color(0xFF8BC34A),
    Color(0xFFFFC107), Color(0xFF795548), Color(0xFF607D8B),
  ];

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < AppDefaults.minPlayers; i++) {
      _nameControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    for (final c in _nameControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addPlayer() {
    if (_nameControllers.length >= AppDefaults.maxPlayers) return;
    setState(() => _nameControllers.add(TextEditingController()));
  }

  void _removePlayer() {
    if (_nameControllers.length <= AppDefaults.minPlayers) return;
    setState(() {
      _nameControllers.last.dispose();
      _nameControllers.removeLast();
      if (_nameControllers.length < 5) _impostorCount = 1;
    });
  }

  void _toggleCategory(String id) {
    setState(() {
      if (_selectedCategoryIds.contains(id)) {
        _selectedCategoryIds.remove(id);
      } else {
        _selectedCategoryIds.add(id);
      }
    });
  }

  void _selectAllCategories(List<Category> cats) {
    setState(() {
      if (_selectedCategoryIds.length == cats.length) {
        _selectedCategoryIds.clear();
      } else {
        _selectedCategoryIds.addAll(cats.map((c) => c.id));
      }
    });
  }

  bool get _isValid {
    final allFilled = _nameControllers.every((c) => c.text.trim().isNotEmpty);
    return allFilled &&
        _nameControllers.length >= AppDefaults.minPlayers &&
        _selectedCategoryIds.isNotEmpty;
  }

  void _startGame() {
    if (!_isValid) return;
    final provider = context.read<GameProvider>();
    final selected = provider.categories
        .where((c) => _selectedCategoryIds.contains(c.id)).toList();
    final config = GameConfig(
      playerNames: _nameControllers.map((c) => c.text.trim()).toList(),
      selectedCategories: selected,
      impostorCount: _impostorCount,
      roundTimeSeconds: _roundTime,
      numberOfRounds: _numberOfRounds,
    );
    provider.startGame(config);
    Navigator.pushReplacementNamed(context, AppRoutes.reveal);
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<GameProvider>().categories;
    return Scaffold(
      appBar: AppBar(
        title: Text('Nueva Partida',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(height: 2,
            color: AppColors.green.withValues(alpha: 0.3)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPlayersSection()
                .animate().fadeIn(duration: 400.ms)
                .slideY(begin: 0.1),
            const SizedBox(height: 28),
            _buildCategoriesSection(categories)
                .animate(delay: 200.ms)
                .fadeIn(duration: 400.ms),
            const SizedBox(height: 28),
            _buildAdvancedConfig()
                .animate(delay: 400.ms)
                .fadeIn(duration: 400.ms),
            const SizedBox(height: 32),
            _buildStartButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity, height: 56,
      child: ElevatedButton.icon(
        onPressed: _isValid ? _startGame : null,
        icon: const Icon(Icons.rocket_launch, size: 22),
        label: Text(AppStrings.startGame,
          style: GoogleFonts.poppins(
            fontSize: 17, fontWeight: FontWeight.w700,
            letterSpacing: 1.0)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green,
          foregroundColor: AppColors.white,
          disabledBackgroundColor:
              AppColors.green.withValues(alpha: 0.3),
          disabledForegroundColor:
              AppColors.white.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppDefaults.cardRadius)),
          elevation: 4,
          shadowColor: AppColors.green.withValues(alpha: 0.3),
        ),
      ),
    ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.2);
  }

  Widget _buildPlayersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text('${AppStrings.players} ',
            style: GoogleFonts.poppins(
              fontSize: 18, fontWeight: FontWeight.w600)),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12)),
            child: Text('${_nameControllers.length}',
              style: GoogleFonts.poppins(
                fontSize: 14, fontWeight: FontWeight.w700,
                color: AppColors.green)),
          ),
          const Spacer(),
          _buildCircularButton(
            icon: Icons.remove, color: AppColors.red,
            onPressed: _nameControllers.length >
                AppDefaults.minPlayers
                ? _removePlayer : null),
          const SizedBox(width: 8),
          _buildCircularButton(
            icon: Icons.add, color: AppColors.green,
            onPressed: _nameControllers.length <
                AppDefaults.maxPlayers
                ? _addPlayer : null),
        ]),
        const SizedBox(height: 4),
        Text('Minimo ${AppDefaults.minPlayers} jugadores',
          style: GoogleFonts.poppins(
            fontSize: 12, color: AppColors.greyMedium)),
        const SizedBox(height: 12),
        ...List.generate(_nameControllers.length, (i) {
          final color = _playerColors[i % _playerColors.length];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: TextField(
              controller: _nameControllers[i],
              style: GoogleFonts.poppins(fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Jugador ${i + 1}',
                hintStyle: GoogleFonts.poppins(
                  color: AppColors.greyMedium),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(
                    left: 12, right: 8),
                  child: CircleAvatar(
                    radius: 16, backgroundColor: color,
                    child: Text('${i + 1}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white))),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 52, minHeight: 32),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ).animate().fadeIn(
            delay: Duration(milliseconds: 50 * i));
        }),
      ],
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required Color color,
    VoidCallback? onPressed,
  }) {
    final isEnabled = onPressed != null;
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: isEnabled
              ? color.withValues(alpha: 0.15)
              : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: isEnabled ? color : AppColors.greyLight,
            width: 2),
        ),
        child: Icon(icon, size: 22,
          color: isEnabled ? color : AppColors.greyLight),
      ),
    );
  }

  Widget _buildCategoriesSection(List<Category> categories) {
    final allSel = categories.isNotEmpty &&
        _selectedCategoryIds.length == categories.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text(AppStrings.categories,
            style: GoogleFonts.poppins(
              fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: _selectedCategoryIds.isNotEmpty
                  ? AppColors.green.withValues(alpha: 0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _selectedCategoryIds.isNotEmpty
                    ? AppColors.green
                    : AppColors.greyLight)),
            child: Text('${_selectedCategoryIds.length} sel.',
              style: GoogleFonts.poppins(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: _selectedCategoryIds.isNotEmpty
                    ? AppColors.green
                    : AppColors.greyMedium)),
          ),
          const Spacer(),
          _buildSelectAllChip(allSel, categories),
        ]),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 12,
            mainAxisSpacing: 12, childAspectRatio: 1.1),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];
            return CategoryCard(
              category: cat,
              isSelected:
                  _selectedCategoryIds.contains(cat.id),
              onTap: () => _toggleCategory(cat.id));
          },
        ),
      ],
    );
  }

  Widget _buildSelectAllChip(
      bool allSel, List<Category> categories) {
    return GestureDetector(
      onTap: () => _selectAllCategories(categories),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: allSel
              ? AppColors.green.withValues(alpha: 0.15)
              : AppColors.grey,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: allSel
                ? AppColors.green
                : AppColors.greyLight)),
        child: Text(
          allSel ? 'Deseleccionar' : 'Seleccionar todas',
          style: GoogleFonts.poppins(
            fontSize: 12, fontWeight: FontWeight.w500,
            color: allSel
                ? AppColors.green : AppColors.white)),
      ),
    );
  }

  Widget _buildAdvancedConfig() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.grey,
        borderRadius: BorderRadius.circular(
          AppDefaults.cardRadius),
        border: Border.all(color: AppColors.greyLight)),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: 16),
          title: Text(AppStrings.advancedConfig,
            style: GoogleFonts.poppins(
              fontSize: 15, fontWeight: FontWeight.w500)),
          leading: const Icon(Icons.tune,
            color: AppColors.gold, size: 22),
          iconColor: AppColors.greyMedium,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                16, 0, 16, 16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Divider(
                    color: AppColors.greyLight),
                  const SizedBox(height: 8),
                  _buildImpostorSelector(),
                  const SizedBox(height: 20),
                  _buildTimeSlider(),
                  const SizedBox(height: 12),
                  _buildRoundsSlider(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImpostorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.impostorCount,
          style: GoogleFonts.poppins(
            fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        SegmentedButton<int>(
          segments: [
            const ButtonSegment(
              value: 1, label: Text('1')),
            ButtonSegment(value: 2,
              label: const Text('2'),
              enabled: _nameControllers.length >= 5),
          ],
          selected: {_impostorCount},
          onSelectionChanged: (v) =>
              setState(() => _impostorCount = v.first),
          style: ButtonStyle(
            backgroundColor:
                WidgetStateProperty.resolveWith((s) {
              if (s.contains(WidgetState.selected)) {
                return AppColors.green;
              }
              return AppColors.greyLight;
            })),
        ),
      ],
    );
  }

  Widget _buildTimeSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSliderLabel(AppStrings.roundTime,
          '$_roundTime s', AppColors.green),
        Slider(
          value: _roundTime.toDouble(),
          min: AppDefaults.minRoundTime.toDouble(),
          max: AppDefaults.maxRoundTime.toDouble(),
          divisions: 10,
          activeColor: AppColors.green,
          inactiveColor: AppColors.greyLight,
          label: '${_roundTime}s',
          onChanged: (v) =>
              setState(() => _roundTime = v.round())),
      ],
    );
  }

  Widget _buildRoundsSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSliderLabel(AppStrings.numberOfRounds,
          '$_numberOfRounds rondas', AppColors.gold),
        Slider(
          value: _numberOfRounds.toDouble(),
          min: AppDefaults.minRounds.toDouble(),
          max: AppDefaults.maxRounds.toDouble(),
          divisions: AppDefaults.maxRounds -
              AppDefaults.minRounds,
          activeColor: AppColors.gold,
          inactiveColor: AppColors.greyLight,
          label: '$_numberOfRounds rondas',
          onChanged: (v) => setState(
              () => _numberOfRounds = v.round())),
      ],
    );
  }

  Widget _buildSliderLabel(
      String label, String value, Color color) {
    return Row(children: [
      Text('$label: ', style: GoogleFonts.poppins(
        fontSize: 14, fontWeight: FontWeight.w500)),
      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8)),
        child: Text(value, style: GoogleFonts.poppins(
          fontSize: 14, fontWeight: FontWeight.w700,
          color: color)),
      ),
    ]);
  }
}
