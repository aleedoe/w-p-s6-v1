class ApiConfig {
  static const String baseUrl = 'http://127.0.0.1:5000/api/reseller'; // Ganti dengan URL API Anda

  // Auth endpoints
  static const String loginEndpoint = '/login';
  static const String registerEndpoint = '/register';
  static const String logoutEndpoint = '/logout';

  // Stock (contoh resource lain)
  static const String stockEndpoint = '/stock';

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
