// lib/config/api_config.dart

class ApiConfig {
  static const String baseUrl = 'http://127.0.0.1:5000/api/reseller';

  // Auth endpoints
  static const String loginEndpoint = '/login';
  static const String registerEndpoint = '/register';
  static const String logoutEndpoint = '/logout';

  // Stock endpoints
  static const String stockEndpoint = '/stocks/1';
  static const String stocksEndpoint = '/stocks'; // For fetching stock by reseller ID
  static const String stockOutEndpoint = '/stockouts'; // For creating stock out

  // Transaction endpoints
  static const String transactionEndpoint = '/transactions';

  // Product endpoints
  static const String productEndpoint = '/products';

  // Timeout configuration
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Headers
  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // If using authentication token
  static Map<String, String> getAuthHeaders(String? token) {
    return {
      ...headers,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}