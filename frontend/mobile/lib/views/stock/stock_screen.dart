// ============================================
// FILE 1: lib/pages/stock_page.dart
// ============================================
import 'package:flutter/material.dart';
import 'package:mobile/views/widgets/stock/stock_page_controller.dart';
import '../widgets/stock/stock_app_bar.dart';
import '../widgets/stock/stock_search_bar.dart';
import '../widgets/stock/stock_stats_section.dart';
import '../widgets/stock/stock_list_section.dart';
import '../widgets/stock/stock_loading_state.dart';
import '../widgets/stock/stock_error_state.dart';
import '../widgets/stock/stock_empty_state.dart';


class StockPage extends StatefulWidget {
  final int? resellerId;

  const StockPage({Key? key, this.resellerId}) : super(key: key);

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  late StockPageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = StockPageController(resellerId: widget.resellerId);
    _controller.addListener(_onStateChanged);
    _controller.loadStockData();
  }

  @override
  void dispose() {
    _controller.removeListener(_onStateChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    setState(() {});
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // App Bar Section
            StockAppBar(
              onBackPressed: () => Navigator.pop(context),
              onRefreshPressed: _controller.isLoading
                  ? null
                  : () async {
                      await _controller.refreshStockData();
                      if (!_controller.hasError) {
                        _showSnackBar('Data berhasil diperbarui');
                      }
                    },
              isLoading: _controller.isLoading,
            ),

            // Search Bar Section
            StockSearchBar(
              onSearchChanged: _controller.searchProducts,
            ),

            // Stock Stats Section
            if (_controller.stockData != null && !_controller.isLoading)
              StockStatsSection(stockData: _controller.stockData!),

            const SizedBox(height: 24),

            // Content Section (Loading/Error/List/Empty)
            Expanded(
              child: _buildContentSection(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    if (_controller.isLoading) {
      return const StockLoadingState();
    }

    if (_controller.hasError) {
      return StockErrorState(
        errorMessage: _controller.errorMessage,
        onRetryPressed: _controller.loadStockData,
      );
    }

    if (_controller.filteredProducts.isEmpty) {
      final hasSearch = _controller.searchQuery.isNotEmpty;
      return StockEmptyState(
        hasSearch: hasSearch,
      );
    }

    return StockListSection(
      products: _controller.filteredProducts,
      onRefresh: () async {
        await _controller.refreshStockData();
        if (!_controller.hasError) {
          _showSnackBar('Data berhasil diperbarui');
        }
      },
    );
  }
}