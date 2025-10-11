// lib/models/stock.dart

class StockItem {
  final String categoryName;
  final int currentStock;
  final String description;
  final int idProduct;
  final List<String> images;
  final double price;
  final String productName;
  final int totalIn;
  final int totalOut;

  StockItem({
    required this.categoryName,
    required this.currentStock,
    required this.description,
    required this.idProduct,
    required this.images,
    required this.price,
    required this.productName,
    required this.totalIn,
    required this.totalOut,
  });

  factory StockItem.fromJson(Map<String, dynamic> json) {
    return StockItem(
      categoryName: json['category_name'] ?? '',
      currentStock: json['current_stock'] ?? 0,
      description: json['description'] ?? '',
      idProduct: json['id_product'] ?? 0,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      price: (json['price'] ?? 0).toDouble(),
      productName: json['product_name'] ?? '',
      totalIn: json['total_in'] ?? 0,
      totalOut: json['total_out'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_name': categoryName,
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

class StockResponse {
  final List<StockItem> details;
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
              ?.map((item) => StockItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      idReseller: json['id_reseller'] ?? 0,
      totalProducts: json['total_products'] ?? 0,
      totalQuantity: json['total_quantity']?.toString() ?? '0',
    );
  }
}

// Model untuk item di cart stock out
class StockOutCartItem {
  final StockItem stock;
  int quantity;

  StockOutCartItem({required this.stock, this.quantity = 1});

  Map<String, dynamic> toJson() {
    return {
      'id_product': stock.idProduct,
      'quantity': quantity,
    };
  }
}

// Model untuk request create stock out
class CreateStockOutRequest {
  final List<StockOutCartItem> details;

  CreateStockOutRequest({required this.details});

  Map<String, dynamic> toJson() {
    return {
      'details': details.map((item) => item.toJson()).toList(),
    };
  }
}

// Model untuk response create stock out
class CreateStockOutResponse {
  final String message;
  final int idStockOut;

  CreateStockOutResponse({
    required this.message,
    required this.idStockOut,
  });

  factory CreateStockOutResponse.fromJson(Map<String, dynamic> json) {
    return CreateStockOutResponse(
      message: json['message'] ?? '',
      idStockOut: json['id_stock_out'] ?? 0,
    );
  }
}