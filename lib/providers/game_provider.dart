import 'package:flutter/foundation.dart' hide Category;
import '../core/constants.dart';
import '../models/category.dart';
import '../models/game_config.dart';
import '../models/game_state.dart';
import '../services/game_service.dart';
import '../services/words_repository.dart';
import '../services/storage_service.dart';
import '../services/audio_service.dart';
import '../services/haptic_service.dart';

class GameProvider extends ChangeNotifier {
  final GameService _gameService = GameService();
  final WordsRepository _wordsRepository = WordsRepository();
  final StorageService _storageService = StorageService();
  final AudioService _audioService = AudioService();
  final HapticService _hapticService = HapticService();

  bool _isInitialized = false;
  bool _hasLoadError = false;
  List<Category> _categories = [];
  GameState? _gameState;
  AppThemeType _themeType = AppThemeType.cruceno;
  bool _isSoundEnabled = true;
  bool _isVibrationEnabled = true;

  bool get isInitialized => _isInitialized;
  bool get hasLoadError => _hasLoadError;
  List<Category> get categories => _categories;
  GameState? get gameState => _gameState;
  AppThemeType get themeType => _themeType;
  bool get isDarkMode => _themeType == AppThemeType.dark;
  bool get isSoundEnabled => _isSoundEnabled;
  bool get isVibrationEnabled => _isVibrationEnabled;

  AudioService get audioService => _audioService;
  HapticService get hapticService => _hapticService;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      await _storageService.init();
      _themeType = _storageService.themeType;
      _isSoundEnabled = _storageService.isSoundEnabled;
      _isVibrationEnabled = _storageService.isVibrationEnabled;
    } catch (e) {
      debugPrint('[GameProvider] Error cargando preferencias: $e');
    }

    try {
      _categories = await _wordsRepository.loadCategories();
      debugPrint('[GameProvider] Categorías cargadas: ${_categories.length}');
      if (_categories.isEmpty) {
        _hasLoadError = true;
        debugPrint('[GameProvider] Advertencia: no se cargaron categorías');
      }
    } catch (e) {
      debugPrint('[GameProvider] Error cargando palabras: $e');
      _categories = [];
      _hasLoadError = true;
    }

    _audioService.enabled = _isSoundEnabled;
    _hapticService.enabled = _isVibrationEnabled;

    try {
      await _hapticService.init();
      await _audioService.preload();
    } catch (e) {
      debugPrint('[GameProvider] Error inicializando audio/haptic: $e');
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> playSound(GameSound sound) async {
    await _audioService.play(sound);
  }

  Future<void> triggerHaptic(HapticType type) async {
    await _hapticService.trigger(type);
  }

  void setThemeType(AppThemeType type) {
    _themeType = type;
    _storageService.themeType = type;
    notifyListeners();
  }

  void toggleDarkMode() {
    if (_themeType == AppThemeType.dark) {
      _themeType = AppThemeType.cruceno;
    } else {
      _themeType = AppThemeType.dark;
    }
    _storageService.themeType = _themeType;
    notifyListeners();
  }

  void toggleSound() {
    _isSoundEnabled = !_isSoundEnabled;
    _storageService.isSoundEnabled = _isSoundEnabled;
    _audioService.enabled = _isSoundEnabled;
    notifyListeners();
  }

  void toggleVibration() {
    _isVibrationEnabled = !_isVibrationEnabled;
    _storageService.isVibrationEnabled = _isVibrationEnabled;
    _hapticService.enabled = _isVibrationEnabled;
    notifyListeners();
  }

  int get defaultRoundTime => _storageService.defaultRoundTime;
  set defaultRoundTime(int value) {
    _storageService.defaultRoundTime = value;
    notifyListeners();
  }

  int get defaultImpostors => _storageService.defaultImpostors;
  set defaultImpostors(int value) {
    _storageService.defaultImpostors = value;
    notifyListeners();
  }

  void startGame(GameConfig config) {
    _gameState = _gameService.startGame(config);
    notifyListeners();
  }

  void revealCurrentPlayer() {
    if (_gameState == null) return;
    _gameState = _gameService.revealCurrentPlayer(_gameState!);
    notifyListeners();
  }

  void nextPlayerReveal() {
    if (_gameState == null) return;
    _gameState = _gameService.nextPlayerReveal(_gameState!);
    notifyListeners();
  }

  void nextPlayerClue() {
    if (_gameState == null) return;
    _gameState = _gameService.nextPlayerClue(_gameState!);
    notifyListeners();
  }

  bool endCluesRound() {
    if (_gameState == null) return false;
    final wasLastRound = _gameState!.currentRound >= _gameState!.totalRounds;
    _gameState = _gameService.endCluesRound(_gameState!);
    notifyListeners();
    return wasLastRound;
  }

  void submitVote(String votedPlayerId) {
    if (_gameState == null) return;
    _gameState = _gameService.submitVote(_gameState!, votedPlayerId);
    notifyListeners();
  }

  void resetGame() {
    _gameState = null;
    notifyListeners();
  }

  Future<void> resetSettings() async {
    await _storageService.resetAll();
    _themeType = AppThemeType.cruceno;
    _isSoundEnabled = true;
    _isVibrationEnabled = true;
    _audioService.enabled = true;
    _hapticService.enabled = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}
