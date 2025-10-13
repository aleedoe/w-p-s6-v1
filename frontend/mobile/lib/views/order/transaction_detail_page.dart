// lib/pages/transaction_detail_page.dart
import 'package:flutter/material.dart';
import 'package:mobile/views/widgets/order/detail_order/transaction_detail_body.dart';
import 'package:mobile/views/widgets/order/detail_order/transaction_detail_controller.dart';
import '../../models/transaction.dart';

class TransactionDetailPage extends StatefulWidget {
  final int resellerId;
  final int transactionId;
  final Transaction transaction;

  const TransactionDetailPage({
    Key? key,
    required this.resellerId,
    required this.transactionId,
    required this.transaction,
  }) : super(key: key);

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  late TransactionDetailController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TransactionDetailController(
      resellerId: widget.resellerId,
      transactionId: widget.transactionId,
    );
    _controller.loadDetailData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: TransactionDetailBody(
                controller: _controller,
                transaction: widget.transaction,
                transactionId: widget.transactionId,
                resellerId: widget.resellerId,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Membangun app bar custom dengan tombol refresh dan navigasi
  Widget _buildAppBar() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.arrow_back, color: Colors.white, size: 24),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detail Transaksi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Order #${widget.transactionId}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _controller.isLoadingNotifier,
            builder: (context, isLoading, _) {
              return GestureDetector(
                onTap: isLoading ? null : _controller.refreshDetailData,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Icon(Icons.refresh, color: Colors.white, size: 24),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
