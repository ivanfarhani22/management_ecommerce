import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WholesaleItemCard extends StatelessWidget {
  final String customerName;
  final double totalAmount;
  final DateTime date;
  final VoidCallback onTap;

  const WholesaleItemCard({
    super.key,
    required this.customerName,
    required this.totalAmount,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: onTap,
        title: Text(
          customerName,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              NumberFormat.currency(
                locale: 'id_ID',
                symbol: 'Rp ',
                decimalDigits: 0,
              ).format(totalAmount),
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              DateFormat('dd MMM yyyy HH:mm').format(date),
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        trailing: Icon(Icons.chevron_right),
      ),
    );
  }
}