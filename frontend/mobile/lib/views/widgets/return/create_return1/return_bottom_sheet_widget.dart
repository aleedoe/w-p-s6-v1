// lib/views/return/widgets/return_bottom_sheet_widget.dart
import 'package:flutter/material.dart';
import 'package:mobile/models/create_return.dart';
import 'package:mobile/views/widgets/return/create_return1/create_return_provider.dart';
import 'package:mobile/views/widgets/return/create_return1/return_confirmation_dialog.dart';
import 'package:mobile/views/widgets/return/create_return/return_success_dialog.dart';
import 'return_item_card.dart';
import 'return_summary_widget.dart';

/// Bottom sheet untuk menampilkan detail return dan form pembuatan return
/// Menampilkan daftar produk yang akan di-return dengan quantity dan reason input
class ReturnBottomSheetWidget extends StatefulWidget {
  final CompletedTransaction transaction;
  final CreateReturnProvider provider;
  final Function() onReturnSuccess;

  const ReturnBottomSheetWidget({
    Key? key,
    required this.transaction,
    required this.provider,
    required this.onReturnSuccess,
  }) : super(key: key);

  @override
  State<ReturnBottomSheetWidget> createState() =>
      _ReturnBottomSheetWidgetState();
}

class _ReturnBottomSheetWidgetState extends State<ReturnBottomSheetWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
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
          Expanded(child: _buildReturnItemsList()),
          _buildSummaryAndSubmit(),
        ],
      ),
    );
  }

  /// Handle bar untuk drag bottom sheet
  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: const Color(0xFFCCCCCC),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  /// Header bottom sheet
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: const Color(0xFFEEEEEE))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.assignment_return,
                color: Color(0xFFFF6B6B),
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
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
            style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
          ),
        ],
      ),
    );
  }

  /// Daftar item return
  Widget _buildReturnItemsList() {
    if (widget.provider.returnItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Color(0xFF999999),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tidak ada produk',
              style: TextStyle(color: Color(0xFF666666), fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.provider.returnItems.length,
      itemBuilder: (context, index) {
        final returnItem = widget.provider.returnItems[index];
        return ReturnItemCard(
          returnItem: returnItem,
          index: index,
          provider: widget.provider,
          onQuantityChanged: () => setState(() {}),
          onReasonChanged: () => setState(() {}),
        );
      },
    );
  }

  /// Summary dan tombol submit
  Widget _buildSummaryAndSubmit() {
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
          ReturnSummaryWidget(provider: widget.provider),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: widget.provider.isSubmitting
                  ? null
                  : () => _handleSubmitReturn(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B6B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: widget.provider.isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Row(
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

  /// Handle submit return dengan validasi dan konfirmasi
  Future<void> _handleSubmitReturn() async {
    if (!widget.provider.validateReturnItems()) {
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ReturnConfirmationDialog(
        transaction: widget.transaction,
        provider: widget.provider,
      ),
    );

    if (confirmed != true) return;

    // Submit return
    final response = await widget.provider.submitReturn(widget.transaction);

    if (response != null && mounted) {
      // Show success dialog
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => ReturnSuccessDialog(response: response),
      );

      if (mounted) {
        Navigator.pop(context); // Close bottom sheet
        Navigator.pop(context, true); // Back to previous page
        widget.onReturnSuccess();
      }
    }
  }
}
