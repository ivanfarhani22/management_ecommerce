import 'package:flutter/material.dart';

class TrendingProducts extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;

  const TrendingProducts({
    super.key,
    this.startDate,
    this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trending Products',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (startDate != null && endDate != null)
              Text(
                'From ${startDate!.toLocal()} to ${endDate!.toLocal()}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Product ${index + 1}'),
                  trailing: Text('${(5 - index) * 20}% Growth'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}