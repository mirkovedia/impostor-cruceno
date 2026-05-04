import 'player.dart';
import 'category.dart';

enum GamePhase { setup, reveal, clues, voting, result }

class GameState {
  final List<Player> players;
  final Category selectedCategory;
  final String secretWord;
  final int roundTimeSeconds;
  final GamePhase phase;
  final int currentPlayerIndex;
  final DateTime? roundStartTime;
  final int currentRound;
  final int totalRounds;

  const GameState({
    required this.players,
    required this.selectedCategory,
    required this.secretWord,
    required this.roundTimeSeconds,
    this.phase = GamePhase.reveal,
    this.currentPlayerIndex = 0,
    this.roundStartTime,
    this.currentRound = 1,
    this.totalRounds = 3,
  });

  List<Player> get impostors =>
      players.where((p) => p.isImpostor).toList();

  List<Player> get civilians =>
      players.where((p) => !p.isImpostor).toList();

  Player get currentPlayer => players[currentPlayerIndex];

  bool get allRevealed => players.every((p) => p.hasRevealed);

  bool get allRoundsCompleted => currentRound > totalRounds;

  Map<String, int> get voteResults {
    final results = <String, int>{};
    for (final player in players) {
      results[player.id] = 0;
    }
    for (final player in players) {
      if (player.votedForId != null) {
        results[player.votedForId!] = (results[player.votedForId!] ?? 0) + 1;
      }
    }
    return results;
  }

  String? get mostVotedPlayerId {
    final results = voteResults;
    if (results.isEmpty) return null;
    final maxVotes = results.values.reduce((a, b) => a > b ? a : b);
    if (maxVotes == 0) return null;
    return results.entries.where((e) => e.value == maxVotes).first.key;
  }

  bool get civiliansWin {
    final votedId = mostVotedPlayerId;
    if (votedId == null) return false;
    return players.any((p) => p.id == votedId && p.isImpostor);
  }

  GameState copyWith({
    List<Player>? players,
    Category? selectedCategory,
    String? secretWord,
    int? roundTimeSeconds,
    GamePhase? phase,
    int? currentPlayerIndex,
    DateTime? roundStartTime,
    int? currentRound,
    int? totalRounds,
  }) {
    return GameState(
      players: players ?? this.players,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      secretWord: secretWord ?? this.secretWord,
      roundTimeSeconds: roundTimeSeconds ?? this.roundTimeSeconds,
      phase: phase ?? this.phase,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      roundStartTime: roundStartTime ?? this.roundStartTime,
      currentRound: currentRound ?? this.currentRound,
      totalRounds: totalRounds ?? this.totalRounds,
    );
  }
}
