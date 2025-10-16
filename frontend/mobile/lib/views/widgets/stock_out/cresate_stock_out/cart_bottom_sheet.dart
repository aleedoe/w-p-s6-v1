// lib/widgets/stockout/cart_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:mobile/models/create_stockout.dart';

/// Bottom sheet untuk menampilkan daftar barang yang akan di-stock out
class CartBottomSheet extends StatefulWidget {
  final List<StockOutCartItem> cartItems;
  final int totalItems;
  final bool isSubmitting;
  final Function(int index, int quantity) onUpdateQuantity;
  final VoidCallback onSubmit;

  const CartBottomSheet({
    Key? key,
    required this.cartItems,
    required this.totalItems,
    required this.isSubmitting,
    required this.onUpdateQuantity,
    required this.onSubmit,
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
          _buildHandle(),
          _buildHeader(),
          _buildCartItems(),
          _buildSummaryAndSubmit(),
        ],
      ),
    );
  }

  /// Builds drag handle at the top
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

  /// Builds header section
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
              Icon(
                Icons.assignment_turned_in,
                color: Color(0xFFFF9800),
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Daftar Stok Keluar',
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

  /// Builds cart items list
  Widget _buildCartItems() {
    return Expanded(
      child: widget.cartItems.isEmpty
          ? _buildEmptyCart()
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: widget.cartItems.length,
              itemBuilder: (context, index) {
                return _buildCartItemCard(widget.cartItems[index], index);
              },
            ),
    );
  }

  /// Builds empty cart state
  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 64, color: Color(0xFF999999)),
          SizedBox(height: 16),
          Text(
            'Daftar masih kosong',
            style: TextStyle(color: Color(0xFF666666), fontSize: 14),
          ),
        ],
      ),
    );
  }

  /// Builds individual cart item card
  Widget _buildCartItemCard(StockOutCartItem cartItem, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildProductIcon(),
          SizedBox(width: 12),
          _buildProductInfo(cartItem),
          _buildQuantityControls(cartItem, index),
        ],
      ),
    );
  }

  /// Builds product icon for cart item
  Widget _buildProductIcon() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Color(0xFFFF9800).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.inventory_2, color: Color(0xFFFF9800), size: 24),
    );
  }

  /// Builds product information
  Widget _buildProductInfo(StockOutCartItem cartItem) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            cartItem.stock.productName,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Stok tersedia: ${cartItem.stock.currentStock}',
            style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
          ),
        ],
      ),
    );
  }

  /// Builds quantity control buttons
  Widget _buildQuantityControls(StockOutCartItem cartItem, int index) {
    return Row(
      children: [
        _buildQuantityButton(
          icon: Icons.remove,
          color: Color(0xFFF44336),
          onTap: () {
            widget.onUpdateQuantity(index, cartItem.quantity - 1);
            setState(() {});
          },
        ),
        Container(
          width: 40,
          alignment: Alignment.center,
          child: Text(
            '${cartItem.quantity}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
        ),
        _buildQuantityButton(
          icon: Icons.add,
          color: Color(0xFFFF9800),
          onTap: () {
            widget.onUpdateQuantity(index, cartItem.quantity + 1);
            setState(() {});
          },
        ),
      ],
    );
  }

  /// Builds individual quantity button
  Widget _buildQuantityButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }

  /// Builds summary and submit section
  Widget _buildSummaryAndSubmit() {
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
          _buildSummaryRow('Total Item', '${widget.totalItems} pcs'),
          SizedBox(height: 8),
          _buildSummaryRow('Total Produk', '${widget.cartItems.length} jenis'),
          SizedBox(height: 20),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  /// Builds summary row
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

  /// Builds submit button
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: widget.isSubmitting ? null : widget.onSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFFF9800),
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
                  Icon(Icons.assignment_turned_in_outlined),
                  SizedBox(width: 8),
                  Text(
                    'Catat Stok Keluar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
      ),
    );
  }
}
