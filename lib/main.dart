import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'views/news/post_detail_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.changeLocale(newLocale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const _channel = MethodChannel('com.avirastra.maruprajapat/deeplink');
  Locale _locale = const Locale('hi', '');

  void changeLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  void _initDeepLinks() async {
    // 1. Listen for warm starts / onNewIntent links
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onDeepLink') {
        final link = call.arguments as String?;
        if (link != null) {
          _handleDeepLink(link);
        }
      }
    });

    // 2. Check for cold start / initialLink
    try {
      final String? initialLink = await _channel.invokeMethod('getInitialLink');
      if (initialLink != null) {
        _handleDeepLink(initialLink);
      }
    } catch (e) {
      print('Failed to get initial deep link: $e');
    }
  }

  void _handleDeepLink(String link) {
    try {
      final uri = Uri.parse(link);
      if (uri.scheme == 'maruprajapat' && uri.host == 'posts') {
        final segments = uri.pathSegments;
        if (segments.isNotEmpty) {
          final postId = int.tryParse(segments.first);
          if (postId != null) {
            // Delay navigation slightly to ensure MaterialApp is mounted and Navigator is ready
            Future.delayed(const Duration(milliseconds: 1000), () {
              navigatorKey.currentState?.push(
                MaterialPageRoute(
                  builder: (_) => PostDetailScreen(postId: postId),
                ),
              );
            });
          }
        }
      }
    } catch (e) {
      print('Error parsing deep link: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'मारू प्रजापत',
      locale: _locale,
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
