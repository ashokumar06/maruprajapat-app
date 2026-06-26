import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../config/env_config.dart';

// Background message handler for Firebase Messaging
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
  }
}

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  late final FirebaseFirestore _firestore;
  late final FirebaseDatabase _realtimeDb;
  late final FirebaseMessaging _messaging;
  late final FirebaseAnalytics _analytics;

  Future<void> init() async {
    // 1. Initialize Firebase Core
    await Firebase.initializeApp();

    // 2. Initialize Analytics
    _analytics = FirebaseAnalytics.instance;

    // 3. Initialize Firestore with Offline Caching enabled to optimize reads (Spark Plan limits)
    _firestore = FirebaseFirestore.instance;
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    // 4. Initialize Realtime Database with Offline Persistence
    final dbUrl = EnvConfig.firebaseDatabaseUrl;
    if (dbUrl.isNotEmpty) {
      _realtimeDb = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: dbUrl,
      );
    } else {
      _realtimeDb = FirebaseDatabase.instance;
    }
    // Enable offline persistence for RTDB to save read operations
    _realtimeDb.setPersistenceEnabled(true);
    _realtimeDb.setPersistenceCacheSizeBytes(10000000); // 10MB cache

    // 5. Initialize Firebase Cloud Messaging (FCM)
    _messaging = FirebaseMessaging.instance;
    await _setupMessaging();
  }

  // Getters for service instances
  FirebaseFirestore get firestore => _firestore;
  FirebaseDatabase get realtimeDb => _realtimeDb;
  FirebaseMessaging get messaging => _messaging;
  FirebaseAnalytics get analytics => _analytics;

  // Setup FCM
  Future<void> _setupMessaging() async {
    // Set background messaging handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permissions for push notifications (compliant with Google Play guidelines)
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (kDebugMode) {
      print('User granted notification permission: ${settings.authorizationStatus}');
    }

    // Subscribe to common notification channels/topics
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      await _messaging.subscribeToTopic('all_members');
      await _messaging.subscribeToTopic('blood_requests');
    }

    // Listen for foreground notification events
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');
      }
    });
  }

  // Optimize Firestore reads with cache-first option
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocWithCache(
      String collection, String docId) async {
    try {
      // Attempt cache read first
      return await _firestore.collection(collection).doc(docId).get(
            const GetOptions(source: Source.cache),
          );
    } catch (_) {
      // Fallback to server if cache is empty or fails
      return await _firestore.collection(collection).doc(docId).get(
            const GetOptions(source: Source.server),
          );
    }
  }

  // Log Custom Analytics Events
  Future<void> logEvent(String name, Map<String, Object>? parameters) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }
}
