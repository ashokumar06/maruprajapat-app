---
name: Flutter Frontend Canvas
description: Best practices and guidelines for building premium, responsive frontend UIs in Flutter with Firebase integration.
---
# Flutter Frontend Canvas

Use this skill to design and build stunning, responsive, high-performance user interfaces in Flutter, integrated cleanly with Firebase.

## 1. Design & Aesthetics Guidelines

### Curated Color Palettes
Avoid using raw/default colors (e.g., `Colors.red`, `Colors.blue`). Instead, define a modern, harmonious color scheme using Tailwind-like custom HSL/RGB colors:

```dart
class AppColors {
  static const Color primary = Color(0xFF6366F1); // Indigo 500
  static const Color primaryDark = Color(0xFF4F46E5); // Indigo 600
  static const Color secondary = Color(0xFF10B981); // Emerald 500
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color border = Color(0xFFE2E8F0); // Slate 200
  static const Color error = Color(0xFFEF4444); // Red 500
}
```

### Premium UI Elements
- **Gradients**: Use smooth, subtle gradients on buttons, headers, or background cards to add depth.
- **Shadows**: Use soft, modern elevation shadows:
  ```dart
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ]
  ```
- **Borders & Corners**: Use rounded corners (`BorderRadius.circular(12)`) for buttons and containers.
- **Feedback & Loaders**: Use custom loading indicators (e.g. `CircularProgressIndicator` wrapped in a clean centered padding with custom color) instead of raw elements.

---

## 2. Firebase & Clean Architecture

Always decouple the presentation layer (Widgets) from data sources (Firebase). Implement a **Repository Pattern**:

### A. Authentication Repository / Service
Implement the Authentication Service to support Google Sign-In, Email & Password, and Anonymous Sign-In:

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // 1. Email & Password Sign Up (with verification email)
  Future<UserCredential> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await cred.user?.sendEmailVerification();
      return cred;
    } on FirebaseAuthException catch (e) {
      throw _handleError(e);
    }
  }

  // 2. Email & Password Sign In
  Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleError(e);
    }
  }

  // 3. Google Sign In
  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google sign in cancelled.');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleError(e);
    }
  }

  // 4. Anonymous Sign In
  Future<UserCredential> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  String _handleError(FirebaseAuthException e) {
    return e.message ?? 'Authentication error occurred.';
  }
}
```

### B. Firestore Repository & Type-Safe Models
Always use `.withConverter` to serialize/deserialize data to and from custom models:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;

  UserModel({required this.id, required this.name, required this.email});

  factory UserModel.fromJson(Map<String, dynamic> json, String id) {
    return UserModel(
      id: id,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
  };
}

class UserRepository {
  final CollectionReference<UserModel> _usersRef = FirebaseFirestore.instance
      .collection('users')
      .withConverter<UserModel>(
        fromFirestore: (snapshot, _) => UserModel.fromJson(snapshot.data()!, snapshot.id),
        toFirestore: (user, _) => user.toJson(),
      );

  Future<UserModel?> getUser(String userId) async {
    final doc = await _usersRef.doc(userId).get();
    return doc.data();
  }

  Future<void> createUser(UserModel user) async {
    await _usersRef.doc(user.id).set(user);
  }
}
```

---

## 3. Responsive State Management

- Use a consistent state management approach (e.g. `Provider` or `ChangeNotifier` pattern).
- Provide visual feedback for state changes (e.g., loading spinner during authentication / data fetching, clean error banners).
- Use `LayoutBuilder` for custom desktop vs. mobile layouts to ensure responsiveness.

---

## 4. Multi-language Localization (l10n)

To support both **Hindi (hi)** and **English (en)** languages in the application with **Hindi as the default locale**, follow these configuration patterns:

### A. Add Dependencies (pubspec.yaml)
Ensure `flutter_localizations` and `intl` are added under dependencies:
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: ^0.18.0
```

### B. Configure MaterialApp
Set the `locale`, `supportedLocales`, and `localizationsDelegates` in `main.dart` with Hindi (`hi`) as default:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maru Prajapat',
      // Set Default Locale to Hindi (hi)
      locale: const Locale('hi', ''), 
      supportedLocales: const [
        Locale('hi', ''), // Hindi (Default)
        Locale('en', ''), // English
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        // Add custom localization delegates here
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'मुख्य पृष्ठ'),
    );
  }
}
```

### C. Pure Hindi Translation Guidelines
When writing copy in Hindi, use standard and pure Hindi terms rather than simple transliterations of English.
- Use `मुख्य पृष्ठ` instead of `होम पेज` (Home Page).
- Use `लॉग इन करें` or `प्रवेश करें` instead of `साइन इन` (Sign In).
- Use `खाता बनाएं` instead of `रजिस्टर` (Register).
- Use `प्रोफ़ाइल` or `व्यक्तिगत विवरण` instead of `माय प्रोफाइल` (My Profile).
- Use `विकल्प` or `सेटिंग्स` instead of `ऑप्शन` (Settings/Option).
- Use `मिट्टी के बर्तन / हस्तकला` for craft references.
