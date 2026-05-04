import 'dart:async';
import 'package:flutter/foundation.dart' hide Category;
import '../models/room.dart';
import '../models/category.dart';
import '../services/room_service.dart';
import '../services/storage_service.dart';

enum RoomConnectionState { disconnected, connecting, connected, error }

class RoomProvider extends ChangeNotifier {
  final RoomService _roomService = RoomService();
  final StorageService _storageService;

  Room? _room;
  StreamSubscription<Room?>? _roomSubscription;
  RoomConnectionState _connectionState = RoomConnectionState.disconnected;
  String? _errorMessage;

  RoomProvider(this._storageService);

  Room? get room => _room;
  RoomConnectionState get connectionState => _connectionState;
  String? get errorMessage => _errorMessage;
  String get deviceId => _storageService.deviceId;
  String get savedPlayerName => _storageService.playerName;

  bool get isHost => _room?.hostDeviceId == deviceId;
  bool get isInRoom => _room != null;
  bool get isPlaying => _room?.status == RoomStatus.playing;

  RoomPlayer? get myPlayer =>
      _room?.players.where((p) => p.deviceId == deviceId).firstOrNull;

  String? get myRole => myPlayer?.role;
  bool get amImpostor => myPlayer?.isImpostor ?? false;

  void savePlayerName(String name) {
    _storageService.playerName = name;
    notifyListeners();
  }

  Future<bool> createRoom({
    required String hostName,
    int? roundTimeSeconds,
    int? impostorCount,
    int? totalRounds,
  }) async {
    _connectionState = RoomConnectionState.connecting;
    _errorMessage = null;
    notifyListeners();

    try {
      savePlayerName(hostName);
      final room = await _roomService.createRoom(
        hostName: hostName,
        deviceId: deviceId,
        roundTimeSeconds: roundTimeSeconds ?? _storageService.defaultRoundTime,
        impostorCount: impostorCount ?? _storageService.defaultImpostors,
        totalRounds: totalRounds ?? 3,
      );
      _listenToRoom(room.code);
      return true;
    } catch (e) {
      _connectionState = RoomConnectionState.error;
      _errorMessage = 'Error creando sala: $e';
      debugPrint('[RoomProvider] $e');
      notifyListeners();
      return false;
    }
  }

  Future<bool> joinRoom({
    required String code,
    required String playerName,
  }) async {
    _connectionState = RoomConnectionState.connecting;
    _errorMessage = null;
    notifyListeners();

    try {
      savePlayerName(playerName);
      final room = await _roomService.joinRoom(
        code: code,
        playerName: playerName,
        deviceId: deviceId,
      );

      if (room == null) {
        _connectionState = RoomConnectionState.error;
        _errorMessage = 'Sala no encontrada o ya empezó la partida';
        notifyListeners();
        return false;
      }

      _listenToRoom(code);
      return true;
    } catch (e) {
      _connectionState = RoomConnectionState.error;
      _errorMessage = 'Error uniéndose a la sala: $e';
      debugPrint('[RoomProvider] $e');
      notifyListeners();
      return false;
    }
  }

  void _listenToRoom(String code) {
    _roomSubscription?.cancel();
    _roomSubscription = _roomService.roomStream(code).listen(
      (room) {
        _room = room;
        _connectionState = room != null
            ? RoomConnectionState.connected
            : RoomConnectionState.disconnected;
        notifyListeners();
      },
      onError: (e) {
        _connectionState = RoomConnectionState.error;
        _errorMessage = 'Conexión perdida: $e';
        debugPrint('[RoomProvider] Stream error: $e');
        notifyListeners();
      },
    );
  }

  Future<void> leaveRoom() async {
    if (_room == null) return;
    final code = _room!.code;
    _roomSubscription?.cancel();
    _roomSubscription = null;
    _room = null;
    _connectionState = RoomConnectionState.disconnected;
    notifyListeners();

    try {
      await _roomService.leaveRoom(code: code, deviceId: deviceId);
    } catch (e) {
      debugPrint('[RoomProvider] Error saliendo de sala: $e');
    }
  }

  Future<void> startGame(Category category) async {
    if (_room == null || !isHost) return;
    try {
      await _roomService.startGame(
        code: _room!.code,
        category: category,
      );
    } catch (e) {
      _errorMessage = 'Error iniciando partida: $e';
      debugPrint('[RoomProvider] $e');
      notifyListeners();
    }
  }

  Future<void> markRevealed() async {
    if (_room == null) return;
    try {
      await _roomService.updatePlayerRevealed(
        code: _room!.code,
        deviceId: deviceId,
      );
    } catch (e) {
      debugPrint('[RoomProvider] Error marcando revelado: $e');
    }
  }

  Future<void> advancePlayer() async {
    if (_room == null) return;
    try {
      await _roomService.advanceToNextPlayer(code: _room!.code);
    } catch (e) {
      debugPrint('[RoomProvider] Error avanzando jugador: $e');
    }
  }

  Future<void> markClueGiven() async {
    if (_room == null) return;
    try {
      await _roomService.markClueGiven(
        code: _room!.code,
        deviceId: deviceId,
      );
    } catch (e) {
      debugPrint('[RoomProvider] Error marcando pista: $e');
    }
  }

  Future<void> submitVote(String votedPlayerId) async {
    if (_room == null) return;
    try {
      await _roomService.submitVote(
        code: _room!.code,
        voterDeviceId: deviceId,
        votedPlayerId: votedPlayerId,
      );
    } catch (e) {
      debugPrint('[RoomProvider] Error votando: $e');
    }
  }

  Future<void> endGame() async {
    if (_room == null) return;
    try {
      await _roomService.endGame(_room!.code);
    } catch (e) {
      debugPrint('[RoomProvider] Error terminando partida: $e');
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _roomSubscription?.cancel();
    super.dispose();
  }
}
