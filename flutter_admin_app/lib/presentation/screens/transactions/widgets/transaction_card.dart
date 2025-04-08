import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionCard extends StatelessWidget {
  final String transactionId;
  final String type;
  final double amount;
  final DateTime date;

  const TransactionCard({
    super.key,
    required this.transactionId,
    required this.type,
    required this.amount,
    required this.date,
  });

  Color _getTransactionColor(String type) {
    switch (type.toLowerCase()) {
      case 'penjualan':
        return Colors.green;
      case 'pembelian':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transaksi #$transactionId',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getTransactionColor(type),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    type,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  NumberFormat.currency(
                    locale: 'id_ID',
                    symbol: 'Rp ',
                    decimalDigits: 0,
                  ).format(amount),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getTransactionColor(type),
                  ),
                ),
                Text(
                  DateFormat('dd MMM yyyy HH:mm').format(date),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}