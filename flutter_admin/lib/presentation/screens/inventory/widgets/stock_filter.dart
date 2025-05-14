import 'package:flutter/material.dart';

class StockFilter extends StatelessWidget {
  final String selectedCategory;
  final bool showLowStockOnly;
  final List<String> categories; // Added this parameter
  final Function(String) onCategoryChanged;
  final Function(bool) onLowStockToggle;
  final VoidCallback onApply;

  const StockFilter({
    super.key,
    required this.selectedCategory,
    required this.showLowStockOnly,
    required this.categories, // Make it required
    required this.onCategoryChanged,
    required this.onLowStockToggle,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Products',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Category',
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: selectedCategory,
              isExpanded: true,
              underline: Container(), // Remove the default underline
              onChanged: (String? value) {
                if (value != null) {
                  onCategoryChanged(value);
                }
              },
              items: categories.map<DropdownMenuItem<String>>((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                'Show Low Stock Only',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Switch(
                value: showLowStockOnly,
                onChanged: onLowStockToggle,
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onApply,
              child: const Text('Apply Filter'),
            ),
          ),
        ],
      ),
    );
  }
}