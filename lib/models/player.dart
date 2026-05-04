import 'package:uuid/uuid.dart';

const _uuid = Uuid();

enum PlayerRole { civilian, impostor }

class Player {
  final String id;
  final String name;
  final int index;
  final PlayerRole role;
  final bool hasRevealed;
  final bool hasGivenClue;
  final String? votedForId;

  Player({
    String? id,
    required this.name,
    required this.index,
    this.role = PlayerRole.civilian,
    this.hasRevealed = false,
    this.hasGivenClue = false,
    this.votedForId,
  }) : id = id ?? _uuid.v4();

  bool get isImpostor => role == PlayerRole.impostor;

  Player copyWith({
    String? name,
    int? index,
    PlayerRole? role,
    bool? hasRevealed,
    bool? hasGivenClue,
    String? votedForId,
    bool clearVotedForId = false,
  }) {
    return Player(
      id: id,
      name: name ?? this.name,
      index: index ?? this.index,
      role: role ?? this.role,
      hasRevealed: hasRevealed ?? this.hasRevealed,
      hasGivenClue: hasGivenClue ?? this.hasGivenClue,
      votedForId: clearVotedForId ? null : (votedForId ?? this.votedForId),
    );
  }
}
