// lib/models/transaction_detail.dart

class TransactionDetailItem {
  final int idDetailTransaction;
  final int idProduct;
  final double price;
  final String productName;
  final int quantity;
  final double totalPrice;

  TransactionDetailItem({
    required this.idDetailTransaction,
    required this.idProduct,
    required this.price,
    required this.productName,
    required this.quantity,
    required this.totalPrice,
  });

  factory TransactionDetailItem.fromJson(Map<String, dynamic> json) {
    return TransactionDetailItem(
      idDetailTransaction: json['id_detail_transaction'] ?? 0,
      idProduct: json['id_product'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      productName: json['product_name'] ?? '',
      quantity: json['quantity'] ?? 0,
      totalPrice: (json['total_price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_detail_transaction': idDetailTransaction,
      'id_product': idProduct,
      'price': price,
      'product_name': productName,
      'quantity': quantity,
      'total_price': totalPrice,
    };
  }
}

class TransactionDetailResponse {
  final List<TransactionDetailItem> details;
  final int idReseller;
  final int idTransaction;
  final double totalPrice;
  final int totalProducts;
  final int totalQuantity;

  TransactionDetailResponse({
    required this.details,
    required this.idReseller,
    required this.idTransaction,
    required this.totalPrice,
    required this.totalProducts,
    required this.totalQuantity,
  });

  factory TransactionDetailResponse.fromJson(Map<String, dynamic> json) {
    return TransactionDetailResponse(
      details:
          (json['details'] as List<dynamic>?)
              ?.map(
                (item) => TransactionDetailItem.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
      idReseller: json['id_reseller'] ?? 0,
      idTransaction: json['id_transaction'] ?? 0,
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      totalProducts: json['total_products'] ?? 0,
      totalQuantity: json['total_quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'details': details.map((item) => item.toJson()).toList(),
      'id_reseller': idReseller,
      'id_transaction': idTransaction,
      'total_price': totalPrice,
      'total_products': totalProducts,
      'total_quantity': totalQuantity,
    };
  }
}
