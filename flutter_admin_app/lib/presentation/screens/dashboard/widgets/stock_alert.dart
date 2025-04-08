import 'package:flutter/material.dart';

class StockAlert extends StatelessWidget {
  const StockAlert({super.key});

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
        _buildStockAlertItem(
          productName: 'Beras Premium',
          currentStock: 50,
          minimumStock: 100,
        ),
        const Divider(),
        _buildStockAlertItem(
          productName: 'Minyak Goreng',
          currentStock: 20,
          minimumStock: 75,
        ),
        const Divider(),
        _buildStockAlertItem(
          productName: 'Gula Pasir',
          currentStock: 35,
          minimumStock: 80,
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: () {
              // TODO: Navigate to full stock report
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