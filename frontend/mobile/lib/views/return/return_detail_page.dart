// lib/views/return/return_detail_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/views/widgets/return/detail_return/return_app_bar.dart';
import 'package:mobile/views/widgets/return/detail_return/return_info_card.dart';
import 'package:mobile/views/widgets/return/detail_return/return_product_table.dart';
import 'package:mobile/views/widgets/return/detail_return/return_summary_stats.dart';
import 'package:mobile/views/widgets/return/detail_return/return_total_section.dart';

import '../../models/return_transaction.dart';
import '../../models/return_transaction_detail.dart';
import '../../repositories/return_repository.dart';
import '../../services/api_client.dart';
// Import widget dan utilitas yang baru dipisahkan


class ReturnDetailPage extends StatefulWidget {
  final int resellerId;
  final int returnTransactionId;
  final ReturnTransaction returnTransaction;

  const ReturnDetailPage({
    Key? key,
    required this.resellerId,
    required this.returnTransactionId,
    required this.returnTransaction,
  }) : super(key: key);

  @override
  State<ReturnDetailPage> createState() => _ReturnDetailPageState();
}

class _ReturnDetailPageState extends State<ReturnDetailPage> {
  final ReturnRepository _returnRepository = ReturnRepository();

  ReturnDetailResponse? _detailData;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Memastikan lokal 'id_ID' diatur untuk pemformatan tanggal/harga
    Intl.defaultLocale = 'id_ID';
    _loadDetailData();
  }

  @override
  void dispose() {
    _returnRepository.dispose();
    super.dispose();
  }

  // Muat data detail return dari API
  Future<void> _loadDetailData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final detailData = await _returnRepository.fetchReturnDetail(
        resellerId: widget.resellerId,
        returnTransactionId: widget.returnTransactionId,
      );

      setState(() {
        _detailData = detailData;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      // Penanganan error dari API
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
      _showErrorSnackBar(e.message);
    } catch (e) {
      // Penanganan error umum/tidak terduga
      setState(() {
        _errorMessage = 'Terjadi kesalahan yang tidak terduga';
        _isLoading = false;
      });
      _showErrorSnackBar('Terjadi kesalahan yang tidak terduga');
    }
  }

  // Refresh detail data
  Future<void> _refreshDetailData() async {
    await _loadDetailData();
    if (_errorMessage == null) {
      _showSuccessSnackBar('Data berhasil diperbarui');
    }
  }

  // Tampilkan SnackBar Error
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Tampilkan SnackBar Sukses
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Tampilan ketika memuat data
  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Color(0xFFFF6B6B),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Memuat detail...',
            style: TextStyle(
              color: Color(0xFF666666),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Tampilan ketika terjadi error
  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Color(0xFFF44336),
            ),
            SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF666666),
                fontSize: 14,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadDetailData,
              icon: Icon(Icons.refresh),
              label: Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF6B6B),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tampilan konten utama (berhasil dimuat)
  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _refreshDetailData,
      color: Color(0xFFFF6B6B),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Return Info Card
            ReturnInfoCard(
              returnTransaction: widget.returnTransaction,
              returnTransactionId: widget.returnTransactionId,
              resellerId: widget.resellerId,
            ),
            SizedBox(height: 24),

            // Summary Stats
            ReturnSummaryStats(
              totalProducts: _detailData!.totalProducts,
              totalQuantity: _detailData!.totalQuantity,
            ),
            SizedBox(height: 24),

            // Products Table Header
            Text(
              'Detail Produk Return',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            SizedBox(height: 16),

            // Products Table
            ReturnProductTable(details: _detailData!.details),
            SizedBox(height: 24),

            // Total Section
            ReturnTotalSection(totalPrice: _detailData!.totalPrice),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_isLoading) {
      content = _buildLoadingIndicator();
    } else if (_errorMessage != null) {
      content = _buildErrorView();
    } else if (_detailData != null) {
      content = _buildContent();
    } else {
      // Fallback: Jika tidak loading, tidak error, dan data null (jarang terjadi)
      content = Center(child: Text('Data detail tidak tersedia.'));
    }

    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar (Dipisahkan ke widget)
            ReturnAppBar(
              returnTransactionId: widget.returnTransactionId,
              isLoading: _isLoading,
              onRefresh: _refreshDetailData,
              onBack: () => Navigator.pop(context),
            ),

            // Content Area
            Expanded(child: content),
          ],
        ),
      ),
    );
  }
}