import 'package:flutter/material.dart';
import 'package:mobile/models/product.dart';
import 'package:mobile/utils/price_formatter.dart';
import 'cart_item_widget.dart';

class CartBottomSheet extends StatefulWidget {
  final List<CartItem> cartItems;
  final double totalPrice;
  final int totalItems;
  final bool isSubmitting;
  final Function(int index, int newQuantity) onUpdateQuantity;
  final Function(int index) onRemoveItem;
  final VoidCallback onSubmitOrder;

  const CartBottomSheet({
    Key? key,
    required this.cartItems,
    required this.totalPrice,
    required this.totalItems,
    required this.isSubmitting,
    required this.onUpdateQuantity,
    required this.onRemoveItem,
    required this.onSubmitOrder,
  }) : super(key: key);

  @override
  State<CartBottomSheet> createState() => _CartBottomSheetState();
}

class _CartBottomSheetState extends State<CartBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle
          _buildHandle(),

          // Header
          _buildHeader(),

          // Cart Items
          _buildCartItemsList(),

          // Summary and Checkout
          _buildCheckoutSection(),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Color(0xFFCCCCCC),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.shopping_cart, color: Color(0xFF4CAF50), size: 24),
              SizedBox(width: 8),
              Text(
                'Keranjang Belanja',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          Text(
            '${widget.cartItems.length} Produk',
            style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemsList() {
    return Expanded(
      child: widget.cartItems.isEmpty
          ? _buildEmptyCart()
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: widget.cartItems.length,
              itemBuilder: (context, index) {
                final cartItem = widget.cartItems[index];
                return CartItemWidget(
                  cartItem: cartItem,
                  onDecrement: () {
                    widget.onUpdateQuantity(index, cartItem.quantity - 1);
                    setState(() {});
                  },
                  onIncrement: () {
                    widget.onUpdateQuantity(index, cartItem.quantity + 1);
                    setState(() {});
                  },
                  onRemove: () {
                    widget.onRemoveItem(index);
                    setState(() {});
                  },
                );
              },
            ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: Color(0xFF999999),
          ),
          SizedBox(height: 16),
          Text(
            'Keranjang masih kosong',
            style: TextStyle(color: Color(0xFF666666), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSection() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Summary Rows
          _buildSummaryRow('Total Item', '${widget.totalItems} pcs'),
          SizedBox(height: 8),
          _buildSummaryRow('Total Produk', '${widget.cartItems.length} jenis'),
          SizedBox(height: 16),
          Divider(color: Color(0xFFEEEEEE)),
          SizedBox(height: 16),

          // Total Price
          _buildTotalPrice(),
          SizedBox(height: 20),

          // Checkout Button
          _buildCheckoutButton(),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Color(0xFF666666))),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalPrice() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Total Harga',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        Text(
          'Rp ${PriceFormatter.format(widget.totalPrice)}',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4CAF50),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: widget.isSubmitting
            ? null
            : () {
                Navigator.pop(context); // Close bottom sheet
                widget.onSubmitOrder();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: widget.isSubmitting
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline),
                  SizedBox(width: 8),
                  Text(
                    'Buat Pesanan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
      ),
    );
  }
}
