// lib/views/return/return_page.dart
import 'package:flutter/material.dart';
import 'package:mobile/services/api_client.dart';
import 'package:mobile/services/token_manager.dart';
import 'package:mobile/models/auth_models.dart';
import 'package:mobile/views/return/create_return_page.dart';
import 'package:mobile/views/widgets/return/return_filter_chips.dart';
import 'package:mobile/views/widgets/return/return_helpers.dart';
import 'package:mobile/views/widgets/return/return_search_bar.dart';
import 'package:mobile/views/widgets/return/return_stats_row.dart';
import 'package:mobile/views/widgets/return/return_table.dart';
import '../../models/return_transaction.dart';
import '../../repositories/return_repository.dart';
import './return_detail_page.dart';
import 'package:mobile/views/widgets/return/return_app_bar.dart';

class ReturnPage extends StatefulWidget {
  const ReturnPage({Key? key}) : super(key: key);

  @override
  State<ReturnPage> createState() => _ReturnPageState();
}

class _ReturnPageState extends State<ReturnPage> {
  final ReturnRepository _returnRepository = ReturnRepository();
  final TextEditingController _searchController = TextEditingController();

  ReturnTransactionResponse? _returnData;
  List<ReturnTransaction> _filteredReturns = [];
  int? _resellerId;
  bool _isInitialLoading = true;
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedFilter = 'Semua';

  // Daftar opsi filter yang tersedia
  final List<String> _filterOptions = [
    'Semua',
    'Disetujui',
    'Menunggu',
    // 'Diproses',
    'Ditolak',
  ];

  @override
  void initState() {
    super.initState();
    _initPage();
    // Tambahkan listener untuk otomatis memfilter saat teks pencarian berubah
    _searchController.addListener(() => _searchReturns(_searchController.text));
  }

  @override
  void dispose() {
    _searchController.removeListener(
      () => _searchReturns(_searchController.text),
    );
    _searchController.dispose();
    _returnRepository.dispose();
    super.dispose();
  }

  // MARK: - Initialization

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

