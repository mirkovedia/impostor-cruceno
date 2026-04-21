import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'core/app_routes.dart';
import 'providers/game_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final provider = GameProvider();
  await provider.init();

  runApp(
    ChangeNotifierProvider.value(
      value: provider,
      child: const ImpostorCrucenoApp(),
    ),
  );
}

class ImpostorCrucenoApp extends StatefulWidget {
  const ImpostorCrucenoApp({super.key});

  @override
  State<ImpostorCrucenoApp> createState() => _ImpostorCrucenoAppState();
}

class _ImpostorCrucenoAppState extends State<ImpostorCrucenoApp> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showSplash = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.select<GameProvider, bool>((p) => p.isDarkMode);
    return MaterialApp(
      title: 'IMPOSTOR CRUCEÑO',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: _showSplash ? const SplashScreen() : const HomeScreen(),
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
