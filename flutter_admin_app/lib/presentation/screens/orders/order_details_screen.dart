import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import '../../../data/api/order_api.dart';
import '../../../config/app_config.dart'; // Added for AppConfig

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  // Use the imported OrderService, not a local declaration
  final OrderService _orderService = OrderService();
  final _secureStorage = const FlutterSecureStorage();
  
  // Add user cache for storing user information
  final Map<String, Map<String, dynamic>> _userCache = {};
  
  bool isLoading = true;
  String errorMessage = '';
  Map<String, dynamic> orderDetails = {};
  List<Map<String, dynamic>> orderItems = [];
  Map<String, dynamic> shippingAddress = {};
  Map<String, dynamic> customerInfo = {};
  Map<String, dynamic> paymentInfo = {};
  
  // Format for currency
  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  
  // Format for date
  final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
  
  // Available status options for updating
  final List<String> statusOptions = ['pending', 'processing', 'shipped', 'delivered', 'cancelled'];
  
  @override
  void initState() {
    super.initState();
    fetchOrderDetails();
  }
  
  // Add method to get auth headers for API requests
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _secureStorage.read(key: 'auth_token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
  
  // Improved method to get user name by user_id
  Future<Map<String, dynamic>> _getUserById(String userId) async {
    // First check the cache
    if (_userCache.containsKey(userId) && 
        _userCache[userId]!.containsKey('name') && 
        _userCache[userId]!['name'] != null) {
      debugPrint('Using cached user data for user_id $userId');
      return _userCache[userId]!;
    }
    
    try {
      debugPrint('Fetching user data for user_id: $userId');
      
      // Get auth headers for the request
      final headers = await _getAuthHeaders();
      
      // Make API request to get user details
      final response = await http.get(
        Uri.parse('${AppConfig.baseApiUrl}/v1/users/$userId'),
        headers: headers,
      ).timeout(AppConfig.apiTimeout);
      
      // Log the response for debugging
      debugPrint('User API response code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        
        // Improved extraction logic with more specific error handling
        String userName;
        String userEmail = '';
        String userPhone = '';
        Map<String, dynamic> userDataMap = {};
        
        if (userData['success'] == true && userData['data'] != null) {
          // Using new API structure
          userDataMap = userData['data'];
          userName = userDataMap['name'] ?? 'Unknown User';
          userEmail = userDataMap['email'] ?? '';
          userPhone = userDataMap['phone'] ?? userDataMap['phone_number'] ?? '';
        } else if (userData['data'] != null) {
          // Old API structure - fallback
          userDataMap = userData['data'];
          userName = userDataMap['name'] ?? 'Unknown User';
          userEmail = userDataMap['email'] ?? '';
          userPhone = userDataMap['phone'] ?? userDataMap['phone_number'] ?? '';
        } else if (userData['name'] != null) {
          // Direct name field
          userName = userData['name'];
          userEmail = userData['email'] ?? '';
          userPhone = userData['phone'] ?? userData['phone_number'] ?? '';
          userDataMap = userData;
        } else {
          // Default fallback
          userName = 'Customer #$userId';
          userDataMap = {'name': userName};
        }
        
        // Create complete user info map
        Map<String, dynamic> userInfo = {
          'name': userName,
          'email': userEmail,
          'phone': userPhone,
          'data': userDataMap,
          'timestamp': DateTime.now().millisecondsSinceEpoch
        };
        
        // Store in cache
        _userCache[userId] = userInfo;
        
        debugPrint('Successfully fetched user data for $userId: $userName');
        return userInfo;
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
        return {'name': 'Customer #$userId'};
      } else {
        debugPrint('Failed to fetch user data for $userId with status code: ${response.statusCode}');
        
        // Cache the failed attempt with error info
        Map<String, dynamic> userInfo = {
          'name': 'Customer #$userId',
          'error': 'API Error: ${response.statusCode}',
          'timestamp': DateTime.now().millisecondsSinceEpoch
        };
        
        _userCache[userId] = userInfo;
        return userInfo;
      }
    } catch (e) {
      debugPrint('Error fetching user data for $userId: $e');
      
      // Cache the failed attempt with error info
      Map<String, dynamic> userInfo = {
        'name': 'Customer #$userId',
        'error': e.toString(),
        'timestamp': DateTime.now().millisecondsSinceEpoch
      };
      
      _userCache[userId] = userInfo;
      return userInfo;
    }
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
      debugPrint('Fetching order details for: ${widget.orderId}');
      
      // Use the OrderService to fetch order details
      final responseData = await _orderService.getOrderDetails(widget.orderId);
      
      // Print the entire response for debugging
      debugPrint('Response status code: ${responseData['status'] ?? 'No status'}');
      debugPrint('Response body (first 100 chars): ${responseData.toString().substring(0, min(responseData.toString().length, 100))}...');
      
      // Extract order data based on the OrderController.php structure
      // The controller returns data in the format: {'order': {...}}
      final orderData = responseData['order'];
      
      if (orderData == null) {
        setState(() {
          errorMessage = 'Invalid order data format received from server';
          isLoading = false;
        });
        return;
      }
      
      // Debug the raw data
      debugPrint('Raw order data: ${orderData.toString().substring(0, min(orderData.toString().length, 200))}...');
      
      // Parse order items - ensure we properly handle the items array
      List<Map<String, dynamic>> parsedItems = [];
      
      // Check if there are items in different possible formats
      if (orderData.containsKey('orderItems') && orderData['orderItems'] is List) {
        debugPrint('Found orderItems array with ${(orderData['orderItems'] as List).length} items');
        
        for (var item in orderData['orderItems']) {
          // Extract product details - handle potential null values
          final product = item['product'] ?? {};
          final productName = product['name'] ?? 'Product #${item['product_id'] ?? ''}';
          
          // Calculate subtotal if not provided
          double price = double.tryParse(item['price']?.toString() ?? '0') ?? 0;
          int quantity = int.tryParse(item['quantity']?.toString() ?? '0') ?? 0;
          double subtotal = double.tryParse(item['subtotal']?.toString() ?? '0') ?? (price * quantity);
          
          parsedItems.add({
            'id': item['id']?.toString() ?? '',
            'order_id': item['order_id']?.toString() ?? widget.orderId,
            'product_id': item['product_id']?.toString() ?? product['id']?.toString() ?? '',
            'product_name': productName,
            'quantity': quantity,
            'price': price,
            'subtotal': subtotal,
            'created_at': item['created_at'] ?? '',
            'updated_at': item['updated_at'] ?? '',
          });
        }
      } else if (orderData.containsKey('items') && orderData['items'] is List) {
        debugPrint('Found items array with ${(orderData['items'] as List).length} items');
        
        // Alternative path if items are stored in 'items' key instead of 'orderItems'
        for (var item in orderData['items']) {
          final product = item['product'] ?? {};
          final productName = product['name'] ?? item['product_name'] ?? 'Product #${item['product_id'] ?? ''}';
          
          double price = double.tryParse(item['price']?.toString() ?? '0') ?? 0;
          int quantity = int.tryParse(item['quantity']?.toString() ?? '0') ?? 0;
          double subtotal = double.tryParse(item['subtotal']?.toString() ?? '0') ?? (price * quantity);
          
          parsedItems.add({
            'id': item['id']?.toString() ?? '',
            'order_id': item['order_id']?.toString() ?? widget.orderId,
            'product_id': item['product_id']?.toString() ?? product['id']?.toString() ?? '',
            'product_name': productName,
            'quantity': quantity,
            'price': price,
            'subtotal': subtotal,
            'created_at': item['created_at'] ?? '',
            'updated_at': item['updated_at'] ?? '',
          });
        }
      } else {
        // Handle case where the items might be in a nested array or differently named
        debugPrint('No items array found in standard locations. Looking for alternatives...');
        
        // Try to find any key that might contain our items
        orderData.forEach((key, value) {
          if (value is List && key.toLowerCase().contains('item')) {
            debugPrint('Found potential items in key: $key');
            for (var item in value) {
              if (item is Map<String, dynamic>) {
                double price = double.tryParse(item['price']?.toString() ?? '0') ?? 0;
                int quantity = int.tryParse(item['quantity']?.toString() ?? '0') ?? 0;
                double subtotal = double.tryParse(item['subtotal']?.toString() ?? '0') ?? (price * quantity);
                
                String productName = 'Unknown Product';
                if (item.containsKey('product_name')) {
                  productName = item['product_name'] ?? 'Unknown Product';
                } else if (item.containsKey('product') && item['product'] is Map) {
                  productName = item['product']['name'] ?? 'Unknown Product';
                }
                
                parsedItems.add({
                  'id': item['id']?.toString() ?? '',
                  'product_id': item['product_id']?.toString() ?? '',
                  'product_name': productName,
                  'quantity': quantity,
                  'price': price,
                  'subtotal': subtotal,
                });
              }
            }
          }
        });
      }
      
      // If we still don't have items, check if there's a products array
      if (parsedItems.isEmpty && orderData.containsKey('products') && orderData['products'] is List) {
        debugPrint('Trying products array as fallback');
        for (var product in orderData['products']) {
          if (product is Map<String, dynamic>) {
            double price = double.tryParse(product['price']?.toString() ?? '0') ?? 0;
            int quantity = product['pivot']?['quantity'] ?? 1;
            double subtotal = price * quantity;
            
            parsedItems.add({
              'id': product['id']?.toString() ?? '',
              'product_id': product['id']?.toString() ?? '',
              'product_name': product['name'] ?? 'Unknown Product',
              'quantity': quantity,
              'price': price,
              'subtotal': subtotal,
            });
          }
        }
      }
      
      // Extract shipping address - handle multiple possible structures
      Map<String, dynamic> addressData = {};
      if (orderData.containsKey('address') && orderData['address'] is Map) {
        addressData = orderData['address'];
      } else if (orderData.containsKey('shipping_address') && orderData['shipping_address'] is Map) {
        addressData = orderData['shipping_address'];
      } else if (orderData.containsKey('shippingAddress') && orderData['shippingAddress'] is Map) {
        addressData = orderData['shippingAddress'];
      }
      
      // Debug the address data
      debugPrint('Found address data: ${addressData.toString().substring(0, min(addressData.toString().length, 100))}...');
      
      // Parse shipping address with fallbacks
      Map<String, dynamic> parsedAddress = {
        'id': addressData['id']?.toString() ?? '',
        'user_id': addressData['user_id']?.toString() ?? orderData['user_id']?.toString() ?? '',
        'street_address': addressData['street'] ?? addressData['address_line1'] ?? addressData['street_address'] ?? '',
        'city': addressData['city'] ?? '',
        'state': addressData['province'] ?? addressData['state'] ?? '',
        'postal_code': addressData['zip_code'] ?? addressData['postal_code'] ?? '',
        'country': addressData['country'] ?? 'Indonesia',
        'is_default': addressData['is_default'] ?? false,
        'created_at': addressData['created_at'] ?? '',
        'updated_at': addressData['updated_at'] ?? '',
      };
      
      // Extract payment information
      Map<String, dynamic> paymentData = {};
      if (orderData.containsKey('payment') && orderData['payment'] is Map) {
        paymentData = orderData['payment'];
      }
      
      Map<String, dynamic> parsedPayment = {
        'id': paymentData['id']?.toString() ?? '',
        'amount': double.tryParse(paymentData['amount']?.toString() ?? orderData['total_amount']?.toString() ?? '0') ?? 0,
        'status': paymentData['status'] ?? orderData['payment_status'] ?? 'pending',
        'payment_method': paymentData['payment_method'] ?? orderData['payment_method'] ?? 'Not specified',
        'created_at': paymentData['created_at'] ?? '',
      };
      
      // Extract user/customer info from the order data
      Map<String, dynamic> userData = {};
      String userId = '';
      
      // First check if user ID is available to fetch complete user data
      if (orderData.containsKey('user_id') && orderData['user_id'] != null) {
        userId = orderData['user_id'].toString();
      }
      
      // Check if user data is embedded in the order data
      if (orderData.containsKey('user') && orderData['user'] is Map) {
        debugPrint('Found user data in user key');
        userData = orderData['user'];
        if (!userId.isNotEmpty && userData['id'] != null) {
          userId = userData['id'].toString();
        }
      } else if (orderData.containsKey('customer') && orderData['customer'] is Map) {
        debugPrint('Found user data in customer key');
        userData = orderData['customer'];
        if (!userId.isNotEmpty && userData['id'] != null) {
          userId = userData['id'].toString();
        }
      }
      
      // Initialize parsed user with data from response
      Map<String, dynamic> parsedUser = {
        'id': userId,
        'name': userData['name'] ?? userData['fullname'] ?? orderData['customer_name'] ?? 'Unknown Customer',
        'email': userData['email'] ?? orderData['customer_email'] ?? '',
        'phone': userData['phone'] ?? userData['phone_number'] ?? orderData['customer_phone'] ?? '',
      };
      
      // Fetch additional user data if we have a user ID and incomplete information
      if (userId.isNotEmpty) {
        debugPrint('User ID found: $userId, fetching complete user data');
        try {
          final userInfo = await _getUserById(userId);
          
          // Update with more complete information if available
          if (userInfo.containsKey('name') && userInfo['name'] != 'Customer #$userId') {
            parsedUser['name'] = userInfo['name'];
          }
          
          if (userInfo.containsKey('email') && userInfo['email'].isNotEmpty) {
            parsedUser['email'] = userInfo['email'];
          }
          
          if (userInfo.containsKey('phone') && userInfo['phone'].isNotEmpty) {
            parsedUser['phone'] = userInfo['phone'];
          }
          
          debugPrint('Updated user data: ${parsedUser.toString()}');
        } catch (e) {
          debugPrint('Error fetching additional user data: $e');
          // Continue with existing data
        }
      } else {
        debugPrint('No user ID found, using order data for customer info');
      }
      
      setState(() {
        orderDetails = {
          'id': orderData['id']?.toString() ?? widget.orderId,
          'user_id': userId,
          'address_id': orderData['address_id']?.toString() ?? orderData['shipping_address_id']?.toString() ?? '',
          'total_amount': double.tryParse(orderData['total']?.toString() ?? orderData['total_amount']?.toString() ?? '0') ?? 0,
          'status': orderData['status']?.toString()?.toLowerCase() ?? 'pending',
          'created_at': orderData['created_at'] ?? '',
          'updated_at': orderData['updated_at'] ?? '',
          'payment_status': paymentData['status'] ?? orderData['payment_status'] ?? 'pending',
          'payment_method': orderData['payment_method'] ?? paymentData['payment_method'] ?? 'Not specified',
          'notes': orderData['notes'] ?? orderData['order_notes'] ?? '',
        };
        
        orderItems = parsedItems;
        shippingAddress = parsedAddress;
        paymentInfo = parsedPayment;
        customerInfo = parsedUser;
        isLoading = false;
        
        // Debug output to help diagnose issues
        debugPrint('Parsed ${orderItems.length} order items');
        debugPrint('Customer name: ${customerInfo['name']}');
        debugPrint('Shipping address street: ${shippingAddress['street_address']}');
      });
    } catch (e) {
      debugPrint('Error fetching order details: $e');
      
      // Handle specific errors
      if (e.toString().contains('Unauthorized')) {
        _handleUnauthorized();
        return;
      }
      
      setState(() {
        if (e.toString().contains('SocketException') || 
            e.toString().contains('Connection refused') ||
            e.toString().contains('Connection timed out')) {
          errorMessage = 'Cannot connect to server. Please check your internet connection.';
        } else {
          errorMessage = 'Error: ${e.toString()}';
        }
        isLoading = false;
      });
    }
  }
  
  Future<void> updateOrderStatus(String newStatus) async {
    // Validate the newStatus
    final String apiStatus = newStatus.toLowerCase();
    
    // Check if status is valid
    if (!statusOptions.contains(apiStatus)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid status: $newStatus'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
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
      
      // Use OrderService to update status
      final result = await _orderService.updateOrderStatus(widget.orderId, apiStatus);
      
      // Pop loading dialog
      Navigator.pop(context);
      
      // Update the local order status
      setState(() {
        orderDetails['status'] = apiStatus;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order status updated to ${_formatStatus(newStatus)}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Pop loading dialog if still showing
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      debugPrint('Exception when updating order status: $e');
      
      // Handle unauthorized
      if (e.toString().contains('Unauthorized')) {
        _handleUnauthorized();
        return;
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // Format status for display
  String _formatStatus(String status) {
    // Change first character to uppercase, rest to lowercase
    if (status.isEmpty) return '';
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }
  
  // Get status color based on status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.indigo;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  // Helper function to get minimum of two integers
  int min(int a, int b) {
    return a < b ? a : b;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${widget.orderId}'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? _buildErrorView()
              : _buildOrderDetailsView(),
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
            label: const Text('Try Again'),
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
    // Format order date
    DateTime? orderDate;
    try {
      orderDate = DateTime.parse(orderDetails['created_at']);
    } catch (e) {
      orderDate = null;
    }
    
    return RefreshIndicator(
      onRefresh: fetchOrderDetails,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order summary card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order #${widget.orderId}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        _buildStatusBadge(orderDetails['status']),
                      ],
                    ),
                    const Divider(height: 24),
                    if (orderDate != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              'Order Date: ${dateFormat.format(orderDate)}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    Row(
                      children: [
                        const Icon(Icons.payments_outlined, size: 18, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          'Payment: ${_formatStatus(orderDetails['payment_status'])} (${orderDetails['payment_method']})',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount:',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          currencyFormat.format(orderDetails['total_amount']),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    if (orderDetails['notes']?.isNotEmpty == true) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Notes:',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        orderDetails['notes'],
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Customer information
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Customer Information',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Divider(height: 24),
                    Text(
                      'Name: ${customerInfo['name'] ?? 'Unknown Customer'}',
                      style: const TextStyle(fontSize: 15),
                    ),
                    if (customerInfo['email']?.isNotEmpty == true)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Email: ${customerInfo['email']}',
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    if (customerInfo['phone']?.isNotEmpty == true)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Phone: ${customerInfo['phone']}',
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    if (orderDetails['user_id']?.isNotEmpty == true)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Customer ID: ${orderDetails['user_id']}',
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        ),
                      ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Shipping Address
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Shipping Address',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Divider(height: 24),
                    // Show shipping address details even if some fields are empty
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (shippingAddress['street_address']?.isNotEmpty == true) 
                          Text(
                            '${shippingAddress['street_address']}',
                            style: const TextStyle(fontSize: 15),
                          )
                        else
                          const Text(
                            'Address: Not provided',
                            style: TextStyle(fontSize: 15),
                          ),
                        const SizedBox(height: 4),
                        if (shippingAddress['city']?.isNotEmpty == true || 
                            shippingAddress['state']?.isNotEmpty == true || 
                            shippingAddress['postal_code']?.isNotEmpty == true)
                          Text(
                            '${shippingAddress['city'] ?? ''}, ${shippingAddress['state'] ?? ''} ${shippingAddress['postal_code'] ?? ''}',
                            style: const TextStyle(fontSize: 15),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          shippingAddress['country'] ?? 'Indonesia',
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Order items
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Order Items',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${orderItems.length} items',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    if (orderItems.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'No items found for this order',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: orderItems.length,
                        separatorBuilder: (context, index) => const Divider(height: 24),
                        itemBuilder: (context, index) {
                          final item = orderItems[index];
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Item image or placeholder
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[200],
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.inventory_2,
                                    color: Colors.grey[400],
                                    size: 24,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Item details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['product_name'] ?? 'Unknown Product',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${item['quantity']} x ${currencyFormat.format(item['price'])}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Item subtotal
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    currencyFormat.format(item['subtotal']),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'ID: ${item['product_id']}',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      // Subtotal and other price details
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Amount'),
                          Text(
                            currencyFormat.format(orderDetails['total_amount']),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Actions section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Actions',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Divider(height: 24),
                    
                    // Update status section
                    const Text(
                      'Update Status:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (String status in statusOptions)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ElevatedButton(
                                onPressed: status == orderDetails['status']
                                    ? null
                                    : () => updateOrderStatus(status),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _getStatusColor(status),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: status == orderDetails['status']
                                      ? _getStatusColor(status)
                                      : null,
                                  disabledForegroundColor: status == orderDetails['status']
                                      ? Colors.white.withOpacity(0.8)
                                      : null,
                                ),
                                child: Text(_formatStatus(status)),
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    
                    // Other actions
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.receipt),
                          label: const Text('Generate Invoice'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => _generateInvoice(),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.share),
                          label: const Text('Share Order'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _shareOrder,
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.email),
                          label: const Text('Contact Customer'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[700],
                            foregroundColor: Colors.white,
                          ),
                          onPressed: customerInfo['email']?.isNotEmpty == true
                              ? () => _contactCustomer()
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
  
  // Status badge widget
  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _formatStatus(status),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
  
  // Generate invoice PDF
  Future<void> _generateInvoice() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generating invoice...'),
              ],
            ),
          );
        },
      );
      
      // Create a PDF document
      final pdf = pw.Document();
      
      // Format order date
      String formattedDate = 'N/A';
      try {
        final orderDate = DateTime.parse(orderDetails['created_at']);
        formattedDate = dateFormat.format(orderDate);
      } catch (e) {
        debugPrint('Error parsing date: $e');
      }
      
      // Add page to PDF
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'INVOICE',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text('Order #${widget.orderId}'),
                        pw.Text('Date: $formattedDate'),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'Your Company Name',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text('your@email.com'),
                        pw.Text('Company Address'),
                        pw.Text('Phone: +123456789'),
                      ],
                    ),
                  ],
                ),
                
                pw.SizedBox(height: 30),
                
                // Customer Information
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Bill To:',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                          pw.Text(customerInfo['name'] ?? 'Unknown Customer'),
                          if (customerInfo['email']?.isNotEmpty == true)
                            pw.Text(customerInfo['email']),
                          if (customerInfo['phone']?.isNotEmpty == true)
                            pw.Text(customerInfo['phone']),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Ship To:',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                          pw.Text(shippingAddress['street_address'] ?? 'No address provided'),
                          pw.Text('${shippingAddress['city'] ?? ''}, ${shippingAddress['state'] ?? ''} ${shippingAddress['postal_code'] ?? ''}'),
                          pw.Text(shippingAddress['country'] ?? 'Indonesia'),
                        ],
                      ),
                    ),
                  ],
                ),
                
                pw.SizedBox(height: 20),
                
                // Invoice Details
                pw.Text(
                  'Order Details',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                
                // Table Header
                pw.Container(
                  color: PdfColors.grey300,
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        flex: 5,
                        child: pw.Text(
                          'Product',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          'Quantity',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          'Price',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          'Amount',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Table Content
                ...orderItems.map((item) {
                  return pw.Container(
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(
                        bottom: pw.BorderSide(color: PdfColors.grey300),
                      ),
                    ),
                    padding: const pw.EdgeInsets.symmetric(vertical: 8),
                    child: pw.Row(
                      children: [
                        pw.Expanded(
                          flex: 5,
                          child: pw.Text(item['product_name'] ?? 'Unknown Product'),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            '${item['quantity']}',
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            'Rp ${item['price']}',
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            'Rp ${item['subtotal']}',
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                
                pw.SizedBox(height: 10),
                
                // Total
                pw.Row(
                  children: [
                    pw.Spacer(flex: 7),
                    pw.Expanded(
                      flex: 4,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                        children: [
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                'Total:',
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                              ),
                              pw.Text(
                                'Rp ${orderDetails['total_amount']}',
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                pw.SizedBox(height: 30),
                
                // Payment Info
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Payment Information',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text('Payment Method: ${orderDetails['payment_method']}'),
                      pw.Text('Payment Status: ${_formatStatus(orderDetails['payment_status'])}'),
                      pw.Text('Order Status: ${_formatStatus(orderDetails['status'])}'),
                    ],
                  ),
                ),
                
                pw.SizedBox(height: 20),
                
                // Notes
                pw.Text(
                  'Thank you for your business!',
                  style: pw.TextStyle(
                    fontStyle: pw.FontStyle.italic,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            );
          },
        ),
      );
      
      // Get the directory for saving PDF
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/invoice_${widget.orderId}.pdf');
      
      // Save the PDF file
      await file.writeAsBytes(await pdf.save());
      
      // Close loading dialog
      Navigator.pop(context);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invoice generated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Open the PDF
      await OpenFile.open(file.path);
    } catch (e) {
      // Close loading dialog if still showing
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      debugPrint('Error generating invoice: $e');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // Share order details
  void _shareOrder() {
    try {
      // Format the share text
      String shareText = 'Order #${widget.orderId}\n';
      shareText += 'Status: ${_formatStatus(orderDetails['status'])}\n';
      shareText += 'Customer: ${customerInfo['name']}\n';
      shareText += 'Total Amount: ${currencyFormat.format(orderDetails['total_amount'])}\n\n';
      
      // Add items to share text
      shareText += 'Items:\n';
      for (final item in orderItems) {
        shareText += '- ${item['quantity']} x ${item['product_name']} (${currencyFormat.format(item['price'])} each)\n';
      }
      
      // Share order details
      Share.share(shareText);
    } catch (e) {
      debugPrint('Error sharing order: $e');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // Contact customer via email
  void _contactCustomer() async {
    if (customerInfo['email']?.isEmpty ?? true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No email address available for this customer'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Create email URI
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: customerInfo['email'],
      queryParameters: {
        'subject': 'Regarding your order #${widget.orderId}',
        'body': 'Dear ${customerInfo['name']},\n\nThank you for your order #${widget.orderId}.\n\n',
      },
    );
    
    // Open email app
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        throw 'Could not launch email app';
      }
    } catch (e) {
      debugPrint('Error launching email: $e');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}