      await _loadReturnData();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isInitialLoading = false;
      });
    }
  }

  // MARK: - Data Management

  /// Memuat data return dari API dan memperbarui state.
  Future<void> _loadReturnData() async {
    if (_resellerId == null) return;
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final returnData = await _returnRepository.fetchReturnTransactions(
        resellerId: _resellerId!,
      );

      if (!mounted) return;
      setState(() {
        _returnData = returnData;
        _searchReturns(_searchController.text);
        _isLoading = false;
        _isInitialLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
        _isInitialLoading = false;
      });
      _showErrorSnackBar(e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Terjadi kesalahan yang tidak terduga';
        _isLoading = false;
        _isInitialLoading = false;
      });
      _showErrorSnackBar('Terjadi kesalahan yang tidak terduga');
    }
  }

  /// Memuat ulang data return dan menampilkan snackbar sukses.
  Future<void> _refreshReturns() async {
    await _loadReturnData();
    if (_errorMessage == null) {
      _showSuccessSnackBar('Data berhasil diperbarui');
    }
  }

  // MARK: - Filtering and Searching

  /// Menerapkan filter status dan pencarian berdasarkan query.
  void _searchReturns(String query) {
    if (_returnData == null) return;

    setState(() {
      var filtered = _returnData!.returnTransactions;

      // 1. Aplikasikan filter status
      if (_selectedFilter != 'Semua') {
        String statusFilter = ReturnHelpers.getStatusFromLabel(_selectedFilter);
        filtered = filtered
            .where((r) => r.status.toLowerCase() == statusFilter.toLowerCase())
            .toList();
      }

      // 2. Aplikasikan query pencarian
      if (query.isNotEmpty) {
        filtered = filtered.where((r) {
          return r.idReturnTransaction.toString().contains(query) ||
              r.idTransaction.toString().contains(query) ||
              r.getStatusLabel().toLowerCase().contains(query.toLowerCase());
        }).toList();
      }

      _filteredReturns = filtered;
    });
  }

  /// Mengubah filter status yang dipilih dan memicu pencarian ulang.
  void _filterByStatus(String filter) {
    setState(() {
      _selectedFilter = filter;
      _searchReturns(_searchController.text);
    });
  }

  // MARK: - Navigation and UI Helpers

  /// Menampilkan Snackbar dengan pesan error.
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

  /// Menampilkan Snackbar dengan pesan sukses.
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

  /// Menavigasi ke halaman detail return.
  void _navigateToDetail(ReturnTransaction returnTrans) {
    if (_resellerId == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReturnDetailPage(
          resellerId: _resellerId!,
          returnTransactionId: returnTrans.idReturnTransaction,
          returnTransaction: returnTrans,
        ),
      ),
    );
  }

  /// Menangani navigasi ke halaman buat return baru.
  Future<void> _handleCreateReturn() async {
    if (_resellerId == null) return;

    final created = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateReturnPage(resellerId: _resellerId!),
      ),
    );
    // Jika return berhasil dibuat, refresh data
    if (created == true) {
      await _refreshReturns();
    }
  }

  // MARK: - Build Method

  @override
  Widget build(BuildContext context) {
    // Loading awal saat mengambil user dari TokenManager
    if (_isInitialLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B6B)),
          ),
        ),
      );
    }

    // Error saat inisialisasi (misal user tidak ditemukan)
    if (_errorMessage != null && _resellerId == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
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
                  backgroundColor: Color(0xFFFF6B6B),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            ReturnAppBar(isLoading: _isLoading, onRefresh: _refreshReturns),

            // Search Bar
            Padding(
              padding: const EdgeInsets.all(24),
              child: ReturnSearchBar(
                controller: _searchController,
              ),
            ),

            // Filter Chips
            if (!_isLoading && _returnData != null)
              ReturnFilterChips(
                filterOptions: _filterOptions,
                selectedFilter: _selectedFilter,
                onFilterSelected: _filterByStatus,
              ),

            // Return Stats
            if (_returnData != null && !_isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ReturnStatsRow(returnData: _returnData!),
              ),

            const SizedBox(height: 24),

            // Returns List/Table Area
            Expanded(child: _buildBodyContent()),
          ],
        ),
      ),
      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: _handleCreateReturn,
        backgroundColor: const Color(0xFF2196F3),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Membangun konten utama (loading, error, kosong, atau tabel data).
  Widget _buildBodyContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState(_errorMessage!);
    }

    if (_filteredReturns.isEmpty) {
      return _buildEmptyState();
    }

    // Tampilkan Tabel Return
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daftar Return (${_filteredReturns.length})',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshReturns,
              color: const Color(0xFFFF6B6B),
              child: SingleChildScrollView(
                child: ReturnTable(
                  filteredReturns: _filteredReturns,
                  onRowTap: _navigateToDetail,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget untuk menampilkan keadaan memuat data.
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B6B)),
          ),
          const SizedBox(height: 16),
          const Text(
            'Memuat data...',
            style: TextStyle(color: Color(0xFF666666), fontSize: 14),
          ),
        ],
      ),
    );
  }

  /// Widget untuk menampilkan keadaan error.
  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Color(0xFFF44336)),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF666666), fontSize: 14),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadReturnData,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget untuk menampilkan keadaan data kosong.
  Widget _buildEmptyState() {
    final bool isFiltered =
        _searchController.text.isNotEmpty || _selectedFilter != 'Semua';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.assignment_return_outlined,
            size: 64,
            color: Color(0xFF999999),
          ),
          const SizedBox(height: 16),
          Text(
            isFiltered ? 'Return tidak ditemukan' : 'Belum ada return',
            style: const TextStyle(color: Color(0xFF666666), fontSize: 14),
          ),
        ],
      ),
    );
  }
}