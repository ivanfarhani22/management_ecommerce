import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
  final _secureStorage = const FlutterSecureStorage();
  
  // Available status options for updating
  final List<String> statusOptions = ['Pending', 'Processing', 'Completed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    // Get token from secure storage
    final token = await _secureStorage.read(key: 'auth_token');
    
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}',
    };
  }

  void _handleUnauthorized() {
    // Delete token because it's no longer valid
    _secureStorage.delete(key: 'auth_token');
    
    // Show dialog and redirect to login page
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Sesi Berakhir'),
        content: const Text('Silakan login kembali untuk melanjutkan.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to login page and remove all previous routes
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> fetchOrders() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Get auth headers for the request
      final headers = await _getAuthHeaders();

      debugPrint('Fetching orders from: ${AppConfig.baseApiUrl}/v1/orders');
      
      // Use AppConfig for API URL with timeout
      final response = await http.get(
        Uri.parse('${AppConfig.baseApiUrl}/v1/orders'),
        headers: headers,
      ).timeout(AppConfig.apiTimeout);

      debugPrint('Status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body.substring(0, min(100, response.body.length))}...');

      // Check if response is HTML instead of JSON (server error page)
      if (response.body.trim().startsWith('<!DOCTYPE html>') ||
          response.body.trim().startsWith('<html>')) {
        throw FormatException('Received HTML instead of JSON. Server might be returning an error page.');
      }

      if (response.statusCode == 401) {
        // Handle unauthorized case - redirect to login
        _handleUnauthorized();
        throw Exception('Unauthorized: Please login again');
      } else if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // FIX: Check for 'orders' field instead of 'data'
        if (data['orders'] != null) {
          setState(() {
            orders = List<Map<String, dynamic>>.from(data['orders'].map((order) => {
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
      } else if (response.statusCode >= 500) {
        setState(() {
          errorMessage = 'Server Error: The server encountered an unexpected condition (${response.statusCode})';
          isLoading = false;
        });
      } else {
        Map<String, dynamic>? errorData;
        try {
          errorData = json.decode(response.body);
          setState(() {
            errorMessage = errorData?['message'] ?? 'Gagal memuat pesanan: ${response.statusCode}';
            isLoading = false;
          });
        } catch (e) {
          setState(() {
            errorMessage = 'Gagal memuat pesanan: ${response.statusCode} - ${response.reasonPhrase}';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      setState(() {
        if (e.toString().contains('SocketException') || 
            e.toString().contains('Connection refused') ||
            e.toString().contains('Connection timed out')) {
          errorMessage = 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
        } else {
          errorMessage = 'Error: ${e.toString()}';
        }
        isLoading = false;
      });
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      final headers = await _getAuthHeaders();
      
      // Convert status to match backend format (lowercase)
      final apiStatus = newStatus.toLowerCase();
      
      // Send PUT request to update status
      final response = await http.put(
        Uri.parse('${AppConfig.baseApiUrl}/v1/orders/$orderId/status'),
        headers: headers,
        body: json.encode({'status': apiStatus}),
      ).timeout(AppConfig.apiTimeout);

      // Pop loading dialog
      Navigator.pop(context);

      if (response.statusCode == 401) {
        _handleUnauthorized();
        return;
      } else if (response.statusCode == 200 || response.statusCode == 204) {
        // Success - refresh the orders list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status pesanan berhasil diubah menjadi $newStatus')),
        );
        fetchOrders();
      } else {
        // Handle error
        Map<String, dynamic>? errorData;
        try {
          errorData = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorData?['message'] ?? 'Gagal mengubah status pesanan'),
              backgroundColor: Colors.red,
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal mengubah status pesanan: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Pop loading dialog if still showing
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showStatusChangeDialog(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ubah Status Pesanan #${order['id']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Pilih status baru:'),
              const SizedBox(height: 16),
              ...statusOptions.map((status) => 
                ListTile(
                  title: Text(status),
                  selected: order['status'] == status,
                  onTap: () {
                    Navigator.pop(context);
                    if (order['status'] != status) {
                      updateOrderStatus(order['id'], status);
                    }
                  },
                  tileColor: order['status'] == status ? Colors.grey.shade200 : null,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  int min(int a, int b) {
    return a < b ? a : b;
  }

  // Format status for display
  String _formatStatus(String status) {
    // Change first character to uppercase, rest to lowercase
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          errorMessage, 
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
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
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                              child: Column(
                                children: [
                                  InkWell(
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
                                  ),
                                  const Divider(height: 1),
                                  // Button to change status
                                  TextButton.icon(
                                    icon: const Icon(Icons.edit),
                                    label: const Text('Ubah Status'),
                                    onPressed: () => _showStatusChangeDialog(order),
                                    style: TextButton.styleFrom(
                                      minimumSize: const Size.fromHeight(40),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
    );
  }
}