import 'package:flutter/material.dart';

class OrderDetailsScreen extends StatelessWidget {
  final String orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    // In a real app, you'd fetch order details based on orderId
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Pesanan $orderId'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Information',
              style: Theme.of(context).textTheme.titleLarge, // Replaced headline6 with titleLarge
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Order ID', orderId),
            _buildDetailRow('Customer', 'John Doe'),
            _buildDetailRow('Total', 'Rp 150,000'),
            _buildDetailRow('Status', 'Pending'),
            // Add more order details
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}