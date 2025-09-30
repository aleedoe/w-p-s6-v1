// lib/models/stock_detail.dart
class StockDetail {
  final String categoryName;
  final String description;
  final int idDetailTransaction;
  final int idProduct;
  final int idReseller;
  final List<String> images;
  final double price;
  final String productName;
  final int quantity;

  StockDetail({
    required this.categoryName,
    required this.description,
    required this.idDetailTransaction,
    required this.idProduct,
    required this.idReseller,
    required this.images,
    required this.price,
    required this.productName,
    required this.quantity,
  });

  factory StockDetail.fromJson(Map<String, dynamic> json) {
    return StockDetail(
      categoryName: json['category_name'] ?? '',
      description: json['description'] ?? '',
      idDetailTransaction: json['id_detail_transaction'] ?? 0,
      idProduct: json['id_product'] ?? 0,
      idReseller: json['id_reseller'] ?? 0,
      images: List<String>.from(json['images'] ?? []),
      price: (json['price'] ?? 0).toDouble(),
      productName: json['product_name'] ?? '',
      quantity: json['quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_name': categoryName,
      'description': description,
      'id_detail_transaction': idDetailTransaction,
      'id_product': idProduct,
      'id_reseller': idReseller,
      'images': images,
      'price': price,
      'product_name': productName,
      'quantity': quantity,
    };
  }
}

// lib/models/stock_response.dart
class StockResponse {
  final List<StockDetail> details;
  final int idReseller;
  final int totalProducts;
  final int totalQuantity;

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
      totalQuantity: json['total_quantity'] ?? 0,
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