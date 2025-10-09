// lib/repositories/create_return_repository.dart
import '../models/create_return.dart';
import '../services/api_client.dart';

class CreateReturnRepository {
  final ApiClient _apiClient;

  CreateReturnRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  // Fetch completed transactions
  Future<CompletedTransactionResponse> fetchCompletedTransactions({
    required int resellerId,
  }) async {
    try {
      final endpoint = '/transactions/$resellerId/completed';
      final response = await _apiClient.get(endpoint);

      return CompletedTransactionResponse.fromJson(response);
    } catch (e) {
      throw ApiException(
        'Gagal mengambil data transaksi selesai: ${e.toString()}',
      );
    }
  }

  // Fetch transaction detail for return
  Future<TransactionDetailForReturn> fetchTransactionDetailForReturn({
    required int resellerId,
    required int transactionId,
  }) async {
    try {
      final endpoint = '/transactions/$resellerId/$transactionId';
      final response = await _apiClient.get(endpoint);

      return TransactionDetailForReturn.fromJson(response);
    } catch (e) {
      throw ApiException('Gagal mengambil detail transaksi: ${e.toString()}');
    }
  }

  // Create return transaction
  Future<CreateReturnResponse> createReturnTransaction({
    required int resellerId,
    required int transactionId,
    required CreateReturnRequest request,
  }) async {
    try {
      final endpoint = '/return-transactions/$resellerId/$transactionId';
      final response = await _apiClient.post(endpoint, body: request.toJson());

      return CreateReturnResponse.fromJson(response);
    } catch (e) {
      throw ApiException('Gagal membuat return: ${e.toString()}');
    }
  }

  // Refresh completed transactions
  Future<CompletedTransactionResponse> refreshCompletedTransactions({
    required int resellerId,
  }) async {
    return fetchCompletedTransactions(resellerId: resellerId);
  }

  // Search transactions
  List<CompletedTransaction> searchTransactions(
    List<CompletedTransaction> transactions,
    String query,
  ) {
    if (query.isEmpty) {
      return transactions;
    }

    return transactions.where((t) {
      return t.idTransaction.toString().contains(query);
    }).toList();
  }

  void dispose() {
    _apiClient.dispose();
  }
}
