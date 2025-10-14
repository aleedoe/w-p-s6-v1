// lib/views/return/widgets/return_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:mobile/models/create_return.dart';
import 'package:mobile/utils/price_formatter.dart';
import 'return_item_card.dart';

/// Widget utama untuk Bottom Sheet proses Return Produk
class ReturnBottomSheet extends StatelessWidget {
  /// Data transaksi yang ingin di-return
  final CompletedTransaction transaction;

  /// List item yang akan di-return
  final List<ReturnCartItem> returnItems;

  /// Total harga semua item yang direturn
  final double totalReturnPrice;

  /// Total jumlah item (qty) yang direturn
  final int totalReturnItems;

  /// Total jumlah produk unik yang direturn
  final int totalReturnProducts;

  /// Status apakah sedang mengirim data return
  final bool isSubmitting;

  /// Callback ketika quantity diubah
  /// 💡 Parameter terakhir diubah dari [VoidCallback] → [StateSetter]
  /// agar bisa memanggil `setModalState()` dari StatefulBuilder.
  final Function(int index, int quantity, StateSetter setModalState)
      onUpdateQuantity;

  /// Callback ketika alasan return diubah
  /// 💡 Sama seperti di atas, ubah parameter terakhir ke [StateSetter].
  final Function(int index, String reason, StateSetter setModalState)
      onUpdateReason;

  /// Callback ketika tombol submit ditekan
  final Function(CompletedTransaction transaction) onSubmitReturn;

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
    // StatefulBuilder digunakan agar bottom sheet bisa diupdate
    // tanpa harus menutup dan membuka ulang
    return StatefulBuilder(
      builder: (context, setModalState) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Handle kecil di atas bottom sheet
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCCCCCC),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header bagian atas
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
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
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),

            // Daftar produk yang akan di-return
            Expanded(
              child: returnItems.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: returnItems.length,
                      itemBuilder: (context, index) {
                        final returnItem = returnItems[index];
                        return ReturnItemCard(
                          returnItem: returnItem,
                          index: index,

                          // Callback untuk ubah quantity
                          // Dikirim bersama setModalState agar item bisa update UI
                          onUpdateQuantity: onUpdateQuantity,

                          // Callback untuk ubah alasan return
                          onUpdateReason: onUpdateReason,

                          // SetState dari StatefulBuilder dikirim ke item card
                          setModalState: setModalState,
                        );
                      },
                    ),
            ),

            // Bagian bawah: summary dan tombol submit
            _buildSummaryAndSubmit(context, transaction),
          ],
        ),
      ),
    );
  }

  /// Widget tampilan ketika tidak ada produk
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
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
    );
  }

  /// Widget untuk menampilkan summary dan tombol submit
  Widget _buildSummaryAndSubmit(
    BuildContext context,
    CompletedTransaction transaction,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Total produk return
          _buildSummaryRow(
            'Total Produk Return',
            '$totalReturnProducts jenis',
            const Color(0xFF666666),
          ),
          const SizedBox(height: 8),

          // Total item return
          _buildSummaryRow(
            'Total Item Return',
            '$totalReturnItems pcs',
            const Color(0xFF666666),
          ),
          const SizedBox(height: 16),

          const Divider(color: Color(0xFFEEEEEE)),
          const SizedBox(height: 16),

          // Total harga return
          _buildSummaryRow(
            'Total Return',
            'Rp ${PriceFormatter.format(totalReturnPrice)}',
            const Color(0xFF333333),
            isTotal: true,
          ),
          const SizedBox(height: 20),

          // Tombol submit
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () {
                      // Panggil callback submit
                      onSubmitReturn(transaction);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B6B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
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

  /// Helper untuk membangun baris summary
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
            color: isTotal ? const Color(0xFFFF6B6B) : const Color(0xFF333333),
          ),
        ),
      ],
    );
  }
}
