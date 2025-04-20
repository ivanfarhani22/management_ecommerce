import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import './widgets/order_filter.dart';
import 'order_details_screen.dart';
import './widgets/order_status_card.dart';
import '../../../config/app_config.dart';

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});

  @override
  _OrdersListScreenState createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;
  String errorMessage = '';
  
  String _selectedStatus = 'All';
  bool _showRecentOnly = false;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Gunakan AppConfig untuk URL API
      final response = await http.get(
        Uri.parse('${AppConfig.baseApiUrl}/v1/api/orders'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['data'] != null) {
          setState(() {
            orders = List<Map<String, dynamic>>.from(data['data'].map((order) => {
                  'id': order['id'].toString(),
                  'customer': order['user'] != null ? order['user']['name'] ?? 'Unknown Customer' : 'Unknown Customer',
                  'total': double.tryParse(order['total_amount'].toString()) ?? 0.0,
                  'status': _formatStatus(order['status'].toString()),
                  'date': DateTime.tryParse(order['created_at']) ?? DateTime.now(),
                }));
            isLoading = false;
          });
        } else {
          setState(() {
            orders = [];
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Gagal memuat pesanan: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  // Format status untuk tampilan
  String _formatStatus(String status) {
    // Ubah first character menjadi uppercase, sisanya lowercase
    if (status.isEmpty) return '';
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }

  List<Map<String, dynamic>> get filteredOrders {
    return orders.where((order) {
      // Apply status filter
      if (_selectedStatus != 'All' && 
          order['status'].toLowerCase() != _selectedStatus.toLowerCase()) {
        return false;
      }
      
      // Apply date filter
      if (_showRecentOnly) {
        final now = DateTime.now();
        final orderDate = order['date'] as DateTime;
        if (now.difference(orderDate).inDays > 7) {
          return false;
        }
      }
      
      return true;
    }).toList();
  }

  void _applyFilter(String status, bool recentOnly) {
    setState(() {
      _selectedStatus = status;
      _showRecentOnly = recentOnly;
    });
  }

  Future<void> _refreshOrders() async {
    await fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pesanan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => OrderFilter(
                  onFilterApplied: _applyFilter,
                  currentStatus: _selectedStatus,
                  showRecentOnly: _showRecentOnly,
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(errorMessage, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: fetchOrders,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refreshOrders,
                  child: filteredOrders.isEmpty
                      ? const Center(child: Text('Tidak ada pesanan ditemukan'))
                      : ListView.builder(
                          itemCount: filteredOrders.length,
                          padding: const EdgeInsets.all(8),
                          itemBuilder: (context, index) {
                            final order = filteredOrders[index];
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
                ),
    );
  }
}