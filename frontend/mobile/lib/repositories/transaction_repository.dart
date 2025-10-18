// lib/repositories/transaction_repository.dart
import 'package:mobile/models/transaction.dart';
import 'package:mobile/models/transaction_detail.dart';
import '../services/api_client.dart';

class TransactionRepository {
  final ApiClient _apiClient;

  TransactionRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  // Fetch transaction data
  Future<TransactionResponse> fetchTransactions({int? resellerId}) async {
    try {
      final endpoint = resellerId != null
          ? '/transactions/$resellerId'
          : '/transactions/1'; // Default resellerId

      final response = await _apiClient.get(endpoint);

      return TransactionResponse.fromJson(response);
    } catch (e) {
      throw ApiException('Gagal mengambil data transaksi: ${e.toString()}');
    }
  }

  // Fetch transaction detail
  Future<TransactionDetailResponse> fetchTransactionDetail({
    required int resellerId,
    required int transactionId,
  }) async {
    try {
      final endpoint = '/transactions/$resellerId/$transactionId';
      final response = await _apiClient.get(endpoint);

      return TransactionDetailResponse.fromJson(response);
    } catch (e) {
      throw ApiException('Gagal mengambil detail transaksi: ${e.toString()}');
    }
  }

  // Refresh transaction data
  Future<TransactionResponse> refreshTransactions({int? resellerId}) async {
    return fetchTransactions(resellerId: resellerId);
  }

  // Filter transactions by status
  List<Transaction> filterByStatus(
    List<Transaction> transactions,
    String? status,
  ) {
    if (status == null || status.isEmpty || status.toLowerCase() == 'semua') {
      return transactions;
    }

    return transactions.where((t) {
      return t.status.toLowerCase() == status.toLowerCase();
    }).toList();
  }

  // Search transactions by ID
  List<Transaction> searchTransactions(
    List<Transaction> transactions,
    String query,
  ) {
    if (query.isEmpty) {
      return transactions;
    }

    return transactions.where((t) {
      return t.idTransaction.toString().contains(query) ||
          t.status.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  void dispose() {
    _apiClient.dispose();
  }
}
