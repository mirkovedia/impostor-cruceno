import 'category.dart';

class GameConfig {
  final List<String> playerNames;
  final List<Category> selectedCategories;
  final int impostorCount;
  final int roundTimeSeconds;
  final int numberOfRounds;

  const GameConfig({
    required this.playerNames,
    required this.selectedCategories,
    this.impostorCount = 1,
    this.roundTimeSeconds = 90,
    this.numberOfRounds = 3,
  });

  bool get isValid =>
      playerNames.length >= 3 &&
      playerNames.length <= 12 &&
      selectedCategories.isNotEmpty &&
      impostorCount >= 1 &&
      impostorCount <= 2 &&
      impostorCount < playerNames.length &&
      numberOfRounds >= 1 &&
      numberOfRounds <= 5;
}
