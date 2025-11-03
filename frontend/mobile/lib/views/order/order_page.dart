// lib/pages/order_page/order_page.dart
import 'package:flutter/material.dart';
import 'package:mobile/services/api_client.dart';
import 'package:mobile/services/token_manager.dart';
import 'package:mobile/models/auth_models.dart';
import 'package:mobile/views/widgets/order/order_app_bar.dart';
import 'package:mobile/views/widgets/order/transaction_stats.dart';
import 'package:mobile/views/widgets/order/transaction_table.dart';
import '../../models/transaction.dart';
import '../../repositories/transaction_repository.dart';
import './create_order_page.dart';
import './transaction_detail_page.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({Key? key}) : super(key: key);

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  late TransactionRepository _transactionRepository;
  final TextEditingController _searchController = TextEditingController();

  TransactionResponse? _transactionData;
  List<Transaction> _filteredTransactions = [];
  int? _resellerId;
  bool _isInitialLoading = true;
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    _transactionRepository = TransactionRepository();
    _initPage();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _transactionRepository.dispose();
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

      await _loadTransactionData();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isInitialLoading = false;
      });
    }
  }

  /// Memuat data transaksi dari API
  Future<void> _loadTransactionData() async {
    if (_resellerId == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final transactionData = await _transactionRepository.fetchTransactions(
        resellerId: _resellerId!,
      );

      setState(() {
        _transactionData = transactionData;
        _filteredTransactions = transactionData.transactions;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      _handleApiError(e.message);
    } catch (e) {
      _handleApiError('Terjadi kesalahan yang tidak terduga');
    }
  }

  /// Menangani error dari API
  void _handleApiError(String message) {
    setState(() {
      _errorMessage = message;
      _isLoading = false;
    });
    _showErrorSnackBar(message);
  }

  /// Merefresh data transaksi
  Future<void> _refreshTransactions() async {
    await _loadTransactionData();
    if (_errorMessage == null) {
      _showSuccessSnackBar('Data berhasil diperbarui');
    }
  }


  /// Menampilkan snackbar error
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Menampilkan snackbar sukses
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Navigasi ke halaman detail transaksi
  void _navigateToDetail(Transaction transaction) {
    if (_resellerId == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionDetailPage(
          resellerId: _resellerId!,
          transactionId: transaction.idTransaction,
          transaction: transaction,
        ),
      ),
    );
  }

  /// Navigasi ke halaman membuat order baru
  Future<void> _navigateToCreateOrder() async {
    if (_resellerId == null) return;

    final created = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateOrderPage(resellerId: _resellerId!),
      ),
    );

    if (created == true) {
      await _refreshTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Loading awal saat mengambil user dari TokenManager
    if (_isInitialLoading) {
      return Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
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
                  backgroundColor: Color(0xFF2196F3),
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
            OrderAppBar(
              onBackPressed: () => Navigator.pop(context),
              onRefresh: _isLoading ? null : _refreshTransactions,
              isLoading: _isLoading,
            ),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateOrder,
        backgroundColor: Color(0xFF2196F3),
        child: Icon(Icons.add),
      ),
    );
  }

  /// Membangun konten utama halaman
  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 16),
          if (_transactionData != null) ...[
            SizedBox(height: 24),
            TransactionStats(transactionData: _transactionData!),
            SizedBox(height: 24),
          ],
          _buildTransactionsList(),
        ],
      ),
    );
  }

  /// Membangun widget loading state
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
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

  /// Membangun widget error state
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
            onPressed: _loadTransactionData,
            icon: Icon(Icons.refresh),
            label: Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2196F3),
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

  /// Membangun daftar transaksi
  Widget _buildTransactionsList() {
    if (_filteredTransactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Color(0xFF999999),
            ),
            SizedBox(height: 16),
            Text(
              _searchController.text.isNotEmpty || _selectedFilter != 'Semua'
                  ? 'Transaksi tidak ditemukan'
                  : 'Belum ada transaksi',
              style: TextStyle(color: Color(0xFF666666), fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daftar Transaksi (${_filteredTransactions.length})',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          SizedBox(height: 16),
          RefreshIndicator(
            onRefresh: _refreshTransactions,
            color: Color(0xFF2196F3),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: TransactionTable(
                  transactions: _filteredTransactions,
                  onRowTap: _navigateToDetail,
                ),
              ),
            ),
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}
