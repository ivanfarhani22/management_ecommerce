import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../../config/app_config.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/loading_indicator.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailsScreen({
    super.key,
    required this.orderId,
  });

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  bool isLoading = true;
  String errorMessage = '';
  Map<String, dynamic> orderDetails = {};
  Map<String, dynamic> customerDetails = {};
  List<Map<String, dynamic>> orderItems = [];
  Map<String, dynamic> addressDetails = {};
  
  // Format for currency
  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  
  // Format for date
  final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
  
  // Status options for updating
  final List<String> statusOptions = ['Pending', 'Processing', 'Completed', 'Cancelled'];
  
  // Secure storage
  final _secureStorage = const FlutterSecureStorage();
  
  @override
  void initState() {
    super.initState();
    fetchOrderDetails();
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
  
  Future<void> fetchOrderDetails() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    
    try {
      // Get auth headers for the request
      final headers = await _getAuthHeaders();
      
      // Fetch order details
      final response = await http.get(
        Uri.parse('${AppConfig.baseApiUrl}/v1/orders/${widget.orderId}'),
        headers: headers,
      ).timeout(AppConfig.apiTimeout);
      
      if (response.statusCode == 401) {
        _handleUnauthorized();
        return;
      } else if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Check response structure (could be 'order', 'data', or direct object)
        Map<String, dynamic> orderData;
        if (data['order'] != null) {
          orderData = data['order'];
        } else if (data['data'] != null) {
          orderData = data['data'];
        } else {
          orderData = data;
        }
        
        // Extract order details
        orderDetails = {
          'id': orderData['id'].toString(),
          'status': _formatStatus(orderData['status'].toString()),
          'total_amount': double.tryParse(orderData['total_amount']?.toString() ?? '0') ?? 0.0,
          'created_at': DateTime.tryParse(orderData['created_at'] ?? '') ?? DateTime.now(),
          'payment_method': orderData['payment_method'] ?? 'N/A',
          'notes': orderData['notes'] ?? '',
          'shipping_fee': double.tryParse(orderData['shipping_fee']?.toString() ?? '0') ?? 0.0,
          // Additional fields as needed
        };
        
        // Extract user/customer details if available in order data
        if (orderData['user'] != null) {
          customerDetails = {
            'id': orderData['user']['id'].toString(),
            'name': orderData['user']['name'] ?? 'Unknown Customer',
            'email': orderData['user']['email'] ?? 'N/A',
            'phone': orderData['user']['phone'] ?? 'N/A',
          };
        } else if (orderData['user_id'] != null) {
          // Fetch user details separately if only ID is available
          await fetchCustomerDetails(orderData['user_id'].toString());
        }
        
        // Extract order items if available
        if (orderData['items'] != null) {
          List<dynamic> items = orderData['items'];
          orderItems = items.map((item) => {
            'id': item['id'].toString(),
            'product_id': item['product_id']?.toString() ?? '',
            'product_name': item['product_name'] ?? item['name'] ?? 'Unknown Product',
            'quantity': int.tryParse(item['quantity']?.toString() ?? '0') ?? 0,
            'price': double.tryParse(item['price']?.toString() ?? '0') ?? 0.0,
            'subtotal': double.tryParse(item['subtotal']?.toString() ?? item['total']?.toString() ?? '0') ?? 0.0,
            'product_image': item['product_image'] ?? '',
            // Additional fields as needed
          }).toList();
        } else if (orderData['order_items'] != null) {
          List<dynamic> items = orderData['order_items'];
          orderItems = items.map((item) => {
            'id': item['id'].toString(),
            'product_id': item['product_id']?.toString() ?? '',
            'product_name': item['product_name'] ?? item['name'] ?? 'Unknown Product',
            'quantity': int.tryParse(item['quantity']?.toString() ?? '0') ?? 0,
            'price': double.tryParse(item['price']?.toString() ?? '0') ?? 0.0,
            'subtotal': double.tryParse(item['subtotal']?.toString() ?? item['total']?.toString() ?? '0') ?? 0.0,
            'product_image': item['product_image'] ?? '',
            // Additional fields as needed
          }).toList();
        } else {
          // Fetch order items separately
          await fetchOrderItems();
        }
        
        // Extract address details if available
        if (orderData['address'] != null) {
          addressDetails = {
            'id': orderData['address']['id']?.toString() ?? '',
            'recipient_name': orderData['address']['recipient_name'] ?? orderData['address']['name'] ?? '',
            'phone': orderData['address']['phone'] ?? orderData['address']['phone_number'] ?? '',
            'address_line': orderData['address']['address_line'] ?? orderData['address']['address'] ?? '',
            'city': orderData['address']['city'] ?? '',
            'province': orderData['address']['province'] ?? '',
            'postal_code': orderData['address']['postal_code'] ?? orderData['address']['zip_code'] ?? '',
            // Additional fields as needed
          };
        } else if (orderData['shipping_address'] != null) {
          addressDetails = {
            'id': orderData['shipping_address']['id']?.toString() ?? '',
            'recipient_name': orderData['shipping_address']['recipient_name'] ?? orderData['shipping_address']['name'] ?? '',
            'phone': orderData['shipping_address']['phone'] ?? orderData['shipping_address']['phone_number'] ?? '',
            'address_line': orderData['shipping_address']['address_line'] ?? orderData['shipping_address']['address'] ?? '',
            'city': orderData['shipping_address']['city'] ?? '',
            'province': orderData['shipping_address']['province'] ?? '',
            'postal_code': orderData['shipping_address']['postal_code'] ?? orderData['shipping_address']['zip_code'] ?? '',
            // Additional fields as needed
          };
        } else if (orderData['address_id'] != null) {
          // Fetch address details separately
          await fetchAddressDetails(orderData['address_id'].toString());
        }
        
        setState(() {
          isLoading = false;
        });
      } else if (response.statusCode >= 500) {
        setState(() {
          errorMessage = 'Server Error: The server encountered an unexpected condition (${response.statusCode})';
          isLoading = false;
        });
      } else {
        try {
          final errorData = json.decode(response.body);
          setState(() {
            errorMessage = errorData['message'] ?? 'Gagal memuat detail pesanan: ${response.statusCode}';
            isLoading = false;
          });
        } catch (e) {
          setState(() {
            errorMessage = 'Gagal memuat detail pesanan: ${response.statusCode} - ${response.reasonPhrase}';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching order details: $e');
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
  
  Future<void> fetchCustomerDetails(String userId) async {
    try {
      final headers = await _getAuthHeaders();
      
      final response = await http.get(
        Uri.parse('${AppConfig.baseApiUrl}/v1/users/$userId'),
        headers: headers,
      ).timeout(AppConfig.apiTimeout);
      
      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        
        // Extract user data based on response structure
        Map<String, dynamic> user;
        if (userData['data'] != null) {
          user = userData['data'];
        } else {
          user = userData;
        }
        
        customerDetails = {
          'id': user['id'].toString(),
          'name': user['name'] ?? 'Unknown Customer',
          'email': user['email'] ?? 'N/A',
          'phone': user['phone'] ?? 'N/A',
          // Additional fields as needed
        };
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      }
    } catch (e) {
      debugPrint('Error fetching customer details: $e');
      // Set default customer details if fetch fails
      customerDetails = {
        'id': userId,
        'name': 'Customer #$userId',
        'email': 'N/A',
        'phone': 'N/A',
      };
    }
  }
  
  Future<void> fetchOrderItems() async {
    try {
      final headers = await _getAuthHeaders();
      
      final response = await http.get(
        Uri.parse('${AppConfig.baseApiUrl}/v1/orders/${widget.orderId}/items'),
        headers: headers,
      ).timeout(AppConfig.apiTimeout);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Extract items based on response structure
        List<dynamic> items;
        if (data['items'] != null) {
          items = data['items'];
        } else if (data['data'] != null) {
          items = data['data'];
        } else if (data is List) {
          items = data;
        } else {
          items = [];
        }
        
        orderItems = items.map((item) => {
          'id': item['id'].toString(),
          'product_id': item['product_id']?.toString() ?? '',
          'product_name': item['product_name'] ?? item['name'] ?? 'Unknown Product',
          'quantity': int.tryParse(item['quantity']?.toString() ?? '0') ?? 0,
          'price': double.tryParse(item['price']?.toString() ?? '0') ?? 0.0,
          'subtotal': double.tryParse(item['subtotal']?.toString() ?? item['total']?.toString() ?? '0') ?? 0.0,
          'product_image': item['product_image'] ?? '',
          // Additional fields as needed
        }).toList();
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      }
    } catch (e) {
      debugPrint('Error fetching order items: $e');
      // Keep orderItems as empty if fetch fails
    }
  }
  
  Future<void> fetchAddressDetails(String addressId) async {
    try {
      final headers = await _getAuthHeaders();
      
      final response = await http.get(
        Uri.parse('${AppConfig.baseApiUrl}/v1/addresses/$addressId'),
        headers: headers,
      ).timeout(AppConfig.apiTimeout);
      
      if (response.statusCode == 200) {
        final addressData = json.decode(response.body);
        
        // Extract address data based on response structure
        Map<String, dynamic> address;
        if (addressData['data'] != null) {
          address = addressData['data'];
        } else {
          address = addressData;
        }
        
        addressDetails = {
          'id': address['id']?.toString() ?? '',
          'recipient_name': address['recipient_name'] ?? address['name'] ?? '',
          'phone': address['phone'] ?? address['phone_number'] ?? '',
          'address_line': address['address_line'] ?? address['address'] ?? '',
          'city': address['city'] ?? '',
          'province': address['province'] ?? '',
          'postal_code': address['postal_code'] ?? address['zip_code'] ?? '',
          // Additional fields as needed
        };
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      }
    } catch (e) {
      debugPrint('Error fetching address details: $e');
      // Keep addressDetails as empty if fetch fails
    }
  }
  
  Future<void> updateOrderStatus(String newStatus) async {
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
        Uri.parse('${AppConfig.baseApiUrl}/v1/orders/${widget.orderId}/status'),
        headers: headers,
        body: json.encode({'status': apiStatus}),
      ).timeout(AppConfig.apiTimeout);

      // Pop loading dialog
      Navigator.pop(context);

      if (response.statusCode == 401) {
        _handleUnauthorized();
      } else if (response.statusCode == 200 || response.statusCode == 204) {
        // Success - refresh order details
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status pesanan berhasil diubah menjadi $newStatus'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Update local state immediately
        setState(() {
          orderDetails['status'] = _formatStatus(newStatus);
        });
        
        // Refresh data from server
        fetchOrderDetails();
      } else {
        // Handle error
        try {
          final errorData = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorData['message'] ?? 'Gagal mengubah status pesanan'),
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
  
  void _showStatusChangeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ubah Status Pesanan #${orderDetails['id']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Pilih status baru:'),
              const SizedBox(height: 16),
              ...statusOptions.map((status) => 
                ListTile(
                  title: Text(status),
                  selected: orderDetails['status'] == status,
                  onTap: () {
                    Navigator.pop(context);
                    if (orderDetails['status'] != status) {
                      updateOrderStatus(status);
                    }
                  },
                  tileColor: orderDetails['status'] == status ? Colors.grey.shade200 : null,
                  leading: Icon(_getStatusIcon(status), color: _getStatusColor(status)),
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
  
  // Format status for display
  String _formatStatus(String status) {
    // Change first character to uppercase, rest to lowercase
    if (status.isEmpty) return '';
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }

  // Get appropriate color for status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Get appropriate icon for status
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'processing':
        return Icons.sync;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }
  
  Future<void> _refreshOrderDetails() async {
    await fetchOrderDetails();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Detail Pesanan',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            color: Colors.white,
            onPressed: _refreshOrderDetails,
          ),
        ],
      ),
      body: isLoading 
          ? const Center(child: LoadingIndicator())
          : errorMessage.isNotEmpty
              ? _buildErrorView()
              : _buildOrderDetailsView(),
      floatingActionButton: !isLoading && errorMessage.isEmpty
          ? FloatingActionButton(
              onPressed: _showStatusChangeDialog,
              tooltip: 'Ubah Status',
              child: const Icon(Icons.edit),
            )
          : null,
    );
  }
  
  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              errorMessage, 
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
            onPressed: fetchOrderDetails,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildOrderDetailsView() {
    return RefreshIndicator(
      onRefresh: _refreshOrderDetails,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderHeader(),
            const SizedBox(height: 16),
            _buildStatusCard(),
            const SizedBox(height: 16),
            _buildCustomerInfo(),
            const SizedBox(height: 16),
            _buildAddressInfo(),
            const SizedBox(height: 16),
            _buildOrderItems(),
            const SizedBox(height: 16),
            _buildOrderSummary(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOrderHeader() {
    final DateTime orderDate = orderDetails['created_at'] ?? DateTime.now();
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${orderDetails['id']}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  dateFormat.format(orderDate),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Metode Pembayaran:'),
                Text(
                  orderDetails['payment_method'] ?? 'N/A',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            if (orderDetails['notes'] != null && orderDetails['notes'].toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Catatan:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                orderDetails['notes'].toString(),
                style: TextStyle(
                  color: Colors.grey[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusCard() {
    final status = orderDetails['status'] ?? 'Unknown';
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status Pesanan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: _getStatusColor(status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _getStatusColor(status)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getStatusIcon(status),
                    color: _getStatusColor(status),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    status,
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('Ubah Status'),
              onPressed: _showStatusChangeDialog,
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
                side: BorderSide(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCustomerInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Pelanggan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _infoRow(
              'Nama',
              customerDetails['name'] ?? 'Unknown Customer',
              Icons.person,
            ),
            _infoRow(
              'Email',
              customerDetails['email'] ?? 'N/A',
              Icons.email,
            ),
            _infoRow(
              'Telepon',
              customerDetails['phone'] ?? 'N/A',
              Icons.phone,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAddressInfo() {
    if (addressDetails.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Alamat Pengiriman',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _infoRow(
              'Penerima',
              addressDetails['recipient_name'] ?? 'N/A',
              Icons.person_pin_circle,
            ),
            _infoRow(
              'Telepon',
              addressDetails['phone'] ?? 'N/A',
              Icons.phone,
            ),
            _infoRow(
              'Alamat',
              addressDetails['address_line'] ?? 'N/A',
              Icons.home,
              multiLine: true,
            ),
            _infoRow(
              'Kota',
              addressDetails['city'] ?? 'N/A',
              Icons.location_city,
            ),
            _infoRow(
              'Provinsi',
              addressDetails['province'] ?? 'N/A',
              Icons.map,
            ),
            _infoRow(
              'Kode Pos',
              addressDetails['postal_code'] ?? 'N/A',
              Icons.local_post_office,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOrderItems() {
    if (orderItems.isEmpty) {
      return const Card(
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('Tidak ada item pesanan'),
          ),
        ),
      );
    }
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Item Pesanan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: orderItems.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final item = orderItems[index];
                return _buildOrderItemRow(item);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOrderItemRow(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: item['product_image'] != null && item['product_image'].toString().isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item['product_image'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                        size: 24,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                    size: 24,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['product_name'] ?? 'Unknown Product',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${currencyFormat.format(item['price'])} x ${item['quantity']}',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            currencyFormat.format(item['subtotal']),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildOrderSummary() {
    // Calculate total amount from items if available
    double itemsTotal = 0;
    for (var item in orderItems) {
      itemsTotal += item['subtotal'] ?? 0;
    }
    
    final shippingFee = orderDetails['shipping_fee'] ?? 0.0;
    final totalAmount = orderDetails['total_amount'] ?? 0.0;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ringkasan Pembayaran',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal'),
                Text(
                  currencyFormat.format(itemsTotal),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Biaya Pengiriman'),
                Text(
                  currencyFormat.format(shippingFee),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  currencyFormat.format(totalAmount),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, IconData icon, {bool multiLine = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: multiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}