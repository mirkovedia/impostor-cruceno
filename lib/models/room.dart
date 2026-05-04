import 'package:cloud_firestore/cloud_firestore.dart';

enum RoomStatus { waiting, playing, finished }

class RoomPlayer {
  final String id;
  final String name;
  final int index;
  final String deviceId;
  final bool isHost;
  final String role; // "civilian" | "impostor"
  final bool hasRevealed;
  final bool hasGivenClue;
  final String? votedForId;

  const RoomPlayer({
    required this.id,
    required this.name,
    required this.index,
    required this.deviceId,
    this.isHost = false,
    this.role = 'civilian',
    this.hasRevealed = false,
    this.hasGivenClue = false,
    this.votedForId,
  });

  bool get isImpostor => role == 'impostor';

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'index': index,
    'deviceId': deviceId,
    'isHost': isHost,
    'role': role,
    'hasRevealed': hasRevealed,
    'hasGivenClue': hasGivenClue,
    'votedForId': votedForId,
  };

  factory RoomPlayer.fromMap(Map<String, dynamic> map) => RoomPlayer(
    id: map['id'] as String,
    name: map['name'] as String,
    index: map['index'] as int,
    deviceId: map['deviceId'] as String,
    isHost: map['isHost'] as bool? ?? false,
    role: map['role'] as String? ?? 'civilian',
    hasRevealed: map['hasRevealed'] as bool? ?? false,
    hasGivenClue: map['hasGivenClue'] as bool? ?? false,
    votedForId: map['votedForId'] as String?,
  );

  RoomPlayer copyWith({
    String? name,
    int? index,
    String? role,
    bool? hasRevealed,
    bool? hasGivenClue,
    String? votedForId,
    bool clearVotedForId = false,
  }) => RoomPlayer(
    id: id,
    name: name ?? this.name,
    index: index ?? this.index,
    deviceId: deviceId,
    isHost: isHost,
    role: role ?? this.role,
    hasRevealed: hasRevealed ?? this.hasRevealed,
    hasGivenClue: hasGivenClue ?? this.hasGivenClue,
    votedForId: clearVotedForId ? null : (votedForId ?? this.votedForId),
  );
}

class Room {
  final String code;
  final String hostDeviceId;
  final RoomStatus status;
  final DateTime createdAt;
  final List<RoomPlayer> players;
  // Config
  final int roundTimeSeconds;
  final int impostorCount;
  final int totalRounds;
  // Game state
  final String? selectedCategoryId;
  final String? selectedCategoryName;
  final String? selectedCategoryIcon;
  final String? secretWord;
  final String phase; // "waiting" | "reveal" | "clues" | "voting" | "result"
  final int currentPlayerIndex;
  final int currentRound;
  final DateTime? roundStartTime;

  const Room({
    required this.code,
    required this.hostDeviceId,
    this.status = RoomStatus.waiting,
    required this.createdAt,
    this.players = const [],
    this.roundTimeSeconds = 90,
    this.impostorCount = 1,
    this.totalRounds = 3,
    this.selectedCategoryId,
    this.selectedCategoryName,
    this.selectedCategoryIcon,
    this.secretWord,
    this.phase = 'waiting',
    this.currentPlayerIndex = 0,
    this.currentRound = 1,
    this.roundStartTime,
  });

  RoomPlayer? get currentPlayer =>
      currentPlayerIndex < players.length ? players[currentPlayerIndex] : null;

  bool get isFull => players.length >= 12;

  Map<String, int> get voteResults {
    final results = <String, int>{};
    for (final p in players) {
      results[p.id] = 0;
    }
    for (final p in players) {
      if (p.votedForId != null) {
        results[p.votedForId!] = (results[p.votedForId!] ?? 0) + 1;
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

  List<RoomPlayer> get impostors =>
      players.where((p) => p.isImpostor).toList();

  Map<String, dynamic> toMap() => {
    'code': code,
    'hostDeviceId': hostDeviceId,
    'status': status.name,
    'createdAt': Timestamp.fromDate(createdAt),
    'players': players.map((p) => p.toMap()).toList(),
    'roundTimeSeconds': roundTimeSeconds,
    'impostorCount': impostorCount,
    'totalRounds': totalRounds,
    'selectedCategoryId': selectedCategoryId,
    'selectedCategoryName': selectedCategoryName,
    'selectedCategoryIcon': selectedCategoryIcon,
    'secretWord': secretWord,
    'phase': phase,
    'currentPlayerIndex': currentPlayerIndex,
    'currentRound': currentRound,
    'roundStartTime': roundStartTime != null
        ? Timestamp.fromDate(roundStartTime!) : null,
  };

  factory Room.fromMap(Map<String, dynamic> map) {
    final playersList = (map['players'] as List<dynamic>?)
        ?.map((p) => RoomPlayer.fromMap(p as Map<String, dynamic>))
        .toList() ?? [];

    return Room(
      code: map['code'] as String,
      hostDeviceId: map['hostDeviceId'] as String,
      status: RoomStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => RoomStatus.waiting,
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      players: playersList,
      roundTimeSeconds: map['roundTimeSeconds'] as int? ?? 90,
      impostorCount: map['impostorCount'] as int? ?? 1,
      totalRounds: map['totalRounds'] as int? ?? 3,
      selectedCategoryId: map['selectedCategoryId'] as String?,
      selectedCategoryName: map['selectedCategoryName'] as String?,
      selectedCategoryIcon: map['selectedCategoryIcon'] as String?,
      secretWord: map['secretWord'] as String?,
      phase: map['phase'] as String? ?? 'waiting',
      currentPlayerIndex: map['currentPlayerIndex'] as int? ?? 0,
      currentRound: map['currentRound'] as int? ?? 1,
      roundStartTime: (map['roundStartTime'] as Timestamp?)?.toDate(),
    );
  }
}
