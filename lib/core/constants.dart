import 'package:flutter/material.dart';

abstract class AppColors {
  static const green = Color(0xFF009639);
  static const greenDark = Color(0xFF007A2E);
  static const greenLight = Color(0xFF00B844);
  static const white = Color(0xFFFFFFFF);
  static const red = Color(0xFFDA291C);
  static const redDark = Color(0xFFB01E15);
  static const gold = Color(0xFFFFD700);
  static const black = Color(0xFF1A1A1A);
  static const grey = Color(0xFF2A2A2A);
  static const greyLight = Color(0xFF3A3A3A);
  static const greyMedium = Color(0xFF666666);
  static const surface = Color(0xFF1E1E1E);
  static const surfaceLight = Color(0xFFF5F5F5);
  static const background = Color(0xFF121212);
  static const backgroundLight = Color(0xFFFFFFFF);
}

abstract class AppDefaults {
  static const int minPlayers = 3;
  static const int maxPlayers = 12;
  static const int defaultImpostors = 1;
  static const int maxImpostors = 2;
  static const int defaultRoundTime = 90;
  static const int minRoundTime = 30;
  static const int maxRoundTime = 180;
  static const int revealCountdown = 3;
  static const double cardRadius = 16.0;
  static const double cardRadiusLarge = 24.0;
  static const int defaultRounds = 3;
  static const int minRounds = 1;
  static const int maxRounds = 5;
}

abstract class AppStrings {
  static const appName = 'IMPOSTOR CRUCEÑO';
  static const subtitle = 'El impostor está entre nosotros, camba';
  static const play = 'JUGAR';
  static const howToPlay = 'Cómo jugar';
  static const settings = 'Configuración';
  static const players = 'Jugadores';
  static const categories = 'Categorías';
  static const advancedConfig = 'Configuración avanzada';
  static const impostorCount = 'Cantidad de impostores';
  static const roundTime = 'Tiempo de ronda';
  static const startGame = 'EMPEZAR PARTIDA';
  static const touchToReveal = 'TOCAR PARA VER';
  static const impostor = 'IMPOSTOR';
  static const impostorSubtitle = 'No conocés la palabra';
  static const readyNext = 'LISTO, PASAR AL SIGUIENTE';
  static const clueInstruction = 'Cada uno dice UNA sola palabra relacionada EN VOZ ALTA';
  static const nextPlayer = 'Siguiente jugador';
  static const endRound = 'Terminar ronda ahora';
  static const whoIsImpostor = '¿Quién creés que es el impostor?';
  static const revealResult = 'REVELAR RESULTADO';
  static const impostorWas = 'El impostor era...';
  static const civiliansWin = '¡GANARON LOS CIVILES!';
  static const impostorWins = '¡GANÓ EL IMPOSTOR!';
  static const playAgain = 'JUGAR DE NUEVO';
  static const mainMenu = 'MENÚ PRINCIPAL';
  static const darkMode = 'Modo oscuro';
  static const sound = 'Sonido';
  static const vibration = 'Vibración';
  static const resetSettings = 'Resetear configuración';
  static const about = 'Acerca de';
  static const turnOf = 'Turno de';
  static const seconds = 'segundos';
  static const numberOfRounds = 'Rondas de pistas';
  static const roundOf = 'Ronda';
}
