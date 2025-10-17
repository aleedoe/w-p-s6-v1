// lib/models/report_models.dart

class ReportSummary {
  final int currentStock;
  final String sellThroughRate;
  final int totalItemsTaken;
  final int totalReturns;
  final int totalStockOut;
  final int totalTransactions;

  ReportSummary({
    required this.currentStock,
    required this.sellThroughRate,
    required this.totalItemsTaken,
    required this.totalReturns,
    required this.totalStockOut,
    required this.totalTransactions,
  });

  factory ReportSummary.fromJson(Map<String, dynamic> json) {
    return ReportSummary(
      currentStock: json['current_stock'] ?? 0,
      sellThroughRate: json['sell_through_rate']?.toString() ?? '0',
      totalItemsTaken: json['total_items_taken'] ?? 0,
      totalReturns: json['total_returns'] ?? 0,
      totalStockOut: json['total_stock_out'] ?? 0,
      totalTransactions: json['total_transactions'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_stock': currentStock,
      'sell_through_rate': sellThroughRate,
      'total_items_taken': totalItemsTaken,
      'total_returns': totalReturns,
      'total_stock_out': totalStockOut,
      'total_transactions': totalTransactions,
    };
  }
}

class ReportResponse {
  final int idReseller;
  final DateTime? lastStockOutDate;
  final DateTime? lastTransactionDate;
  final ReportSummary summary;

  ReportResponse({
    required this.idReseller,
    this.lastStockOutDate,
    this.lastTransactionDate,
    required this.summary,
  });

  factory ReportResponse.fromJson(Map<String, dynamic> json) {
    return ReportResponse(
      idReseller: json['id_reseller'] ?? 0,
      lastStockOutDate: json['last_stock_out_date'] != null
          ? DateTime.tryParse(json['last_stock_out_date'])
          : null,
      lastTransactionDate: json['last_transaction_date'] != null
          ? DateTime.tryParse(json['last_transaction_date'])
          : null,
      summary: ReportSummary.fromJson(json['summary'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_reseller': idReseller,
      'last_stock_out_date': lastStockOutDate?.toIso8601String(),
      'last_transaction_date': lastTransactionDate?.toIso8601String(),
      'summary': summary.toJson(),
    };
  }

  // Helper methods for formatting
  double get returnRate {
    if (summary.totalTransactions == 0) return 0.0;
    return (summary.totalReturns / summary.totalTransactions) * 100;
  }

  String get formattedReturnRate => '${returnRate.toStringAsFixed(1)}%';
}
