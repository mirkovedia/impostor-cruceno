import 'dart:math';
import '../models/player.dart';
import '../models/game_config.dart';
import '../models/game_state.dart';

class GameService {
  final _random = Random();

  GameState startGame(GameConfig config) {
    assert(config.isValid, 'GameConfig inválido');
    if (config.selectedCategories.isEmpty) {
      throw StateError('Se requiere al menos una categoría');
    }
    final category = config.selectedCategories[
        _random.nextInt(config.selectedCategories.length)];
    if (category.words.isEmpty) {
      throw StateError('La categoría "${category.name}" no tiene palabras');
    }
    final word = category.words[_random.nextInt(category.words.length)];

    final players = <Player>[];
    for (var i = 0; i < config.playerNames.length; i++) {
      players.add(Player(name: config.playerNames[i], index: i));
    }

    final impostorIndices = <int>{};
    while (impostorIndices.length < config.impostorCount) {
      impostorIndices.add(_random.nextInt(players.length));
    }
    for (final idx in impostorIndices) {
      players[idx] = players[idx].copyWith(role: PlayerRole.impostor);
    }

    return GameState(
      players: players,
      selectedCategory: category,
      secretWord: word,
      roundTimeSeconds: config.roundTimeSeconds,
      phase: GamePhase.reveal,
      currentPlayerIndex: 0,
      currentRound: 1,
      totalRounds: config.numberOfRounds,
    );
  }

  GameState revealCurrentPlayer(GameState state) {
    final players = List<Player>.from(state.players);
    players[state.currentPlayerIndex] =
        players[state.currentPlayerIndex].copyWith(hasRevealed: true);
    return state.copyWith(players: players);
  }

  GameState nextPlayerReveal(GameState state) {
    final nextIndex = state.currentPlayerIndex + 1;
    if (nextIndex >= state.players.length) {
      return state.copyWith(
        phase: GamePhase.clues,
        currentPlayerIndex: 0,
        roundStartTime: DateTime.now(),
      );
    }
    return state.copyWith(currentPlayerIndex: nextIndex);
  }

  GameState nextPlayerClue(GameState state) {
    final players = List<Player>.from(state.players);
    players[state.currentPlayerIndex] =
        players[state.currentPlayerIndex].copyWith(hasGivenClue: true);
    final nextIndex = state.currentPlayerIndex + 1;
    if (nextIndex >= state.players.length) {
      return state.copyWith(
        players: players,
        currentPlayerIndex: 0,
      );
    }
    return state.copyWith(
      players: players,
      currentPlayerIndex: nextIndex,
    );
  }

  GameState endCluesRound(GameState state) {
    if (state.currentRound >= state.totalRounds) {
      // Última ronda completada, pasar a votación
      return state.copyWith(
        phase: GamePhase.voting,
        currentPlayerIndex: 0,
      );
    }
    // Avanzar a la siguiente ronda: resetear hasGivenClue
    final players = state.players
        .map((p) => p.copyWith(hasGivenClue: false))
        .toList();
    return state.copyWith(
      players: players,
      currentRound: state.currentRound + 1,
      currentPlayerIndex: 0,
      roundStartTime: DateTime.now(),
    );
  }

  GameState submitVote(GameState state, String votedPlayerId) {
    final players = List<Player>.from(state.players);
    players[state.currentPlayerIndex] =
        players[state.currentPlayerIndex].copyWith(votedForId: votedPlayerId);
    final nextIndex = state.currentPlayerIndex + 1;
    if (nextIndex >= state.players.length) {
      return state.copyWith(
        players: players,
        phase: GamePhase.result,
        currentPlayerIndex: 0,
      );
    }
    return state.copyWith(
      players: players,
      currentPlayerIndex: nextIndex,
    );
  }
}
