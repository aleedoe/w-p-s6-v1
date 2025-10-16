// ===================================================================
// lib/views/stock_out/widgets/stock_out_error_state.dart
// ===================================================================
import 'package:flutter/material.dart';

/// Widget untuk menampilkan error state
class StockOutErrorState extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const StockOutErrorState({
    Key? key,
    required this.errorMessage,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Color(0xFFF44336)),
          SizedBox(height: 16),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF666666), fontSize: 14),
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
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
}
