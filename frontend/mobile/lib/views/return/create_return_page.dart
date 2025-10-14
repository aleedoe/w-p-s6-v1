// lib/views/return/create_return_page.dart
import 'package:flutter/material.dart';
import 'package:mobile/views/widgets/return/create_return1/create_return_provider.dart';
import 'package:mobile/views/widgets/return/create_return1/transaction_list_widget.dart';
import '../../repositories/create_return_repository.dart';
import '../../views/widgets/return/create_return1/return_app_bar.dart';
import '../../views/widgets/return/create_return1/search_bar_widget.dart';

 
class CreateReturnPage extends StatefulWidget {
  final int resellerId;

  const CreateReturnPage({Key? key, required this.resellerId})
      : super(key: key);

  @override
  State<CreateReturnPage> createState() => _CreateReturnPageState();
}

class _CreateReturnPageState extends State<CreateReturnPage> {
  late CreateReturnProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = CreateReturnProvider(
      resellerId: widget.resellerId,
      repository: CreateReturnRepository(),
    );
    _provider.loadCompletedTransactions();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            ReturnAppBar(
              isLoading: _provider.isLoading,
              onRefresh: _provider.refreshTransactions,
              onBack: () => Navigator.pop(context),
            ),
            SearchBarWidget(
              controller: _provider.searchController,
              onChanged: _provider.searchTransactions,
            ),
            Expanded(
              child: TransactionListWidget(
                provider: _provider,
                onTransactionSelected: (transaction) {
                  _provider.loadTransactionDetail(
                    transaction,
                    context,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}