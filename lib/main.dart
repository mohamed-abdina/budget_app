import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'screens/splash/splash_screen.dart';

final _navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SplashApp());
}

class SplashApp extends StatelessWidget {
  const SplashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFFB8862F),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFFB8862F),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: SplashScreen(
        onComplete: () {
          debugPrint('SPLASH: onComplete called, navigating to LedgerlineApp');
          _navigatorKey.currentState?.pushReplacement(
            MaterialPageRoute(
              builder: (_) => const ProviderScope(child: LedgerlineApp()),
            ),
          );
        },
      ),
    );
  }
}
