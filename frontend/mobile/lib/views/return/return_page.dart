// lib/views/return/return_page.dart
import 'package:flutter/material.dart';
import 'package:mobile/services/api_client.dart';
import 'package:intl/intl.dart';
import '../../models/return_transaction.dart';
import '../../repositories/return_repository.dart';
import './return_detail_page.dart';

class ReturnPage extends StatefulWidget {
  final int? resellerId;

  const ReturnPage({Key? key, this.resellerId}) : super(key: key);

  @override
  State<ReturnPage> createState() => _ReturnPageState();
}

class _ReturnPageState extends State<ReturnPage> {
  final ReturnRepository _returnRepository = ReturnRepository();
  final TextEditingController _searchController = TextEditingController();

  ReturnTransactionResponse? _returnData;
  List<ReturnTransaction> _filteredReturns = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedFilter = 'Semua';

  final List<String> _filterOptions = [
    'Semua',
    'Disetujui',
    'Menunggu',
    'Diproses',
    'Ditolak',
  ];

  @override
  void initState() {
    super.initState();
    _loadReturnData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _returnRepository.dispose();
    super.dispose();
  }

  // Load return data from API
  Future<void> _loadReturnData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final returnData = await _returnRepository.fetchReturnTransactions(
        resellerId: widget.resellerId ?? 1,
      );

      setState(() {
        _returnData = returnData;
        _filteredReturns = returnData.returnTransactions;
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

  // Refresh return data
  Future<void> _refreshReturns() async {
    await _loadReturnData();
    if (_errorMessage == null) {
      _showSuccessSnackBar('Data berhasil diperbarui');
    }
  }

  // Search returns
  void _searchReturns(String query) {
    if (_returnData == null) return;

    setState(() {
      var filtered = _returnData!.returnTransactions;

      // Apply status filter
      if (_selectedFilter != 'Semua') {
        String statusFilter = _getStatusFromLabel(_selectedFilter);
        filtered = filtered
            .where((r) => r.status.toLowerCase() == statusFilter.toLowerCase())
            .toList();
      }

      // Apply search query
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

  // Filter by status
  void _filterByStatus(String filter) {
    setState(() {
      _selectedFilter = filter;
      _searchReturns(_searchController.text);
    });
  }

  String _getStatusFromLabel(String label) {
    switch (label) {
      case 'Disetujui':
        return 'approved';
      case 'Menunggu':
        return 'pending';
      case 'Diproses':
        return 'processing';
      case 'Ditolak':
        return 'rejected';
      default:
        return '';
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

  void _navigateToDetail(ReturnTransaction returnTrans) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReturnDetailPage(
          resellerId: widget.resellerId ?? 1,
          returnTransactionId: returnTrans.idReturnTransaction,
          returnTransaction: returnTrans,
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
                  colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
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
                              'Manajemen Return',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Kelola return produk',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: _isLoading ? null : _refreshReturns,
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
                  onChanged: _searchReturns,
                  decoration: InputDecoration(
                    hintText: 'Cari berdasarkan ID Return atau ID Transaksi...',
                    hintStyle: TextStyle(color: Color(0xFF999999)),
                    prefixIcon: Icon(Icons.search, color: Color(0xFFFF6B6B)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ),

            // Filter Chips
            if (!_isLoading && _returnData != null)
              Container(
                height: 50,
                margin: EdgeInsets.only(bottom: 16),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _filterOptions.length,
                  itemBuilder: (context, index) {
                    final filter = _filterOptions[index];
                    final isSelected = _selectedFilter == filter;
                    return GestureDetector(
                      onTap: () => _filterByStatus(filter),
                      child: Container(
                        margin: EdgeInsets.only(right: 8),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? Color(0xFFFF6B6B) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            filter,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Color(0xFF666666),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Return Stats
            if (_returnData != null && !_isLoading)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Return',
                        '${_returnData!.totalReturns}',
                        Icons.assignment_return_outlined,
                        Color(0xFFFF6B6B),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Disetujui',
                        '${_returnData!.approvedReturns}',
                        Icons.check_circle_outline,
                        Color(0xFF4CAF50),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Menunggu',
                        '${_returnData!.pendingReturns}',
                        Icons.access_time,
                        Color(0xFFFF9800),
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(height: 24),

            // Returns Table
            Expanded(
              child: _isLoading
                  ? Center(
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
                            onPressed: _loadReturnData,
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
                    )
                  : _filteredReturns.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_return_outlined,
                            size: 64,
                            color: Color(0xFF999999),
                          ),
                          SizedBox(height: 16),
                          Text(
                            _searchController.text.isNotEmpty ||
                                    _selectedFilter != 'Semua'
                                ? 'Return tidak ditemukan'
                                : 'Belum ada return',
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
                            'Daftar Return (${_filteredReturns.length})',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                          SizedBox(height: 16),
                          Expanded(
                            child: RefreshIndicator(
                              onRefresh: _refreshReturns,
                              color: Color(0xFFFF6B6B),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: _buildReturnTable(),
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

  Widget _buildReturnTable() {
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
          Color(0xFFFF6B6B).withOpacity(0.1),
        ),
        columns: [
          DataColumn(
            label: Text(
              'ID Return',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF6B6B),
                fontSize: 14,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'ID Transaksi',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF6B6B),
                fontSize: 14,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Tgl Return',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF6B6B),
                fontSize: 14,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Status',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF6B6B),
                fontSize: 14,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Total Qty',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF6B6B),
                fontSize: 14,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Aksi',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF6B6B),
                fontSize: 14,
              ),
            ),
          ),
        ],
        rows: _filteredReturns.map((returnTrans) {
          return DataRow(
            cells: [
              DataCell(
                Text(
                  '#${returnTrans.idReturnTransaction}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                onTap: () => _navigateToDetail(returnTrans),
              ),
              DataCell(
                Text(
                  '#${returnTrans.idTransaction}',
                  style: TextStyle(
                    color: Color(0xFF666666),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () => _navigateToDetail(returnTrans),
              ),
              DataCell(
                Text(
                  _formatDate(returnTrans.returnDate),
                  style: TextStyle(color: Color(0xFF666666)),
                ),
                onTap: () => _navigateToDetail(returnTrans),
              ),
              DataCell(
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(returnTrans.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    returnTrans.getStatusLabel(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(returnTrans.status),
                    ),
                  ),
                ),
                onTap: () => _navigateToDetail(returnTrans),
              ),
              DataCell(
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(0xFFFF6B6B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${returnTrans.totalQuantity}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF6B6B),
                    ),
                  ),
                ),
                onTap: () => _navigateToDetail(returnTrans),
              ),
              DataCell(
                IconButton(
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: Color(0xFFFF6B6B),
                  ),
                  onPressed: () => _navigateToDetail(returnTrans),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Color(0xFF4CAF50);
      case 'pending':
        return Color(0xFFFF9800);
      case 'processing':
        return Color(0xFF2196F3);
      case 'rejected':
        return Color(0xFFF44336);
      default:
        return Color(0xFF999999);
    }
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
