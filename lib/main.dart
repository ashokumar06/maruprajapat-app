import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'config/env_config.dart';
import 'config/theme_config.dart';
import 'services/firebase_service.dart';
import 'providers/auth_provider.dart';
import 'providers/home_provider.dart';
import 'providers/explore_provider.dart';
import 'providers/forms_provider.dart';
import 'providers/news_provider.dart';
import 'providers/honours_provider.dart';
import 'providers/membership_provider.dart';
import 'views/splash/splash_screen.dart';
import 'views/auth/login_screen.dart';
import 'views/main/main_shell.dart';
void main() async {
  // Ensure Flutter engine is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (.env)
  await EnvConfig.init();

  // Initialize Firebase, Firestore caching, RTDB persistence, and FCM permissions
  await FirebaseService().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => ExploreProvider()),
        ChangeNotifierProvider(create: (_) => FormsProvider()),
        ChangeNotifierProvider(create: (_) => NewsProvider()),
        ChangeNotifierProvider(create: (_) => HonoursProvider()),
        ChangeNotifierProvider(create: (_) => MembershipProvider()),
      ],
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'मारू प्रजापत',
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
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.isAuthenticated) {
            return const MainShell();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
