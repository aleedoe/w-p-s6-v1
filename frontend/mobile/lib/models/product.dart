// lib/models/product.dart

class Product {
  final int id;
  final String name;
  final String? itemCode;
  final String? itemSeries;
  final double price;
  final int quantity;

  Product({
    required this.id,
    required this.name,
    this.itemCode,
    this.itemSeries,
    required this.price,
    required this.quantity,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      itemCode: json['item_code'],
      itemSeries: json['item_series'],
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'item_code': itemCode,
      'item_series': itemSeries,
      'price': price,
      'quantity': quantity,
    };
  }
}

// Model untuk item di keranjang
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get totalPrice => product.price * quantity;

  Map<String, dynamic> toJson() {
    return {'id_product': product.id, 'quantity': quantity};
  }
}

// Model untuk request create transaction
class CreateTransactionRequest {
  final List<CartItem> details;

  CreateTransactionRequest({required this.details});

  Map<String, dynamic> toJson() {
    return {'details': details.map((item) => item.toJson()).toList()};
  }
}

// Model untuk response create transaction
class CreateTransactionResponse {
  final String message;
  final TransactionData transaction;

  CreateTransactionResponse({required this.message, required this.transaction});

  factory CreateTransactionResponse.fromJson(Map<String, dynamic> json) {
    return CreateTransactionResponse(
      message: json['message'] ?? '',
      transaction: TransactionData.fromJson(json['transaction'] ?? {}),
    );
  }
}

class TransactionData {
  final int idTransaction;
  final int idReseller;
  final String status;
  final double totalPrice;
  final int totalProducts;
  final List<TransactionDetailData> details;

  TransactionData({
    required this.idTransaction,
    required this.idReseller,
    required this.status,
    required this.totalPrice,
    required this.totalProducts,
    required this.details,
  });

  factory TransactionData.fromJson(Map<String, dynamic> json) {
    return TransactionData(
      idTransaction: json['id_transaction'] ?? 0,
      idReseller: json['id_reseller'] ?? 0,
      status: json['status'] ?? '',
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      totalProducts: json['total_products'] ?? 0,
      details:
          (json['details'] as List<dynamic>?)
              ?.map((item) => TransactionDetailData.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class TransactionDetailData {
  final int idProduct;
  final String productName;
  final double price;
  final int quantity;
  final double totalPrice;

  TransactionDetailData({
    required this.idProduct,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.totalPrice,
  });

  factory TransactionDetailData.fromJson(Map<String, dynamic> json) {
    return TransactionDetailData(
      idProduct: json['id_product'] ?? 0,
      productName: json['product_name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      totalPrice: (json['total_price'] ?? 0).toDouble(),
    );
  }
}
