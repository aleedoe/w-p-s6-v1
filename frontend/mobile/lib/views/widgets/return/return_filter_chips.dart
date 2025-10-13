// lib/views/return/widgets/return_filter_chips.dart
import 'package:flutter/material.dart';

class ReturnFilterChips extends StatelessWidget {
  final List<String> filterOptions;
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;

  const ReturnFilterChips({
    Key? key,
    required this.filterOptions,
    required this.selectedFilter,
    required this.onFilterSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: filterOptions.length,
        itemBuilder: (context, index) {
          final filter = filterOptions[index];
          final isSelected = selectedFilter == filter;
          return GestureDetector(
            onTap: () => onFilterSelected(filter),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFF6B6B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF666666),
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
