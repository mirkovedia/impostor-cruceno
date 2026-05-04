import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' hide Category;
import '../models/room.dart';
import '../models/category.dart';

class RoomService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _random = Random();

  static const _roomsCollection = 'rooms';
  static const _codeChars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  static const _codeLength = 6;

  CollectionReference<Map<String, dynamic>> get _rooms =>
      _firestore.collection(_roomsCollection);

  String _generateCode() {
    return List.generate(
      _codeLength,
      (_) => _codeChars[_random.nextInt(_codeChars.length)],
    ).join();
  }

  Future<Room> createRoom({
    required String hostName,
    required String deviceId,
    int roundTimeSeconds = 90,
    int impostorCount = 1,
    int totalRounds = 3,
  }) async {
    String code;
    DocumentSnapshot<Map<String, dynamic>> existing;

    // Generar codigo unico
    do {
      code = _generateCode();
      existing = await _rooms.doc(code).get();
    } while (existing.exists);

    final host = RoomPlayer(
      id: deviceId,
      name: hostName,
      index: 0,
      deviceId: deviceId,
      isHost: true,
    );

    final room = Room(
      code: code,
      hostDeviceId: deviceId,
      createdAt: DateTime.now(),
      players: [host],
      roundTimeSeconds: roundTimeSeconds,
      impostorCount: impostorCount,
      totalRounds: totalRounds,
    );

    await _rooms.doc(code).set(room.toMap());
    debugPrint('[RoomService] Sala creada: $code');
    return room;
  }

  Future<Room?> getRoom(String code) async {
    final doc = await _rooms.doc(code.toUpperCase()).get();
    if (!doc.exists || doc.data() == null) return null;
    return Room.fromMap(doc.data()!);
  }

  Stream<Room?> roomStream(String code) {
    return _rooms.doc(code.toUpperCase()).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return Room.fromMap(doc.data()!);
    });
  }

  Future<Room?> joinRoom({
    required String code,
    required String playerName,
    required String deviceId,
  }) async {
    final upperCode = code.toUpperCase();
    final ref = _rooms.doc(upperCode);

    return _firestore.runTransaction<Room?>((transaction) async {
      final doc = await transaction.get(ref);
      if (!doc.exists || doc.data() == null) return null;

      final room = Room.fromMap(doc.data()!);

      if (room.status != RoomStatus.waiting) return null;
      if (room.isFull) return null;

      // Ya esta en la sala
      final existingIndex =
          room.players.indexWhere((p) => p.deviceId == deviceId);
      if (existingIndex >= 0) return room;

      final newPlayer = RoomPlayer(
        id: deviceId,
        name: playerName,
        index: room.players.length,
        deviceId: deviceId,
      );

      final updatedPlayers = [...room.players, newPlayer];
      transaction.update(ref, {
        'players': updatedPlayers.map((p) => p.toMap()).toList(),
      });

      return Room.fromMap({
        ...doc.data()!,
        'players': updatedPlayers.map((p) => p.toMap()).toList(),
      });
    });
  }

  Future<void> leaveRoom({
    required String code,
    required String deviceId,
  }) async {
    final ref = _rooms.doc(code.toUpperCase());

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(ref);
      if (!doc.exists || doc.data() == null) return;

      final room = Room.fromMap(doc.data()!);
      final updatedPlayers =
          room.players.where((p) => p.deviceId != deviceId).toList();

      // Reindexar
      final reindexed = <RoomPlayer>[];
      for (var i = 0; i < updatedPlayers.length; i++) {
        reindexed.add(updatedPlayers[i].copyWith(index: i));
      }

      if (reindexed.isEmpty) {
        transaction.delete(ref);
        return;
      }

      // Si el host se fue, el siguiente es host
      final hasHost = reindexed.any((p) => p.isHost);
      final finalPlayers = hasHost
          ? reindexed
          : [
              RoomPlayer(
                id: reindexed[0].id,
                name: reindexed[0].name,
                index: 0,
                deviceId: reindexed[0].deviceId,
                isHost: true,
                role: reindexed[0].role,
                hasRevealed: reindexed[0].hasRevealed,
                hasGivenClue: reindexed[0].hasGivenClue,
                votedForId: reindexed[0].votedForId,
              ),
              ...reindexed.skip(1),
            ];

      transaction.update(ref, {
        'players': finalPlayers.map((p) => p.toMap()).toList(),
        if (!hasHost) 'hostDeviceId': finalPlayers[0].deviceId,
      });
    });
  }

  Future<void> startGame({
    required String code,
    required Category category,
  }) async {
    final ref = _rooms.doc(code.toUpperCase());

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(ref);
      if (!doc.exists || doc.data() == null) return;

      final room = Room.fromMap(doc.data()!);
      if (room.players.length < 3) return;
      if (category.words.isEmpty) return;

      final word = category.words[_random.nextInt(category.words.length)];

      // Asignar impostores (nunca más que players-1)
      final players = List<RoomPlayer>.from(room.players);
      final validImpostorCount = room.impostorCount.clamp(1, players.length - 1);
      final impostorIndices = <int>{};
      while (impostorIndices.length < validImpostorCount) {
        impostorIndices.add(_random.nextInt(players.length));
      }

      final updatedPlayers = <RoomPlayer>[];
      for (var i = 0; i < players.length; i++) {
        updatedPlayers.add(players[i].copyWith(
          role: impostorIndices.contains(i) ? 'impostor' : 'civilian',
        ));
      }

      transaction.update(ref, {
        'status': RoomStatus.playing.name,
        'phase': 'reveal',
        'selectedCategoryId': category.id,
        'selectedCategoryName': category.name,
        'selectedCategoryIcon': category.icon,
        'secretWord': word,
        'currentPlayerIndex': 0,
        'currentRound': 1,
        'players': updatedPlayers.map((p) => p.toMap()).toList(),
      });
    });
  }

  Future<void> updatePlayerRevealed({
    required String code,
    required String deviceId,
  }) async {
    final ref = _rooms.doc(code.toUpperCase());

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(ref);
      if (!doc.exists || doc.data() == null) return;

      final room = Room.fromMap(doc.data()!);
      final players = room.players.map((p) {
        if (p.deviceId == deviceId) {
          return p.copyWith(hasRevealed: true);
        }
        return p;
      }).toList();

      transaction.update(ref, {
        'players': players.map((p) => p.toMap()).toList(),
      });
    });
  }

  Future<void> advanceToNextPlayer({
    required String code,
  }) async {
    final ref = _rooms.doc(code.toUpperCase());

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(ref);
      if (!doc.exists || doc.data() == null) return;

      final room = Room.fromMap(doc.data()!);
      final nextIndex = room.currentPlayerIndex + 1;

      if (nextIndex >= room.players.length) {
        if (room.phase == 'reveal') {
          transaction.update(ref, {
            'phase': 'clues',
            'currentPlayerIndex': 0,
            'roundStartTime': Timestamp.now(),
          });
        } else if (room.phase == 'clues') {
          if (room.currentRound >= room.totalRounds) {
            transaction.update(ref, {
              'phase': 'voting',
              'currentPlayerIndex': 0,
            });
          } else {
            final resetPlayers = room.players
                .map((p) => p.copyWith(hasGivenClue: false))
                .toList();
            transaction.update(ref, {
              'currentRound': room.currentRound + 1,
              'currentPlayerIndex': 0,
              'roundStartTime': Timestamp.now(),
              'players': resetPlayers.map((p) => p.toMap()).toList(),
            });
          }
        }
      } else {
        transaction.update(ref, {'currentPlayerIndex': nextIndex});
      }
    });
  }

  Future<void> markClueGiven({
    required String code,
    required String deviceId,
  }) async {
    final ref = _rooms.doc(code.toUpperCase());

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(ref);
      if (!doc.exists || doc.data() == null) return;

      final room = Room.fromMap(doc.data()!);
      final players = room.players.map((p) {
        if (p.deviceId == deviceId) {
          return p.copyWith(hasGivenClue: true);
        }
        return p;
      }).toList();

      transaction.update(ref, {
        'players': players.map((p) => p.toMap()).toList(),
      });
    });
  }

  Future<void> submitVote({
    required String code,
    required String voterDeviceId,
    required String votedPlayerId,
  }) async {
    final ref = _rooms.doc(code.toUpperCase());

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(ref);
      if (!doc.exists || doc.data() == null) return;

      final room = Room.fromMap(doc.data()!);
      final players = room.players.map((p) {
        if (p.deviceId == voterDeviceId) {
          return p.copyWith(votedForId: votedPlayerId);
        }
        return p;
      }).toList();

      final allVoted = players.every((p) => p.votedForId != null);

      transaction.update(ref, {
        'players': players.map((p) => p.toMap()).toList(),
        if (allVoted) 'phase': 'result',
      });
    });
  }

  Future<void> endGame(String code) async {
    await _rooms.doc(code.toUpperCase()).update({
      'status': RoomStatus.finished.name,
      'phase': 'result',
    });
  }

  Future<void> deleteRoom(String code) async {
    await _rooms.doc(code.toUpperCase()).delete();
  }

  Future<void> cleanupOldRooms() async {
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));
    final query = await _rooms
        .where('createdAt', isLessThan: Timestamp.fromDate(cutoff))
        .get();

    final batch = _firestore.batch();
    for (final doc in query.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
    if (query.docs.isNotEmpty) {
      debugPrint('[RoomService] Limpieza: ${query.docs.length} salas eliminadas');
    }
  }
}
