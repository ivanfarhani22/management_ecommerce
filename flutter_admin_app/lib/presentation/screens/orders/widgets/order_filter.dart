import 'package:flutter/material.dart';

class OrderFilter extends StatefulWidget {
  final Function(String, bool) onFilterApplied;
  final String currentStatus;
  final bool showRecentOnly;

  const OrderFilter({
    super.key,
    required this.onFilterApplied,
    this.currentStatus = 'All',
    this.showRecentOnly = false,
  });

  @override
  _OrderFilterState createState() => _OrderFilterState();
}

class _OrderFilterState extends State<OrderFilter> {
  late String _status;
  late bool _recentOnly;

  @override
  void initState() {
    super.initState();
    _status = widget.currentStatus;
    _recentOnly = widget.showRecentOnly;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Pesanan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Status Pesanan:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            children: [
              _buildFilterChip('All'),
              _buildFilterChip('Pending'),
              _buildFilterChip('Processing'),
              _buildFilterChip('Shipped'),
              _buildFilterChip('Delivered'),
              _buildFilterChip('Cancelled'),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Hanya tampilkan pesanan 7 hari terakhir'),
            value: _recentOnly,
            onChanged: (value) {
              setState(() {
                _recentOnly = value;
              });
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Batal'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  widget.onFilterApplied(_status, _recentOnly);
                  Navigator.pop(context);
                },
                child: const Text('Terapkan'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String status) {
    final isSelected = _status == status;
    return FilterChip(
      label: Text(status),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _status = status;
        });
      },
      backgroundColor: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }
}