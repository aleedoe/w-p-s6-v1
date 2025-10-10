// lib/repositories/stock_out_repository.dart

import 'package:mobile/models/stock_out.dart';
import 'package:mobile/models/stock_out_detail.dart';
import '../services/api_client.dart';

class StockOutRepository {
  final ApiClient _apiClient;

  StockOutRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  // Fetch stock out list
  Future<StockOutResponse> fetchStockOuts({int? resellerId}) async {
    try {
      final endpoint = resellerId != null
          ? '/stockouts/$resellerId'
          : '/stockouts/1';

      final response = await _apiClient.get(endpoint);
      return StockOutResponse.fromJson(response);
    } catch (e) {
      throw ApiException('Gagal mengambil data stock out: ${e.toString()}');
    }
  }

  // Fetch stock out detail
  Future<StockOutDetailResponse> fetchStockOutDetail({
    required int resellerId,
    required int stockOutId,
  }) async {
    try {
      final endpoint = '/stockouts/$resellerId/$stockOutId';
      final response = await _apiClient.get(endpoint);
      return StockOutDetailResponse.fromJson(response);
    } catch (e) {
      throw ApiException('Gagal mengambil detail stock out: ${e.toString()}');
    }
  }

  // Search stock out by ID
  List<StockOut> searchStockOuts(List<StockOut> stockOuts, String query) {
    if (query.isEmpty) {
      return stockOuts;
    }

    return stockOuts.where((s) {
      return s.idStockOut.toString().contains(query);
    }).toList();
  }

  void dispose() {
    _apiClient.dispose();
  }
}
