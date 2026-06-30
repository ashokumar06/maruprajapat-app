import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _currentUserModel;
  bool _isLoading = false;
  String? _error;

  User? get firebaseUser => _authService.currentUser;
  UserModel? get currentUserModel => _currentUserModel;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => firebaseUser != null;

  AuthProvider() {
    _authService.authStateChanges.listen((User? user) {
      if (user != null) {
        _fetchUserProfile();
      } else {
        _currentUserModel = null;
        notifyListeners();
      }
    });
  }

  Future<void> signInWithGoogle() async {
    _setLoading(true);
    try {
      await _authService.signInWithGoogle();
      // _fetchUserProfile will be called by the authStateChanges listener
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithEmailPassword(String email, String password) async {
    _setLoading(true);
    try {
      await _authService.signInWithEmailPassword(email: email, password: password);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signUpWithEmailPassword(String email, String password) async {
    _setLoading(true);
    try {
      await _authService.signUpWithEmailPassword(email: email, password: password);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInAnonymously() async {
    _setLoading(true);
    try {
      await _authService.signInAnonymously();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _fetchUserProfile() async {
    try {
      // Calling our FastAPI backend to get the user's profile
      final response = await ApiClient().dio.get('/api/v1/auth/me');
      if (response.statusCode == 200) {
        _currentUserModel = UserModel.fromJson(response.data, firebaseUser!.uid);
        _error = null;
      }
    } catch (e) {
      print('User not found on backend. Attempting registration... $e');
      // If the backend doesn't have the user yet, register them
      try {
        final registerResponse = await ApiClient().dio.post('/api/v1/auth/register', data: {
          'firebase_uid': firebaseUser!.uid,
          'email': firebaseUser!.email ?? '',
          'full_name': firebaseUser!.displayName ?? '',
          'phone': firebaseUser!.phoneNumber ?? '',
        });
        
        if (registerResponse.statusCode == 201 || registerResponse.statusCode == 200) {
          _currentUserModel = UserModel.fromJson(registerResponse.data, firebaseUser!.uid);
          _error = null;
        }
      } catch (regErr) {
        _error = 'Failed to load or register user profile.';
        print('Error registering profile: $regErr');
      }
    }
    notifyListeners();
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await ApiClient().dio.patch('/api/v1/auth/me', data: data);
      if (response.statusCode == 200) {
        _currentUserModel = UserModel.fromJson(response.data, firebaseUser!.uid);
        notifyListeners();
      } else {
        throw Exception('प्रोफाइल अपडेट करने में विफल');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }
}
