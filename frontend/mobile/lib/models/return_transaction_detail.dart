// lib/models/return_transaction_detail.dart

class ReturnDetailItem {
  final int idReturnDetailTransaction;
  final int idProduct;
  final String productName;
  final double price;
  final int quantity;
  final String reason;
  final double totalPrice;

  ReturnDetailItem({
    required this.idReturnDetailTransaction,
    required this.idProduct,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.reason,
    required this.totalPrice,
  });

  factory ReturnDetailItem.fromJson(Map<String, dynamic> json) {
    return ReturnDetailItem(
      idReturnDetailTransaction: json['id_return_detail_transaction'] ?? 0,
      idProduct: json['id_product'] ?? 0,
      productName: json['product_name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      reason: json['reason'] ?? '',
      totalPrice: (json['total_price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_return_detail_transaction': idReturnDetailTransaction,
      'id_product': idProduct,
      'product_name': productName,
      'price': price,
      'quantity': quantity,
      'reason': reason,
      'total_price': totalPrice,
    };
  }
}

class ReturnDetailResponse {
  final int idReseller;
  final int idReturnTransaction;
  final List<ReturnDetailItem> details;
  final int totalProducts;
  final int totalQuantity;
  final double totalPrice;

  ReturnDetailResponse({
    required this.idReseller,
    required this.idReturnTransaction,
    required this.details,
    required this.totalProducts,
    required this.totalQuantity,
    required this.totalPrice,
  });

  factory ReturnDetailResponse.fromJson(Map<String, dynamic> json) {
    return ReturnDetailResponse(
      idReseller: json['id_reseller'] ?? 0,
      idReturnTransaction: json['id_return_transaction'] ?? 0,
      details:
          (json['details'] as List<dynamic>?)
              ?.map(
                (item) =>
                    ReturnDetailItem.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      totalProducts: json['total_products'] ?? 0,
      totalQuantity: json['total_quantity'] ?? 0,
      totalPrice: (json['total_price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_reseller': idReseller,
      'id_return_transaction': idReturnTransaction,
      'details': details.map((item) => item.toJson()).toList(),
      'total_products': totalProducts,
      'total_quantity': totalQuantity,
      'total_price': totalPrice,
    };
  }
}
