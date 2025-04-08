import 'package:flutter/material.dart';
import './widgets/order_filter.dart';
import 'order_details_screen.dart';
import './widgets/order_status_card.dart';

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});

  @override
  _OrdersListScreenState createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  List<Map<String, dynamic>> orders = [
    // Sample order data
    {
      'id': '001',
      'customer': 'John Doe',
      'total': 150000,
      'status': 'Pending',
      'date': DateTime.now(),
    },
    // Add more sample orders
  ];

  String _selectedStatus = 'All';
  bool _showRecentOnly = false;

  void _applyFilter(String status, bool recentOnly) {
    setState(() {
      _selectedStatus = status;
      _showRecentOnly = recentOnly;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Pesanan'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => OrderFilter(
                  onFilterApplied: _applyFilter,
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderDetailsScreen(orderId: order['id']),
                ),
              );
            },
            child: OrderStatusCard(
              orderNumber: order['id'],
              customerName: order['customer'],
              total: order['total'],
              status: order['status'],
              date: order['date'],
            ),
          );
        },
      ),
    );
  }
}