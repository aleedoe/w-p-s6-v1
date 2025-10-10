// lib/models/stock_out_detail.dart

class StockOutDetail {
  final int idDetailStockOut;
  final int idProduct;
  final String productName;
  final double price;
  final int quantity;
  final double totalHarga;

  StockOutDetail({
    required this.idDetailStockOut,
    required this.idProduct,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.totalHarga,
  });

  factory StockOutDetail.fromJson(Map<String, dynamic> json) {
    return StockOutDetail(
      idDetailStockOut: json['id_detail_stock_out'] ?? 0,
      idProduct: json['id_product'] ?? 0,
      productName: json['product_name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      totalHarga: (json['total_harga'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_detail_stock_out': idDetailStockOut,
      'id_product': idProduct,
      'product_name': productName,
      'price': price,
      'quantity': quantity,
      'total_harga': totalHarga,
    };
  }
}

class StockOutDetailResponse {
  final int idReseller;
  final int idStockOut;
  final String createdAt;
  final int totalProducts;
  final int totalQuantity;
  final double totalHargaSemua;
  final List<StockOutDetail> details;

  StockOutDetailResponse({
    required this.idReseller,
    required this.idStockOut,
    required this.createdAt,
    required this.totalProducts,
    required this.totalQuantity,
    required this.totalHargaSemua,
    required this.details,
  });

  factory StockOutDetailResponse.fromJson(Map<String, dynamic> json) {
    return StockOutDetailResponse(
      idReseller: json['id_reseller'] ?? 0,
      idStockOut: json['id_stock_out'] ?? 0,
      createdAt: json['created_at'] ?? '',
      totalProducts: json['total_products'] ?? 0,
      totalQuantity: json['total_quantity'] ?? 0,
      totalHargaSemua: (json['total_harga_semua'] ?? 0).toDouble(),
      details: (json['details'] as List<dynamic>?)
          ?.map((item) => StockOutDetail.fromJson(item as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_reseller': idReseller,
      'id_stock_out': idStockOut,
      'created_at': createdAt,
      'total_products': totalProducts,
      'total_quantity': totalQuantity,
      'total_harga_semua': totalHargaSemua,
      'details': details.map((d) => d.toJson()).toList(),
    };
  }
}