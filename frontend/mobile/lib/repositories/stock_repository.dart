// lib/repositories/stock_repository.dart
import 'package:mobile/config/api_config.dart';
import 'package:mobile/models/stock_detail.dart';

import '../services/api_client.dart';

class StockRepository {
  final ApiClient _apiClient;

  StockRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  // Fetch stock data
  Future<StockResponse> fetchStock({int? resellerId}) async {
    try {
      final queryParams = <String, String>{};
      if (resellerId != null) {
        queryParams['reseller_id'] = resellerId.toString();
      }

      final response = await _apiClient.get(
        ApiConfig.stockEndpoint,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      return StockResponse.fromJson(response);
    } catch (e) {
      throw ApiException('Gagal mengambil data stok: ${e.toString()}');
    }
  }

  // Refresh stock data (same as fetch, but semantically different)
  Future<StockResponse> refreshStock({int? resellerId}) async {
    return fetchStock(resellerId: resellerId);
  }

  // Search stock by product name
  Future<List<StockDetail>> searchStock(String query, {int? resellerId}) async {
    try {
      final stockResponse = await fetchStock(resellerId: resellerId);

      if (query.isEmpty) {
        return stockResponse.details;
      }

      return stockResponse.details.where((product) {
        return product.productName.toLowerCase().contains(
              query.toLowerCase(),
            ) ||
            product.categoryName.toLowerCase().contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      throw ApiException('Gagal mencari produk: ${e.toString()}');
    }
  }

  void dispose() {
    _apiClient.dispose();
  }
}
