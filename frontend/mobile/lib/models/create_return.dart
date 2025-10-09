// lib/models/create_return.dart

class CompletedTransaction {
  final int idTransaction;
  final String createdAt;
  final String status;
  final double totalPrice;
  final int totalProducts;

  CompletedTransaction({
    required this.idTransaction,
    required this.createdAt,
    required this.status,
    required this.totalPrice,
    required this.totalProducts,
  });

  factory CompletedTransaction.fromJson(Map<String, dynamic> json) {
    return CompletedTransaction(
      idTransaction: json['id_transaction'] ?? 0,
      createdAt: json['created_at'] ?? '',
      status: json['status'] ?? '',
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      totalProducts: json['total_products'] ?? 0,
    );
  }
}

class CompletedTransactionResponse {
  final int idReseller;
  final List<CompletedTransaction> transactions;

  CompletedTransactionResponse({
    required this.idReseller,
    required this.transactions,
  });

  factory CompletedTransactionResponse.fromJson(Map<String, dynamic> json) {
    return CompletedTransactionResponse(
      idReseller: json['id_reseller'] ?? 0,
      transactions:
          (json['transactions'] as List<dynamic>?)
              ?.map(
                (item) =>
                    CompletedTransaction.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}

class ReturnDetailItem {
  final int idDetailTransaction;
  final int idProduct;
  final String productName;
  final double price;
  final int quantity;
  final double totalPrice;

  ReturnDetailItem({
    required this.idDetailTransaction,
    required this.idProduct,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.totalPrice,
  });

  factory ReturnDetailItem.fromJson(Map<String, dynamic> json) {
    return ReturnDetailItem(
      idDetailTransaction: json['id_detail_transaction'] ?? 0,
      idProduct: json['id_product'] ?? 0,
      productName: json['product_name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      totalPrice: (json['total_price'] ?? 0).toDouble(),
    );
  }
}

class TransactionDetailForReturn {
  final int idReseller;
  final int idTransaction;
  final List<ReturnDetailItem> details;
  final int totalProducts;
  final int totalQuantity;
  final double totalPrice;

  TransactionDetailForReturn({
    required this.idReseller,
    required this.idTransaction,
    required this.details,
    required this.totalProducts,
    required this.totalQuantity,
    required this.totalPrice,
  });

  factory TransactionDetailForReturn.fromJson(Map<String, dynamic> json) {
    return TransactionDetailForReturn(
      idReseller: json['id_reseller'] ?? 0,
      idTransaction: json['id_transaction'] ?? 0,
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
}

class ReturnCartItem {
  final ReturnDetailItem product;
  int quantity;
  String reason;

  ReturnCartItem({
    required this.product,
    required this.quantity,
    this.reason = '',
  });

  double get totalPrice => product.price * quantity;
}

class CreateReturnRequest {
  final List<ReturnCartItem> details;

  CreateReturnRequest({required this.details});

  Map<String, dynamic> toJson() {
    return {
      'details': details.map((item) {
        return {
          'id_product': item.product.idProduct,
          'quantity': item.quantity,
          'reason': item.reason,
        };
      }).toList(),
    };
  }
}

class CreateReturnResponse {
  final String message;
  final ReturnTransactionData returnTransaction;

  CreateReturnResponse({
    required this.message,
    required this.returnTransaction,
  });

  factory CreateReturnResponse.fromJson(Map<String, dynamic> json) {
    return CreateReturnResponse(
      message: json['message'] ?? '',
      returnTransaction: ReturnTransactionData.fromJson(
        json['return_transaction'] ?? {},
      ),
    );
  }
}

class ReturnTransactionData {
  final int idReturnTransaction;
  final int idTransaction;
  final int idReseller;
  final String status;
  final int totalProductsReturned;
  final List<Map<String, dynamic>> details;

  ReturnTransactionData({
    required this.idReturnTransaction,
    required this.idTransaction,
    required this.idReseller,
    required this.status,
    required this.totalProductsReturned,
    required this.details,
  });

  factory ReturnTransactionData.fromJson(Map<String, dynamic> json) {
    return ReturnTransactionData(
      idReturnTransaction: json['id_return_transaction'] ?? 0,
      idTransaction: json['id_transaction'] ?? 0,
      idReseller: json['id_reseller'] ?? 0,
      status: json['status'] ?? '',
      totalProductsReturned: json['total_products_returned'] ?? 0,
      details:
          (json['details'] as List<dynamic>?)
              ?.map((item) => item as Map<String, dynamic>)
              .toList() ??
          [],
    );
  }
}
