import 'package:flutter/material.dart';
import 'package:mobile/models/auth_models.dart';
import 'package:mobile/views/widgets/stock/stock_page_controller.dart';
import '../widgets/stock/stock_app_bar.dart';
import '../widgets/stock/stock_search_bar.dart';
import '../widgets/stock/stock_stats_section.dart';
import '../widgets/stock/stock_list_section.dart';
import '../widgets/stock/stock_loading_state.dart';
import '../widgets/stock/stock_error_state.dart';
import '../widgets/stock/stock_empty_state.dart';
import 'package:mobile/services/token_manager.dart'; // Pastikan ini benar

class StockPage extends StatefulWidget {
  const StockPage({Key? key}) : super(key: key);

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  StockPageController? _controller;
  int? _resellerId;
  bool _isInitialLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initPage();
  }

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

      _controller = StockPageController(resellerId: _resellerId);
      _controller!.addListener(_onStateChanged);
      await _controller!.loadStockData();
    } catch (e) {
      _errorMessage = e.toString();
    }

    setState(() {
      _isInitialLoading = false;
    });
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller!.removeListener(_onStateChanged);
      _controller!.dispose();
    }
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
    if (_isInitialLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _initPage,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final controller = _controller!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // App Bar Section
            StockAppBar(
              onBackPressed: () => Navigator.pop(context),
              onRefreshPressed: controller.isLoading
                  ? null
                  : () async {
                      await controller.refreshStockData();
                      if (!controller.hasError) {
                        _showSnackBar('Data berhasil diperbarui');
                      }
                    },
              isLoading: controller.isLoading,
            ),

            // Search Bar Section
            StockSearchBar(
              onSearchChanged: controller.searchProducts,
            ),

            // Stock Stats Section
            if (controller.stockData != null && !controller.isLoading)
              StockStatsSection(stockData: controller.stockData!),

            const SizedBox(height: 24),

            // Content Section (Loading/Error/List/Empty)
            Expanded(
              child: _buildContentSection(controller),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection(StockPageController controller) {
    if (controller.isLoading) {
      return const StockLoadingState();
    }

    if (controller.hasError) {
      return StockErrorState(
        errorMessage: controller.errorMessage,
        onRetryPressed: controller.loadStockData,
      );
    }

    if (controller.filteredProducts.isEmpty) {
      final hasSearch = controller.searchQuery.isNotEmpty;
      return StockEmptyState(
        hasSearch: hasSearch,
      );
    }

    return StockListSection(
      products: controller.filteredProducts,
      onRefresh: () async {
        await controller.refreshStockData();
        if (!controller.hasError) {
          _showSnackBar('Data berhasil diperbarui');
        }
      },
    );
  }
}
