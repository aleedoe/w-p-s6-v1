// lib/models/stock_out.dart

class StockOut {
  final int idStockOut;
  final String createdAt;
  final int totalProducts;
  final int totalQuantity;

  StockOut({
    required this.idStockOut,
    required this.createdAt,
    required this.totalProducts,
    required this.totalQuantity,
  });

  factory StockOut.fromJson(Map<String, dynamic> json) {
    return StockOut(
      idStockOut: json['id_stock_out'] ?? 0,
      createdAt: json['created_at'] ?? '',
      totalProducts: json['total_products'] ?? 0,
      totalQuantity: json['total_quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_stock_out': idStockOut,
      'created_at': createdAt,
      'total_products': totalProducts,
      'total_quantity': totalQuantity,
    };
  }
}

class StockOutResponse {
  final int idReseller;
  final List<StockOut> stockOuts;
  final int totalStockOuts;

  StockOutResponse({
    required this.idReseller,
    required this.stockOuts,
    required this.totalStockOuts,
  });

  factory StockOutResponse.fromJson(Map<String, dynamic> json) {
    return StockOutResponse(
      idReseller: json['id_reseller'] ?? 0,
      stockOuts:
          (json['stock_outs'] as List<dynamic>?)
              ?.map((item) => StockOut.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      totalStockOuts: json['total_stock_outs'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_reseller': idReseller,
      'stock_outs': stockOuts.map((s) => s.toJson()).toList(),
      'total_stock_outs': totalStockOuts,
    };
  }
}
