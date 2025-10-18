// lib/views/laporan_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/report_models.dart';
import '../models/auth_models.dart';
import '../repositories/report_repository.dart';
import '../services/token_manager.dart';
import 'custom_navbar.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({Key? key}) : super(key: key);

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  final ReportRepository _reportRepository = ReportRepository();
  ReportResponse? _reportData;
  bool _isLoading = true;
  String? _errorMessage;
  final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get current user
      final User? user = await TokenManager.getUser();

      if (user == null) {
        throw Exception('User tidak ditemukan. Silakan login kembali.');
      }

      // Fetch report data
      final reportData = await _reportRepository.getReport(user.id);

      setState(() {
        _reportData = reportData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Belum ada data';
    return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadReportData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Laporan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Analisis & Statistik Bisnis',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(24),
                  child: _isLoading
                      ? _buildLoadingState()
                      : _errorMessage != null
                      ? _buildErrorState()
                      : _buildReportContent(),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const CustomNavBar(selectedIndex: 1),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(48.0),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            'Gagal Memuat Data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Terjadi kesalahan',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadReportData,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent() {
    if (_reportData == null) {
      return const Center(child: Text('Data tidak tersedia'));
    }

    final summary = _reportData!.summary;

    return Column(
      children: [
        // Last Activity Info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    color: Color(0xFF4CAF50),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Aktivitas Terakhir',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Transaksi',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF666666),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(_reportData!.lastTransactionDate),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Stock Out',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF666666),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(_reportData!.lastStockOutDate),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Statistik Cards
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Transaksi',
                summary.totalTransactions.toString(),
                Icons.shopping_bag,
                const Color(0xFF2196F3),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Total Stock Out',
                summary.totalStockOut.toString(),
                Icons.inventory_2,
                const Color(0xFF4CAF50),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Barang Diambil',
                summary.totalItemsTaken.toString(),
                Icons.local_shipping,
                const Color(0xFFFF9800),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Total Return',
                summary.totalReturns.toString(),
                Icons.keyboard_return,
                const Color(0xFFF44336),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Stok Sekarang',
                summary.currentStock.toString(),
                Icons.inventory,
                const Color(0xFF9C27B0),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Sell Through Rate',
                '${summary.sellThroughRate}%',
                Icons.trending_up,
                const Color(0xFF00BCD4),
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),

        // Performance Summary
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.analytics, color: Color(0xFF4CAF50), size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Ringkasan Performa',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildPerformanceItem(
                'Return Rate',
                _reportData!.formattedReturnRate,
                _reportData!.returnRate < 5 ? Colors.green : Colors.orange,
              ),
              const Divider(height: 24),
              _buildPerformanceItem(
                'Efisiensi Stok',
                '${((summary.totalItemsTaken / (summary.totalItemsTaken + summary.currentStock)) * 100).toStringAsFixed(1)}%',
                const Color(0xFF4CAF50),
              ),
              const Divider(height: 24),
              _buildPerformanceItem(
                'Rata-rata per Transaksi',
                summary.totalTransactions > 0
                    ? (summary.totalItemsTaken / summary.totalTransactions)
                          .toStringAsFixed(1)
                    : '0',
                const Color(0xFF2196F3),
              ),
            ],
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceItem(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _reportRepository.dispose();
    super.dispose();
  }
}
