import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'config/env_config.dart';
import 'config/theme_config.dart';
import 'services/firebase_service.dart';
import 'views/splash/splash_screen.dart';

void main() async {
  // Ensure Flutter engine is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (.env)
  await EnvConfig.init();

  // Initialize Firebase, Firestore caching, RTDB persistence, and FCM permissions
  await FirebaseService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'मारू प्रजापत',
      // Default Locale set to Hindi
      locale: const Locale('hi', ''),
      supportedLocales: const [
        Locale('hi', ''), // Hindi
        Locale('en', ''), // English
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeConfig.lightTheme,
      home: const SplashScreen(),
    );
  }
}
