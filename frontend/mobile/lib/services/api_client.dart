// lib/services/api_client.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ApiClient {
  final http.Client _client;
  String? _authToken;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  // Set authentication token
  void setAuthToken(String token) {
    _authToken = token;
  }

  // Clear authentication token
  void clearAuthToken() {
    _authToken = null;
  }

  // GET Request
  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? queryParameters,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint')
          .replace(queryParameters: queryParameters);

      final response = await _client
          .get(
            uri,
            headers: ApiConfig.getAuthHeaders(_authToken),
          )
          .timeout(ApiConfig.connectionTimeout);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Tidak ada koneksi internet');
    } on TimeoutException {
      throw ApiException('Koneksi timeout');
    } catch (e) {
      throw ApiException('Terjadi kesalahan: ${e.toString()}');
    }
  }

  // POST Request
  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');

      final response = await _client
          .post(
            uri,
            headers: ApiConfig.getAuthHeaders(_authToken),
            body: body != null ? json.encode(body) : null,
          )
          .timeout(ApiConfig.connectionTimeout);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Tidak ada koneksi internet');
    } on TimeoutException {
      throw ApiException('Koneksi timeout');
    } catch (e) {
      throw ApiException('Terjadi kesalahan: ${e.toString()}');
    }
  }

  // PUT Request
  Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');

      final response = await _client
          .put(
            uri,
            headers: ApiConfig.getAuthHeaders(_authToken),
            body: body != null ? json.encode(body) : null,
          )
          .timeout(ApiConfig.connectionTimeout);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Tidak ada koneksi internet');
    } on TimeoutException {
      throw ApiException('Koneksi timeout');
    } catch (e) {
      throw ApiException('Terjadi kesalahan: ${e.toString()}');
    }
  }

  // DELETE Request
  Future<dynamic> delete(String endpoint) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');

      final response = await _client
          .delete(
            uri,
            headers: ApiConfig.getAuthHeaders(_authToken),
          )
          .timeout(ApiConfig.connectionTimeout);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Tidak ada koneksi internet');
    } on TimeoutException {
      throw ApiException('Koneksi timeout');
    } catch (e) {
      throw ApiException('Terjadi kesalahan: ${e.toString()}');
    }
  }

  // Handle Response
  dynamic _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        if (response.body.isEmpty) return null;
        return json.decode(response.body);
      case 400:
        throw ApiException('Bad request', response.statusCode);
      case 401:
        throw ApiException('Unauthorized - Token tidak valid', response.statusCode);
      case 403:
        throw ApiException('Forbidden - Akses ditolak', response.statusCode);
      case 404:
        throw ApiException('Data tidak ditemukan', response.statusCode);
      case 500:
        throw ApiException('Server error', response.statusCode);
      default:
        throw ApiException(
          'Error: ${response.statusCode}',
          response.statusCode,
        );
    }
  }

  // Dispose client
  void dispose() {
    _client.close();
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException([this.message = 'Connection timeout']);
}