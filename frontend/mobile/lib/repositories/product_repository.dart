// lib/repositories/product_repository.dart
import 'package:mobile/config/api_config.dart';
import 'package:mobile/models/product.dart';
import '../services/api_client.dart';

class ProductRepository {
  final ApiClient _apiClient;

  ProductRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  // Fetch all products
  Future<List<Product>> fetchProducts() async {
    try {
      final response = await _apiClient.get('/products');

      if (response is List) {
        return response
            .map((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      throw ApiException('Format response tidak valid');
    } catch (e) {
      throw ApiException('Gagal mengambil data produk: ${e.toString()}');
    }
  }

  // Create transaction
  Future<CreateTransactionResponse> createTransaction({
    required int resellerId,
    required CreateTransactionRequest request,
  }) async {
    try {
      final endpoint = '/transactions/$resellerId';
      final response = await _apiClient.post(endpoint, data: request.toJson());

      return CreateTransactionResponse.fromJson(response);
    } catch (e) {
      throw ApiException('Gagal membuat transaksi: ${e.toString()}');
    }
  }

  // Search products
  List<Product> searchProducts(List<Product> products, String query) {
    if (query.isEmpty) {
      return products;
    }

    return products.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase()) ||
          product.category.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Filter by category
  List<Product> filterByCategory(List<Product> products, String? category) {
    if (category == null || category.isEmpty || category == 'Semua') {
      return products;
    }

    return products.where((product) {
      return product.category == category;
    }).toList();
  }

  void dispose() {
    _apiClient.dispose();
  }
}
