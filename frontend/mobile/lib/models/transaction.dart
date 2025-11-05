// lib/models/transaction.dart

class Transaction {
  final String createdAt;
  final int idTransaction;
  final String status;
  final double totalPrice;
  final int totalProducts;

  Transaction({
    required this.createdAt,
    required this.idTransaction,
    required this.status,
    required this.totalPrice,
    required this.totalProducts,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      createdAt: json['created_at'] ?? '',
      idTransaction: json['id_transaction'] ?? 0,
      status: json['status'] ?? '',
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      totalProducts: json['total_products'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt,
      'id_transaction': idTransaction,
      'status': status,
      'total_price': totalPrice,
      'total_products': totalProducts,
    };
  }

  // Helper method untuk mendapatkan warna status
  String getStatusLabel() {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Selesai';
      case 'pending':
        return 'Menunggu';
      case 'processing':
        return 'Diproses';
      case 'cancelled':
        return 'Ditolak';
      default:
        return status;
    }
  }
}

class TransactionResponse {
  final int idReseller;
  final List<Transaction> transactions;

  TransactionResponse({required this.idReseller, required this.transactions});

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    return TransactionResponse(
      idReseller: json['id_reseller'] ?? 0,
      transactions:
          (json['transactions'] as List<dynamic>?)
              ?.map(
                (item) => Transaction.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_reseller': idReseller,
      'transactions': transactions.map((t) => t.toJson()).toList(),
    };
  }

  // Helper method untuk statistik
  int get totalTransactions => transactions.length;

  int get completedTransactions =>
      transactions.where((t) => t.status.toLowerCase() == 'completed').length;

  int get pendingTransactions =>
      transactions.where((t) => t.status.toLowerCase() == 'pending').length;

  double get totalRevenue => transactions
      .where((t) => t.status.toLowerCase() == 'completed')
      .fold(0.0, (sum, t) => sum + t.totalPrice);
}
