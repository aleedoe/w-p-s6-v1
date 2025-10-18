// lib/views/stock_out/stock_out_page.dart

import 'package:flutter/material.dart';
import 'package:mobile/services/api_client.dart';
import 'package:mobile/services/token_manager.dart';
import 'package:mobile/models/auth_models.dart';
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
  const StockOutPage({Key? key}) : super(key: key);

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
  int? _resellerId;
  bool _isInitialLoading = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initPage();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _stockOutRepository.dispose();
    super.dispose();
  }

  /// Inisialisasi halaman dengan mendapatkan user dari TokenManager
  Future<void> _initPage() async {
    setState(() {
      _isInitialLoading = true;
      _errorMessage = null;
    });

    try {
      final User? user = await TokenManager.getUser();

      if (user == null) {
        throw Exception('User tidak ditemukan. Silakan login kembali.');
      }

      _resellerId = user.id; // Atau user.resellerId jika ada field tersebut

      await _loadStockOutData();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isInitialLoading = false;
      });
    }
  }

  /// Memuat data stock out dari repository
  Future<void> _loadStockOutData() async {
    if (_resellerId == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final stockOutData = await _stockOutRepository.fetchStockOuts(
        resellerId: _resellerId!,
      );

      setState(() {
        _stockOutData = stockOutData;
        _filteredStockOuts = stockOutData.stockOuts;
        _isLoading = false;
        _isInitialLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
        _isInitialLoading = false;
      });
      _showErrorSnackBar(e.message);
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan yang tidak terduga';
        _isLoading = false;
        _isInitialLoading = false;
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
    if (_resellerId == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StockOutDetailPage(
          resellerId: _resellerId!,
          stockOutId: stockOut.idStockOut,
          stockOut: stockOut,
        ),
      ),
    );
  }

  /// Navigasi ke halaman create stock out
  Future<void> _navigateToCreate() async {
    if (_resellerId == null) return;

    final created = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateStockOutPage(resellerId: _resellerId!),
      ),
    );

    // Refresh data jika berhasil membuat stock out baru
    if (created == true) {
      await _refreshStockOuts();
    }
  }

  // Helper methods untuk snackbar notifications
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
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
    // Loading awal saat mengambil user dari TokenManager
    if (_isInitialLoading) {
      return Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
          ),
        ),
      );
    }

    // Error saat inisialisasi (misal user tidak ditemukan)
    if (_errorMessage != null && _resellerId == null) {
      return Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        body: Center(
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
              ElevatedButton(
                onPressed: _initPage,
                child: Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

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
            Expanded(child: _buildContent()),
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
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
          ),
          SizedBox(height: 16),
          Text(
            'Memuat data...',
            style: TextStyle(color: Color(0xFF666666), fontSize: 14),
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
