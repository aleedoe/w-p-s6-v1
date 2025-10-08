// lib/repositories/return_repository.dart
import 'package:mobile/models/return_transaction.dart';
import 'package:mobile/models/return_transaction_detail.dart';
import '../services/api_client.dart';

class ReturnRepository {
  final ApiClient _apiClient;

  ReturnRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  // Fetch return transaction data
  Future<ReturnTransactionResponse> fetchReturnTransactions({
    int? resellerId,
  }) async {
    try {
      final endpoint = resellerId != null
          ? '/return-transactions/$resellerId'
          : '/return-transactions/1'; // Default resellerId

      final response = await _apiClient.get(endpoint);

      return ReturnTransactionResponse.fromJson(response);
    } catch (e) {
      throw ApiException('Gagal mengambil data return: ${e.toString()}');
    }
  }

  // Fetch return transaction detail
  Future<ReturnDetailResponse> fetchReturnDetail({
    required int resellerId,
    required int returnTransactionId,
  }) async {
    try {
      final endpoint = '/return-transactions/$resellerId/$returnTransactionId';
      final response = await _apiClient.get(endpoint);

      return ReturnDetailResponse.fromJson(response);
    } catch (e) {
      throw ApiException('Gagal mengambil detail return: ${e.toString()}');
    }
  }

  // Refresh return transaction data
  Future<ReturnTransactionResponse> refreshReturnTransactions({
    int? resellerId,
  }) async {
    return fetchReturnTransactions(resellerId: resellerId);
  }

  // Filter returns by status
  List<ReturnTransaction> filterByStatus(
    List<ReturnTransaction> returns,
    String? status,
  ) {
    if (status == null || status.isEmpty || status.toLowerCase() == 'semua') {
      return returns;
    }

    return returns.where((r) {
      return r.status.toLowerCase() == status.toLowerCase();
    }).toList();
  }

  // Search returns by ID
  List<ReturnTransaction> searchReturns(
    List<ReturnTransaction> returns,
    String query,
  ) {
    if (query.isEmpty) {
      return returns;
    }

    return returns.where((r) {
      return r.idReturnTransaction.toString().contains(query) ||
          r.idTransaction.toString().contains(query) ||
          r.status.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  void dispose() {
    _apiClient.dispose();
  }
}
