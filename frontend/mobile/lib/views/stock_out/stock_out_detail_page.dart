// lib/views/stock_out/stock_out_detail_page.dart

import 'package:flutter/material.dart';
import 'package:mobile/services/api_client.dart';
import 'package:mobile/views/widgets/stock_out/detail_stock_out/stock_out_app_bar.dart';
import '../../models/stock_out.dart';
import '../../models/stock_out_detail.dart';
import '../../repositories/stock_out_repository.dart';
import '../widgets/stock_out/detail_stock_out/stock_out_info_card.dart';
import '../widgets/stock_out/detail_stock_out/stock_out_products_table.dart';
import '../widgets/stock_out/detail_stock_out/stock_out_summary_stats.dart';
import '../widgets/stock_out/detail_stock_out/stock_out_total_section.dart';


/// Halaman detail untuk menampilkan informasi lengkap stock out
/// termasuk daftar produk, harga, dan total keseluruhan
class StockOutDetailPage extends StatefulWidget {
  final int resellerId;
  final int stockOutId;
  final StockOut stockOut;

  const StockOutDetailPage({
    Key? key,
    required this.resellerId,
    required this.stockOutId,
    required this.stockOut,
  }) : super(key: key);

  @override
  State<StockOutDetailPage> createState() => _StockOutDetailPageState();
}

class _StockOutDetailPageState extends State<StockOutDetailPage> {
  final StockOutRepository _stockOutRepository = StockOutRepository();

  StockOutDetailResponse? _detailData;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDetailData();
  }

  @override
  void dispose() {
    _stockOutRepository.dispose();
    super.dispose();
  }

  /// Memuat data detail stock out dari repository
  Future<void> _loadDetailData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final detailData = await _stockOutRepository.fetchStockOutDetail(
        resellerId: widget.resellerId,
        stockOutId: widget.stockOutId,
      );

      setState(() {
        _detailData = detailData;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
      _showErrorSnackBar(e.message);
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan yang tidak terduga';
        _isLoading = false;
      });
      _showErrorSnackBar('Terjadi kesalahan yang tidak terduga');
    }
  }

  /// Refresh data detail dengan menampilkan notifikasi sukses
  Future<void> _refreshDetailData() async {
    await _loadDetailData();
    if (_errorMessage == null) {
      _showSuccessSnackBar('Data berhasil diperbarui');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar dengan tombol refresh
            StockOutAppBar(
              stockOutId: widget.stockOutId,
              isLoading: _isLoading,
              onRefresh: _refreshDetailData,
            ),

            // Content utama
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  /// Membangun konten utama berdasarkan state (loading, error, atau data)
  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    return _buildDataState();
  }

  /// State ketika sedang memuat data
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
          ),
          SizedBox(height: 16),
          Text(
            'Memuat detail...',
            style: TextStyle(color: Color(0xFF666666), fontSize: 14),
          ),
        ],
      ),
    );
  }

  /// State ketika terjadi error
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Color(0xFFF44336)),
          SizedBox(height: 16),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF666666), fontSize: 14),
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadDetailData,
            icon: Icon(Icons.refresh),
            label: Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// State ketika data berhasil dimuat
  Widget _buildDataState() {
    return RefreshIndicator(
      onRefresh: _refreshDetailData,
      color: Color(0xFF4CAF50),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informasi umum stock out
            StockOutInfoCard(
              stockOutId: widget.stockOutId,
              resellerId: widget.resellerId,
              createdAt: widget.stockOut.createdAt,
            ),
            SizedBox(height: 24),

            // Statistik ringkasan
            if (_detailData != null)
              StockOutSummaryStats(detailData: _detailData!),
            SizedBox(height: 24),

            // Tabel produk
            Text(
              'Detail Produk Stock Out',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            SizedBox(height: 16),
            StockOutProductsTable(detailData: _detailData),
            SizedBox(height: 24),

            // Total keseluruhan
            if (_detailData != null)
              StockOutTotalSection(detailData: _detailData!),
          ],
        ),
      ),
    );
  }
}
