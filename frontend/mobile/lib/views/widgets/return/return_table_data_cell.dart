// lib/views/return/widgets/return_table_data_cell.dart
import 'package:flutter/material.dart';
import '../../../models/return_transaction.dart';

class ReturnTableDataCell extends StatelessWidget {
  final Widget child;
  final ReturnTransaction returnTrans;
  final ValueChanged<ReturnTransaction> onTap;

  const ReturnTableDataCell({
    Key? key,
    required this.child,
    required this.returnTrans,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(returnTrans),
      child: child,
    );
  }
}
