// lib/repositories/stock_repository.dart
import 'package:mobile/config/api_config.dart';
import 'package:mobile/models/create_stockout.dart';
import '../services/api_client.dart';

class StockRepository {
  final ApiClient _apiClient;

  StockRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  // Fetch stocks for reseller
  Future<StockResponse> fetchStocks(int resellerId) async {
    try {
      final endpoint = '${ApiConfig.stocksEndpoint}/$resellerId';
      final response = await _apiClient.get(endpoint);

      return StockResponse.fromJson(response);
    } catch (e) {
      throw ApiException('Gagal mengambil data stok: ${e.toString()}');
    }
  }

  // Create stock out
  Future<CreateStockOutResponse> createStockOut({
    required int resellerId,
    required CreateStockOutRequest request,
  }) async {
    try {
      final endpoint = '${ApiConfig.stockOutEndpoint}/$resellerId';

      final response = await _apiClient.post(endpoint, body: request.toJson());

      return CreateStockOutResponse.fromJson(response);
    } catch (e) {
      throw ApiException('Gagal mencatat stok keluar: ${e.toString()}');
    }
  }

  // Search stocks
  List<StockItem> searchStocks(List<StockItem> stocks, String query) {
    if (query.isEmpty) {
      return stocks;
    }

    return stocks.where((stock) {
      return stock.productName.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  void dispose() {
    _apiClient.dispose();
  }
}
