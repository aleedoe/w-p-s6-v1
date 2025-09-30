// lib/repositories/auth_repository.dart
import '../config/api_config.dart';
import '../models/auth_models.dart';
import '../services/api_client.dart';
import '../services/token_manager.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  // Login
  Future<AuthResponse> login(String email, String password) async {
    try {
      final loginRequest = LoginRequest(email: email, password: password);

      final response = await _apiClient.post(
        ApiConfig.loginEndpoint,
        body: loginRequest.toJson(),
      );

      final authResponse = AuthResponse.fromJson(response);

      // Save token and user data
      await TokenManager.saveAuthResponse(authResponse);

      // Set token in API client
      _apiClient.setAuthToken(authResponse.token);

      return authResponse;
    } catch (e) {
      if (e is ApiException) {
        throw e;
      }
      throw ApiException('Gagal melakukan login: ${e.toString()}');
    }
  }

  // Register
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String name,
    String? phone,
    String? address,
  }) async {
    try {
      final registerRequest = RegisterRequest(
        email: email,
        password: password,
        name: name,
        phone: phone,
        address: address,
      );

      final response = await _apiClient.post(
        ApiConfig.registerEndpoint,
        body: registerRequest.toJson(),
      );

      final authResponse = AuthResponse.fromJson(response);

      // Save token and user data
      await TokenManager.saveAuthResponse(authResponse);

      // Set token in API client
      _apiClient.setAuthToken(authResponse.token);

      return authResponse;
    } catch (e) {
      if (e is ApiException) {
        throw e;
      }
      throw ApiException('Gagal melakukan registrasi: ${e.toString()}');
    }
  }

  // Logout
  Future<bool> logout() async {
    try {
      // Try to call logout endpoint if available
      try {
        await _apiClient.post(ApiConfig.logoutEndpoint);
      } catch (_) {
        // Ignore error if logout endpoint doesn't exist
      }

      // Clear local token
      await TokenManager.clearToken();

      // Clear token from API client
      _apiClient.clearAuthToken();

      return true;
    } catch (e) {
      throw ApiException('Gagal melakukan logout: ${e.toString()}');
    }
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    try {
      return await TokenManager.getUser();
    } catch (e) {
      return null;
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      final hasToken = await TokenManager.hasToken();
      if (!hasToken) return false;

      final token = await TokenManager.getToken();
      if (token != null) {
        _apiClient.setAuthToken(token);
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // Refresh token if needed
  Future<void> refreshTokenIfNeeded() async {
    final token = await TokenManager.getToken();
    if (token != null) {
      _apiClient.setAuthToken(token);
    }
  }

  void dispose() {
    _apiClient.dispose();
  }
}
