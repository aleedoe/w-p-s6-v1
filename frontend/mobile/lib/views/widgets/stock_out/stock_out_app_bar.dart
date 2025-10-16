// ===================================================================
// lib/views/stock_out/widgets/stock_out_app_bar.dart
// ===================================================================

import 'package:flutter/material.dart';

/// Custom App Bar untuk halaman Stock Out
/// Menampilkan judul, subtitle, tombol back dan refresh
class StockOutAppBar extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onRefresh;
  final VoidCallback onBack;

  const StockOutAppBar({
    Key? key,
    required this.isLoading,
    required this.onRefresh,
    required this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Row(
        children: [
          _buildBackButton(),
          SizedBox(width: 16),
          Expanded(child: _buildTitle()),
          _buildRefreshButton(),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: onBack,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.arrow_back, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
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
          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildRefreshButton() {
    return GestureDetector(
      onTap: isLoading ? null : onRefresh,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(Icons.refresh, color: Colors.white, size: 24),
      ),
    );
  }
}
