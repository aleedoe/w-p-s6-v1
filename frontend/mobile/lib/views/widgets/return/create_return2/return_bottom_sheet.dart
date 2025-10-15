// lib/views/return/widgets/return_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:mobile/models/create_return.dart';
import 'return_item_card.dart';

/// Bottom sheet for creating return with product selection
class ReturnBottomSheet extends StatefulWidget {
  final CompletedTransaction transaction;
  final List<ReturnCartItem> returnItems;
  final bool isSubmitting;
  final double totalReturnPrice;
  final int totalReturnItems;
  final int totalReturnProducts;
  final Function(int index, int quantity) onQuantityUpdate;
  final Function(int index, String reason) onReasonUpdate;
  final VoidCallback onSubmit;

  const ReturnBottomSheet({
    Key? key,
    required this.transaction,
    required this.returnItems,
    required this.isSubmitting,
    required this.totalReturnPrice,
    required this.totalReturnItems,
    required this.totalReturnProducts,
    required this.onQuantityUpdate,
    required this.onReasonUpdate,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<ReturnBottomSheet> createState() => _ReturnBottomSheetState();
}

class _ReturnBottomSheetState extends State<ReturnBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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
          _buildReturnItemsList(),
          _buildSummaryAndSubmit(),
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
              Icon(Icons.assignment_return, color: Color(0xFFFF6B6B), size: 24),
              SizedBox(width: 8),
              Text(
                'Return Produk',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          Text(
            'Transaksi #${widget.transaction.idTransaction}',
            style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
          ),
        ],
      ),
    );
  }

  Widget _buildReturnItemsList() {
    return Expanded(
      child: widget.returnItems.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: widget.returnItems.length,
              itemBuilder: (context, index) {
                return ReturnItemCard(
                  returnItem: widget.returnItems[index],
                  index: index,
                  onQuantityUpdate: (quantity) {
                    setState(() {
                      widget.onQuantityUpdate(index, quantity);
                    });
                  },
                  onReasonUpdate: (reason) {
                    setState(() {
                      widget.onReasonUpdate(index, reason);
                    });
                  },
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Color(0xFF999999)),
          SizedBox(height: 16),
          Text(
            'Tidak ada produk',
            style: TextStyle(color: Color(0xFF666666), fontSize: 14),
          ),
        ],
      ),
    );
  }

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
          _buildSummaryRow(
            'Total Produk Return',
            '${widget.totalReturnProducts} jenis',
          ),
          SizedBox(height: 8),
          _buildSummaryRow(
            'Total Item Return',
            '${widget.totalReturnItems} pcs',
          ),
          SizedBox(height: 16),
          Divider(color: Color(0xFFEEEEEE)),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Return',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              Text(
                'Rp ${_formatPrice(widget.totalReturnPrice)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6B6B),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildSubmitButton(),
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

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: widget.isSubmitting ? null : widget.onSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFFF6B6B),
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
                    'Buat Return',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
      ),
    );
  }

  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
