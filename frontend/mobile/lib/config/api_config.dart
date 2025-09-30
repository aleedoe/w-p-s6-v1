// lib/core/config/api_config.dart
class ApiConfig {
  static const String baseUrl = 'https://your-api-domain.com/api'; // Ganti dengan URL API Anda
  static const String stockEndpoint = '/stock'; // Endpoint untuk data stok
  
  // Timeout configuration
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Jika menggunakan authentication token
  static Map<String, String> getAuthHeaders(String? token) {
    return {
      ...headers,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}