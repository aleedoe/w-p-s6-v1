// lib/models/stock_detail.dart
class StockDetail {
  final int currentStock;
  final String description;
  final int idProduct;
  final List<String> images;
  final double price;
  final String productName;
  final int totalIn;
  final int totalOut;

  StockDetail({
    required this.currentStock,
    required this.description,
    required this.idProduct,
    required this.images,
    required this.price,
    required this.productName,
    required this.totalIn,
    required this.totalOut,
  });

  factory StockDetail.fromJson(Map<String, dynamic> json) {
    return StockDetail(
      currentStock: json['current_stock'] ?? 0,
      description: json['description'] ?? '',
      idProduct: json['id_product'] ?? 0,
      images: List<String>.from(json['images'] ?? []),
      price: (json['price'] ?? 0).toDouble(),
      productName: json['product_name'] ?? '',
      totalIn: json['total_in'] ?? 0,
      totalOut: json['total_out'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_stock': currentStock,
      'description': description,
      'id_product': idProduct,
      'images': images,
      'price': price,
      'product_name': productName,
      'total_in': totalIn,
      'total_out': totalOut,
    };
  }
}

// lib/models/stock_response.dart
class StockResponse {
  final List<StockDetail> details;
  final int idReseller;
  final int totalProducts;
  final String totalQuantity;

  StockResponse({
    required this.details,
    required this.idReseller,
    required this.totalProducts,
    required this.totalQuantity,
  });

  factory StockResponse.fromJson(Map<String, dynamic> json) {
    return StockResponse(
      details: (json['details'] as List<dynamic>?)
              ?.map((item) => StockDetail.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      idReseller: json['id_reseller'] ?? 0,
      totalProducts: json['total_products'] ?? 0,
      totalQuantity: json['total_quantity']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'details': details.map((detail) => detail.toJson()).toList(),
      'id_reseller': idReseller,
      'total_products': totalProducts,
      'total_quantity': totalQuantity,
    };
  }
}