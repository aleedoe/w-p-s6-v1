// ============================================================================
// lib/pages/order_page/widgets/order_filter_chips.dart
// ============================================================================

import 'package:flutter/material.dart';

class OrderFilterChips extends StatelessWidget {
  final List<String> options;
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const OrderFilterChips({
    Key? key,
    required this.options,
    required this.selectedFilter,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: EdgeInsets.only(bottom: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 24),
        itemCount: options.length,
        itemBuilder: (context, index) {
          final filter = options[index];
          final isSelected = selectedFilter == filter;
          return GestureDetector(
            onTap: () => onFilterChanged(filter),
            child: Container(
              margin: EdgeInsets.only(right: 8),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Color(0xFF2196F3) : Colors.white,
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
                    color: isSelected ? Colors.white : Color(0xFF666666),
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
    );
  }
}
