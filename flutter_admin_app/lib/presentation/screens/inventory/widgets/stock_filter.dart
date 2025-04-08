import 'package:flutter/material.dart';

class StockFilter extends StatefulWidget {
  final String selectedCategory;
  final bool showLowStockOnly;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<bool> onLowStockToggle;
  final VoidCallback onApply;

  const StockFilter({
    super.key,
    required this.selectedCategory,
    required this.showLowStockOnly,
    required this.onCategoryChanged,
    required this.onLowStockToggle,
    required this.onApply,
  });

  @override
  _StockFilterState createState() => _StockFilterState();
}

class _StockFilterState extends State<StockFilter> {
  // Category list
  final List<String> _categories = [
    'All',
    'Bahan Makanan',
    'Elektronik',
    'Pakaian',
    'Lainnya',
  ];

  late String _selectedCategory;
  late bool _showLowStockOnly;

  @override
  void initState() {
    super.initState();
    // Initialize local state with widget's initial values
    _selectedCategory = widget.selectedCategory;
    _showLowStockOnly = widget.showLowStockOnly;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filter Stok'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pilih Kategori',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            // Category Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (newCategory) {
                if (newCategory != null) {
                  setState(() {
                    _selectedCategory = newCategory;
                  });
                  widget.onCategoryChanged(newCategory);
                }
              },
            ),
            const SizedBox(height: 20),
            // Low Stock Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tampilkan Stok Rendah',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Switch(
                  value: _showLowStockOnly,
                  onChanged: (bool value) {
                    setState(() {
                      _showLowStockOnly = value;
                    });
                    widget.onLowStockToggle(value);
                  },
                ),
              ],
            ),
            const Spacer(),
            // Apply Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApply();
                  Navigator.of(context).pop();
                },
                child: Text('Terapkan Filter'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}