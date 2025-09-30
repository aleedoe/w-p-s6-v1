// lib/services/token_manager.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_models.dart';
import 'dart:convert';

class TokenManager {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _expiryKey = 'token_expiry';

  // Save token
  static Future<bool> saveToken(String token, {DateTime? expiryDate}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);

      if (expiryDate != null) {
        await prefs.setString(_expiryKey, expiryDate.toIso8601String());
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Get token
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);

      // Check if token is expired
      if (token != null && await isTokenExpired()) {
        await clearToken();
        return null;
      }

      return token;
    } catch (e) {
      return null;
    }
  }

  // Save user data
  static Future<bool> saveUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, json.encode(user.toJson()));
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get user data
  static Future<User?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);

      if (userJson != null) {
        return User.fromJson(json.decode(userJson));
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // Clear token and user data
  static Future<bool> clearToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      await prefs.remove(_expiryKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Check if token exists
  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Check if token is expired
  static Future<bool> isTokenExpired() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expiryString = prefs.getString(_expiryKey);

      if (expiryString == null) {
        return false; // No expiry set, assume valid
      }

      final expiryDate = DateTime.parse(expiryString);
      return DateTime.now().isAfter(expiryDate);
    } catch (e) {
      return false;
    }
  }

  // Save auth response (token + user)
  static Future<bool> saveAuthResponse(AuthResponse authResponse) async {
    try {
      await saveToken(authResponse.token);
      await saveUser(authResponse.user);
      return true;
    } catch (e) {
      return false;
    }
  }
}
