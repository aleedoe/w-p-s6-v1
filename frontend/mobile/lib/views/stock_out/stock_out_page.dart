// lib/views/stock_out/stock_out_page.dart

import 'package:flutter/material.dart';
import 'package:mobile/services/api_client.dart';
import 'package:intl/intl.dart';
import 'package:mobile/models/stock_out.dart';
import 'package:mobile/repositories/stock_out_repository.dart';
import './stock_out_detail_page.dart';

class StockOutPage extends StatefulWidget {
  final int? resellerId;

  const StockOutPage({Key? key, this.resellerId}) : super(key: key);

  @override
  State<StockOutPage> createState() => _StockOutPageState();
}

class _StockOutPageState extends State<StockOutPage> {
  final StockOutRepository _stockOutRepository = StockOutRepository();
  final TextEditingController _searchController = TextEditingController();

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

  Future<void> _refreshStockOuts() async {
    await _loadStockOutData();
    if (_errorMessage == null) {
      _showSuccessSnackBar('Data berhasil diperbarui');
    }
  }

  void _searchStockOuts(String query) {
    if (_stockOutData == null) return;

    setState(() {
      _filteredStockOuts = _stockOutRepository.searchStockOuts(
        _stockOutData!.stockOuts,
        query,
      );
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Manajemen Stock Out',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Kelola pengeluaran stok',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: _isLoading ? null : _refreshStockOuts,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _isLoading
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
                              : Icon(
                                  Icons.refresh,
                                  color: Colors.white,
                                  size: 24,
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: EdgeInsets.all(24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _searchStockOuts,
                  decoration: InputDecoration(
                    hintText: 'Cari berdasarkan ID Stock Out...',
                    hintStyle: TextStyle(color: Color(0xFF999999)),
                    prefixIcon: Icon(Icons.search, color: Color(0xFF4CAF50)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ),

            // Stock Out Stats
            if (_stockOutData != null && !_isLoading)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Stock Out',
                        '${_stockOutData!.totalStockOuts}',
                        Icons.inventory_2_outlined,
                        Color(0xFF4CAF50),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Total Produk',
                        '${_stockOutData!.stockOuts.fold<int>(0, (sum, s) => sum + s.totalProducts)}',
                        Icons.shopping_bag_outlined,
                        Color(0xFF8BC34A),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Total Qty',
                        '${_stockOutData!.stockOuts.fold<int>(0, (sum, s) => sum + s.totalQuantity)}',
                        Icons.stacked_line_chart,
                        Color(0xFFAED581),
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(height: 24),

            // Stock Out Table
            Expanded(
              child: _isLoading
                  ? Center(
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
                    )
                  : _errorMessage != null
                  ? Center(
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
                            onPressed: _loadStockOutData,
                            icon: Icon(Icons.refresh),
                            label: Text('Coba Lagi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF4CAF50),
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
                    )
                  : _filteredStockOuts.isEmpty
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
                            _searchController.text.isNotEmpty
                                ? 'Stock out tidak ditemukan'
                                : 'Belum ada stock out',
                            style: TextStyle(
                              color: Color(0xFF666666),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Padding(
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
                                  child: _buildStockOutTable(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 11, color: Color(0xFF666666)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStockOutTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: DataTable(
        columnSpacing: 24,
        horizontalMargin: 24,
        headingRowHeight: 56,
        dataRowHeight: 64,
        headingRowColor: MaterialStateProperty.all(
          Color(0xFF4CAF50).withOpacity(0.1),
        ),
        columns: [
          DataColumn(
            label: Text(
              'ID Stock Out',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50),
                fontSize: 14,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Tanggal',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50),
                fontSize: 14,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Total Produk',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50),
                fontSize: 14,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Total Qty',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50),
                fontSize: 14,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Aksi',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50),
                fontSize: 14,
              ),
            ),
          ),
        ],
        rows: _filteredStockOuts.map((stockOut) {
          return DataRow(
            cells: [
              DataCell(
                Text(
                  '#${stockOut.idStockOut}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                onTap: () => _navigateToDetail(stockOut),
              ),
              DataCell(
                Text(
                  _formatDate(stockOut.createdAt),
                  style: TextStyle(color: Color(0xFF666666)),
                ),
                onTap: () => _navigateToDetail(stockOut),
              ),
              DataCell(
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${stockOut.totalProducts}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                ),
                onTap: () => _navigateToDetail(stockOut),
              ),
              DataCell(
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(0xFF8BC34A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${stockOut.totalQuantity}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8BC34A),
                    ),
                  ),
                ),
                onTap: () => _navigateToDetail(stockOut),
              ),
              DataCell(
                IconButton(
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: Color(0xFF4CAF50),
                  ),
                  onPressed: () => _navigateToDetail(stockOut),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final formatter = DateFormat('dd/MM/yy HH:mm', 'id_ID');
      return formatter.format(date);
    } catch (e) {
      return dateString;
    }
  }
}
