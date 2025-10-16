// lib/views/stock_out/stock_out_page.dart

import 'package:flutter/material.dart';
import 'package:mobile/services/api_client.dart';
import 'package:mobile/models/stock_out.dart';
import 'package:mobile/repositories/stock_out_repository.dart';
import './stock_out_detail_page.dart';
import './create_stockout_page.dart';
import '../widgets/stock_out/stock_out_app_bar.dart';
import '../widgets/stock_out/stock_out_search_bar.dart';
import '../widgets/stock_out/stock_out_stats_cards.dart';
import '../widgets/stock_out/stock_out_table.dart';
import '../widgets/stock_out/stock_out_empty_state.dart';
import '../widgets/stock_out/stock_out_error_state.dart';

/// Halaman utama untuk manajemen Stock Out
/// Menampilkan daftar stock out dengan fitur pencarian dan statistik
class StockOutPage extends StatefulWidget {
  final int? resellerId;

  const StockOutPage({Key? key, this.resellerId}) : super(key: key);

  @override
  State<StockOutPage> createState() => _StockOutPageState();
}

class _StockOutPageState extends State<StockOutPage> {
  // Repository untuk mengakses data stock out
  final StockOutRepository _stockOutRepository = StockOutRepository();
  final TextEditingController _searchController = TextEditingController();

  // State management
  StockOutResponse? _stockOutData;
  List<StockOut> _filteredStockOuts = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadStockOutData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _stockOutRepository.dispose();
    super.dispose();
  }

  /// Memuat data stock out dari repository
  Future<void> _loadStockOutData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final stockOutData = await _stockOutRepository.fetchStockOuts(
        resellerId: widget.resellerId ?? 1,
      );

      setState(() {
        _stockOutData = stockOutData;
        _filteredStockOuts = stockOutData.stockOuts;
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

  /// Refresh data stock out dan tampilkan notifikasi sukses
  Future<void> _refreshStockOuts() async {
    await _loadStockOutData();
    if (_errorMessage == null) {
      _showSuccessSnackBar('Data berhasil diperbarui');
    }
  }

  /// Filter stock out berdasarkan query pencarian
  void _searchStockOuts(String query) {
    if (_stockOutData == null) return;

    setState(() {
      _filteredStockOuts = _stockOutRepository.searchStockOuts(
        _stockOutData!.stockOuts,
        query,
      );
    });
  }

  /// Navigasi ke halaman detail stock out
  void _navigateToDetail(StockOut stockOut) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StockOutDetailPage(
          resellerId: widget.resellerId ?? 1,
          stockOutId: stockOut.idStockOut,
          stockOut: stockOut,
        ),
      ),
    );
  }

  /// Navigasi ke halaman create stock out
  Future<void> _navigateToCreate() async {
    final created = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CreateStockOutPage(resellerId: widget.resellerId ?? 1),
      ),
    );

    // Refresh data jika berhasil membuat stock out baru
    if (created == true) {
      await _refreshStockOuts();
    }
  }

  // Helper methods untuk snackbar notifications
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
            // Custom App Bar dengan tombol back dan refresh
            StockOutAppBar(
              isLoading: _isLoading,
              onRefresh: _refreshStockOuts,
              onBack: () => Navigator.pop(context),
            ),

            // Search Bar untuk filter stock out
            StockOutSearchBar(
              controller: _searchController,
              onChanged: _searchStockOuts,
            ),

            // Tampilkan statistik jika data sudah dimuat
            if (_stockOutData != null && !_isLoading)
              StockOutStatsCards(stockOutData: _stockOutData!),

            SizedBox(height: 24),

            // Content area: loading, error, empty, atau table
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreate,
        backgroundColor: Color(0xFF2196F3),
        child: Icon(Icons.add),
      ),
    );
  }

  /// Membangun konten utama berdasarkan state
  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return StockOutErrorState(
        errorMessage: _errorMessage!,
        onRetry: _loadStockOutData,
      );
    }

    if (_filteredStockOuts.isEmpty) {
      return StockOutEmptyState(
        hasSearchQuery: _searchController.text.isNotEmpty,
      );
    }

    return _buildTableSection();
  }

  /// Loading state dengan indicator
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Color(0xFF4CAF50),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Memuat data...',
            style: TextStyle(
              color: Color(0xFF666666),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Section tabel dengan header dan refresh indicator
  Widget _buildTableSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daftar Stock Out (${_filteredStockOuts.length})',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshStockOuts,
              color: Color(0xFF4CAF50),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: StockOutTable(
                    stockOuts: _filteredStockOuts,
                    onTapRow: _navigateToDetail,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}