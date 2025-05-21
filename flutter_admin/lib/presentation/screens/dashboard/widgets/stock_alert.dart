import 'package:flutter/material.dart';

class StockAlert extends StatelessWidget {
  final List<Map<String, dynamic>> lowStockProducts;

  const StockAlert({super.key, required this.lowStockProducts});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Low Stock Alerts',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (lowStockProducts.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'No low stock alerts at the moment',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          for (int i = 0; i < lowStockProducts.length; i++) ...[
            _buildStockAlertItem(
              productName: lowStockProducts[i]['name'],
              currentStock: lowStockProducts[i]['currentStock'],
              minimumStock: lowStockProducts[i]['minimumStock'],
            ),
            if (i < lowStockProducts.length - 1) const Divider(),
          ],
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/inventory');
            },
            child: const Text('View Full Stock Report'),
          ),
        ),
      ],
    );
  }

  Widget _buildStockAlertItem({
    required String productName,
    required int currentStock,
    required int minimumStock,
  }) {
    final isLowStock = currentStock < minimumStock;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            isLowStock ? Icons.warning_amber_rounded : Icons.check_circle,
            color: isLowStock ? Colors.orange : Colors.green,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Stock: $currentStock / $minimumStock',
                  style: TextStyle(
                    color: isLowStock ? Colors.orange : Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}