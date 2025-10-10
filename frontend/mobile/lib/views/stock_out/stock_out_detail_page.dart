// lib/views/stock_out/stock_out_detail_page.dart

import 'package:flutter/material.dart';
import 'package:mobile/services/api_client.dart';
import 'package:intl/intl.dart';
import '../../models/stock_out.dart';
import '../../models/stock_out_detail.dart';
import '../../repositories/stock_out_repository.dart';

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
                              'Detail Stock Out',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Stock Out #${widget.stockOutId}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: _isLoading ? null : _refreshDetailData,
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

            // Content
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
                            'Memuat detail...',
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
                            onPressed: _loadDetailData,
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
                  : RefreshIndicator(
                      onRefresh: _refreshDetailData,
                      color: Color(0xFF4CAF50),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Stock Out Info Card
                            _buildInfoCard(),
                            SizedBox(height: 24),

                            // Summary Stats
                            _buildSummaryStats(),
                            SizedBox(height: 24),

                            // Products Table
                            Text(
                              'Detail Produk Stock Out',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                            ),
                            SizedBox(height: 16),
                            _buildProductsTable(),
                            SizedBox(height: 24),

                            // Total Section
                            _buildTotalSection(),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                color: Color(0xFF4CAF50),
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Informasi Stock Out',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Divider(color: Color(0xFFEEEEEE)),
          SizedBox(height: 16),
          _buildInfoRow('ID Stock Out', '#${widget.stockOutId}', Icons.tag),
          SizedBox(height: 12),
          _buildInfoRow(
            'Tanggal Stock Out',
            _formatDateFull(widget.stockOut.createdAt),
            Icons.calendar_today,
          ),
          SizedBox(height: 12),
          _buildInfoRow('ID Reseller', '#${widget.resellerId}', Icons.person),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Color(0xFF4CAF50)),
        SizedBox(width: 12),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryStats() {
    if (_detailData == null) return SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Produk',
            '${_detailData!.totalProducts}',
            Icons.inventory_2_outlined,
            Color(0xFF4CAF50),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Total Kuantitas',
            '${_detailData!.totalQuantity}',
            Icons.shopping_basket_outlined,
            Color(0xFF8BC34A),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
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
          Icon(icon, color: color, size: 32),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProductsTable() {
    if (_detailData == null || _detailData!.details.isEmpty) {
      return Container(
        padding: EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'Tidak ada produk',
            style: TextStyle(color: Color(0xFF999999)),
          ),
        ),
      );
    }

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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 20,
          horizontalMargin: 20,
          headingRowHeight: 56,
          dataRowHeight: 80,
          headingRowColor: MaterialStateProperty.all(
            Color(0xFF4CAF50).withOpacity(0.1),
          ),
          columns: [
            DataColumn(
              label: Text(
                'No',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                  fontSize: 14,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Nama Produk',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                  fontSize: 14,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Harga Satuan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                  fontSize: 14,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Qty',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                  fontSize: 14,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Total Harga',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                  fontSize: 14,
                ),
              ),
            ),
          ],
          rows: _detailData!.details.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: Color(0xFF666666),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    constraints: BoxConstraints(maxWidth: 180),
                    child: Text(
                      item.productName,
                      style: TextStyle(
                        color: Color(0xFF333333),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    'Rp ${_formatPrice(item.price)}',
                    style: TextStyle(color: Color(0xFF666666)),
                  ),
                ),
                DataCell(
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${item.quantity}',
                      style: TextStyle(
                        color: Color(0xFF4CAF50),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    'Rp ${_formatPrice(item.totalHarga)}',
                    style: TextStyle(
                      color: Color(0xFF8BC34A),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTotalSection() {
    if (_detailData == null) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF4CAF50).withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Nilai Stock Out',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Rp ${_formatPrice(_detailData!.totalHargaSemua)}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateFull(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final formatter = DateFormat('dd MMMM yyyy, HH:mm', 'id_ID');
      return formatter.format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
