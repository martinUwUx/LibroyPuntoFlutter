import 'package:flutter/material.dart';

class ChipsFilter extends StatelessWidget {
  final List<String> filters;
  final String selectedFilter;
  final Function(String) onFilterChanged;
  const ChipsFilter({super.key, required this.filters, required this.selectedFilter, required this.onFilterChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = filter == selectedFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onFilterChanged(filter);
                }
              },
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
              checkmarkColor: Theme.of(context).colorScheme.primary,
              labelStyle: Theme.of(context).textTheme.labelLarge,
            ),
          );
        }).toList(),
      ),
    );
  }
}
