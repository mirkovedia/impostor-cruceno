import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/setup_screen.dart';
import '../screens/reveal_screen.dart';
import '../screens/clues_screen.dart';
import '../screens/voting_screen.dart';
import '../screens/result_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/how_to_play_screen.dart';
import '../screens/mode_select_screen.dart';
import '../screens/online_menu_screen.dart';
import '../screens/join_room_screen.dart';
import '../screens/lobby_screen.dart';
import '../screens/online_reveal_screen.dart';
import '../screens/online_clues_screen.dart';
import '../screens/online_voting_screen.dart';
import '../screens/online_result_screen.dart';

abstract class AppRoutes {
  static const home = '/';
  static const modeSelect = '/mode-select';
  static const setup = '/setup';
  static const reveal = '/reveal';
  static const clues = '/clues';
  static const voting = '/voting';
  static const result = '/result';
  static const settings = '/settings';
  static const howToPlay = '/how-to-play';
  // Online multiplayer
  static const onlineMenu = '/online-menu';
  static const joinRoom = '/join-room';
  static const lobby = '/lobby';
  static const onlineReveal = '/online-reveal';
  static const onlineClues = '/online-clues';
  static const onlineVoting = '/online-voting';
  static const onlineResult = '/online-result';

  static Map<String, WidgetBuilder> get routes => {
        home: (_) => const HomeScreen(),
        modeSelect: (_) => const ModeSelectScreen(),
        setup: (_) => const SetupScreen(),
        reveal: (_) => const RevealScreen(),
        clues: (_) => const CluesScreen(),
        voting: (_) => const VotingScreen(),
        result: (_) => const ResultScreen(),
        settings: (_) => const SettingsScreen(),
        howToPlay: (_) => const HowToPlayScreen(),
        onlineMenu: (_) => const OnlineMenuScreen(),
        joinRoom: (_) => const JoinRoomScreen(),
        lobby: (_) => const LobbyScreen(),
        onlineReveal: (_) => const OnlineRevealScreen(),
        onlineClues: (_) => const OnlineCluesScreen(),
        onlineVoting: (_) => const OnlineVotingScreen(),
        onlineResult: (_) => const OnlineResultScreen(),
      };

  static Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    return PageRouteBuilder(
      settings: routeSettings,
      pageBuilder: (context, animation, secondaryAnimation) {
        final builder = routes[routeSettings.name];
        if (builder != null) return builder(context);
        return const HomeScreen();
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
