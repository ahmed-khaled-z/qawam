import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global instance of AuthManager
late AuthManager authManager;

/// A class that manages user authentication state and data.
/// This class is generic and can work with any user model that can be
/// converted to/from JSON.
class AuthManager<T> extends ChangeNotifier {
  static const String _userKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';
  
  T? _currentUser;
  bool _isLoggedIn = false;
  
  /// Function to convert JSON Map to user model
  final T Function(Map<String, dynamic>)? fromJson;
  /// Function to convert user model to JSON Map
  final Map<String, dynamic> Function(T)? toJson;
  
  AuthManager({this.fromJson, this.toJson});
  
  /// Get the current user data
  T? get currentUser => _currentUser;
  
  /// Check if user is logged in
  bool get isLoggedIn => _isLoggedIn;
  
  /// Initialize the AuthManager and load saved user data
  static Future<AuthManager<T>> loadUser<T>({
    T Function(Map<String, dynamic>)? fromJson,
    Map<String, dynamic> Function(T)? toJson,
  }) async {
    final authManager = AuthManager<T>(fromJson: fromJson, toJson: toJson);
    await authManager._loadUserFromPrefs();
    return authManager;
  }
  
  /// Login user with provided user data
  Future<void> login(T userData) async {
    _currentUser = userData;
    _isLoggedIn = true;
    await _saveUserToPrefs();
    notifyListeners();
  }
  
  /// Logout user and clear all data
  Future<void> logout() async {
    _currentUser = null;
    _isLoggedIn = false;
    await _clearUserFromPrefs();
    notifyListeners();
  }
  
  /// Update current user data
  Future<void> updateUser(T userData) async {
    if (_isLoggedIn) {
      _currentUser = userData;
      await _saveUserToPrefs();
      notifyListeners();
    }
  }
  
  /// Load user data from SharedPreferences
  Future<void> _loadUserFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      
      if (_isLoggedIn) {
        final userDataString = prefs.getString(_userKey);
        if (userDataString != null && fromJson != null) {
          final userDataMap = jsonDecode(userDataString) as Map<String, dynamic>;
          _currentUser = fromJson!(userDataMap);
        } else if (userDataString != null) {
          // If no fromJson function provided, store as dynamic
          _currentUser = jsonDecode(userDataString) as T;
        }
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      await _clearUserFromPrefs();
    }
  }
  
  /// Save user data to SharedPreferences
  Future<void> _saveUserToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, _isLoggedIn);
      
      if (_currentUser != null) {
        String userDataString;
        if (toJson != null) {
          userDataString = jsonEncode(toJson!(_currentUser!));
        } else {
          userDataString = jsonEncode(_currentUser);
        }
        await prefs.setString(_userKey, userDataString);
      }
    } catch (e) {
      debugPrint('Error saving user data: $e');
    }
  }
  
  /// Clear user data from SharedPreferences
  Future<void> _clearUserFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.setBool(_isLoggedInKey, false);
    } catch (e) {
      debugPrint('Error clearing user data: $e');
    }
  }
}
