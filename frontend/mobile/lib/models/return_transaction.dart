// lib/models/return_transaction.dart

class ReturnTransaction {
  final int idReturnTransaction;
  final int idTransaction;
  final String returnDate;
  final String status;
  final int totalQuantity;
  final String transactionDate;

  ReturnTransaction({
    required this.idReturnTransaction,
    required this.idTransaction,
    required this.returnDate,
    required this.status,
    required this.totalQuantity,
    required this.transactionDate,
  });

  factory ReturnTransaction.fromJson(Map<String, dynamic> json) {
    return ReturnTransaction(
      idReturnTransaction: json['id_return_transaction'] ?? 0,
      idTransaction: json['id_transaction'] ?? 0,
      returnDate: json['return_date'] ?? '',
      status: json['status'] ?? '',
      totalQuantity: json['total_quantity'] ?? 0,
      transactionDate: json['transaction_date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_return_transaction': idReturnTransaction,
      'id_transaction': idTransaction,
      'return_date': returnDate,
      'status': status,
      'total_quantity': totalQuantity,
      'transaction_date': transactionDate,
    };
  }

  // Helper method untuk mendapatkan label status
  String getStatusLabel() {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'Disetujui';
      case 'pending':
        return 'Menunggu';
      case 'processing':
        return 'Diproses';
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }
}

class ReturnTransactionResponse {
  final int idReseller;
  final List<ReturnTransaction> returnTransactions;

  ReturnTransactionResponse({
    required this.idReseller,
    required this.returnTransactions,
  });

  factory ReturnTransactionResponse.fromJson(Map<String, dynamic> json) {
    return ReturnTransactionResponse(
      idReseller: json['id_reseller'] ?? 0,
      returnTransactions:
          (json['return_transaction'] as List<dynamic>?)
              ?.map(
                (item) =>
                    ReturnTransaction.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_reseller': idReseller,
      'return_transaction': returnTransactions.map((t) => t.toJson()).toList(),
    };
  }

  // Helper method untuk statistik
  int get totalReturns => returnTransactions.length;

  int get approvedReturns => returnTransactions
      .where((t) => t.status.toLowerCase() == 'approved')
      .length;

  int get pendingReturns => returnTransactions
      .where((t) => t.status.toLowerCase() == 'pending')
      .length;

  int get rejectedReturns => returnTransactions
      .where((t) => t.status.toLowerCase() == 'rejected')
      .length;
}
