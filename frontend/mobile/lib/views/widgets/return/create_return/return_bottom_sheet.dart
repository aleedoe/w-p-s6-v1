// lib/views/return/widgets/return_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:mobile/models/create_return.dart';
import 'package:mobile/utils/price_formatter.dart';
import 'return_item_card.dart';

class ReturnBottomSheet extends StatelessWidget {
  final CompletedTransaction transaction;
  final List<ReturnCartItem> returnItems;
  final double totalReturnPrice;
  final int totalReturnItems;
  final int totalReturnProducts;
  final bool isSubmitting;
  final Function(int, int, VoidCallback) onUpdateQuantity;
  final Function(int, String, VoidCallback) onUpdateReason;
  final Function(CompletedTransaction) onSubmitReturn;

  const ReturnBottomSheet({
    Key? key,
    required this.transaction,
    required this.returnItems,
    required this.totalReturnPrice,
    required this.totalReturnItems,
    required this.totalReturnProducts,
    required this.isSubmitting,
    required this.onUpdateQuantity,
    required this.onUpdateReason,
    required this.onSubmitReturn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Menggunakan StatefulBuilder untuk memungkinkan perubahan state di dalam bottom sheet
    return StatefulBuilder(
      builder: (context, setModalState) => Container(
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
            // Handle
            Container(
              margin: EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Color(0xFFCCCCCC),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Container(
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
                        Icons.assignment_return,
                        color: Color(0xFFFF6B6B),
                        size: 24,
                      ),
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
                    'Transaksi #${transaction.idTransaction}',
                    style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
                  ),
                ],
              ),
            ),

            // Return Items List
            Expanded(
              child: returnItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: Color(0xFF999999),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Tidak ada produk',
                            style: TextStyle(
                              color: Color(0xFF666666),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: returnItems.length,
                      itemBuilder: (context, index) {
                        final returnItem = returnItems[index];
                        return ReturnItemCard(
                          returnItem: returnItem,
                          index: index,
                          onUpdateQuantity: onUpdateQuantity,
                          onUpdateReason: onUpdateReason,
                          setModalState: setModalState,
                        );
                      },
                    ),
            ),

            // Summary and Submit
            _buildSummaryAndSubmit(context, transaction),
          ],
        ),
      ),
    );
  }

  // Widget untuk Summary dan Submit
  Widget _buildSummaryAndSubmit(
    BuildContext context,
    CompletedTransaction transaction,
  ) {
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
          _buildSummaryRow(
            'Total Produk Return',
            '$totalReturnProducts jenis',
            Color(0xFF666666),
          ),
          SizedBox(height: 8),
          _buildSummaryRow(
            'Total Item Return',
            '$totalReturnItems pcs',
            Color(0xFF666666),
          ),
          SizedBox(height: 16),
          Divider(color: Color(0xFFEEEEEE)),
          SizedBox(height: 16),
          // Total Return Price
          _buildSummaryRow(
            'Total Return',
            'Rp ${PriceFormatter.format(totalReturnPrice)}',
            Color(0xFF333333),
            isTotal: true,
          ),
          SizedBox(height: 20),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () {
                      onSubmitReturn(transaction);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF6B6B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: isSubmitting
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
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper untuk Summary Row
  Row _buildSummaryRow(
    String label,
    String value,
    Color color, {
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 20 : 14,
            fontWeight: FontWeight.bold,
            color: isTotal ? Color(0xFFFF6B6B) : Color(0xFF333333),
          ),
        ),
      ],
    );
  }
}
