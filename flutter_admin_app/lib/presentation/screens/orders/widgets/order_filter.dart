import 'package:flutter/material.dart';

class OrderFilter extends StatefulWidget {
  final Function(String status, bool recentOnly) onFilterApplied;

  const OrderFilter({super.key, required this.onFilterApplied});

  @override
  _OrderFilterState createState() => _OrderFilterState();
}

class _OrderFilterState extends State<OrderFilter> {
  String _selectedStatus = 'All';
  bool _showRecentOnly = false;

  final List<String> _statusOptions = [
    'All',
    'Pending',
    'Completed',
    'Cancelled',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Pesanan',
            style: Theme.of(context).textTheme.titleLarge, // Replaced headline6 with titleLarge
          ),
          const SizedBox(height: 16),
          const Text('Status Pesanan'),
          DropdownButtonFormField<String>(
            value: _selectedStatus,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(),
            ),
            items: _statusOptions.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(status),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedStatus = value ?? 'All';
              });
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tampilkan Pesanan Terbaru'),
              Switch(
                value: _showRecentOnly,
                onChanged: (value) {
                  setState(() {
                    _showRecentOnly = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onFilterApplied(_selectedStatus, _showRecentOnly);
                Navigator.pop(context);
              },
              child: const Text('Terapkan Filter'),
            ),
          ),
        ],
      ),
    );
  }
}