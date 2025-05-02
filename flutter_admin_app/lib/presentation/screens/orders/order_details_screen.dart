import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../config/app_config.dart';
import '../../widgets/app_bar.dart';
import './widgets/order_timeline.dart';
import './widgets/order_item_card.dart';
import './widgets/customer_details_card.dart';
import './widgets/payment_details_card.dart';
import './widgets/shipping_details_card.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailsScreen({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  bool isLoading = true;
  bool isUpdating = false;
  String errorMessage = '';
  Map<String, dynamic> orderDetails = {};
  List<Map<String, dynamic>> orderItems = [];
  Map<String, dynamic> customerData = {};
  Map<String, dynamic> shippingData = {};
  Map<String, dynamic> paymentData = {};
  
  // For tracking status changes
  String currentStatus = '';
  String statusUpdateError = '';
  bool isLoadingPdf = false;
  
  // Order status options - ensure these match backend values
  final List<String> statusOptions = ['pending', 'processing', 'shipped', 'delivered', 'cancelled'];
  
  // Format for currency
  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  
  // Format for date
  final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
  
  // Secure storage for auth token
  final _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    fetchOrderDetails();
  }
  
  // Get auth headers with token
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _secureStorage.read(key: 'auth_token');
    
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}',
    };
  }
  
  // Handle unauthorized response
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

  // Fetch order details from API
  Future<void> fetchOrderDetails() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final headers = await _getAuthHeaders();
      
      final response = await http.get(
        Uri.parse('${AppConfig.baseApiUrl}/v1/orders/${widget.orderId}'),
        headers: headers,
      ).timeout(AppConfig.apiTimeout);
      
      if (response.statusCode == 401) {
        _handleUnauthorized();
        return;
      } else if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Extract order data based on API response structure
        Map<String, dynamic> orderData;
        if (data['order'] != null) {
          orderData = data['order'];
        } else if (data['data'] != null) {
          orderData = data['data'];
        } else if (data is Map<String, dynamic> && data.containsKey('id')) {
          orderData = data;
        } else {
          throw Exception('Unexpected API response structure');
        }
        
        // Extract customer data
        Map<String, dynamic> customer = {};
        if (orderData['user'] != null) {
          customer = orderData['user'];
        } else if (orderData['customer'] != null) {
          customer = orderData['customer'];
        } else {
          // If no detailed customer info, try to fetch it
          customer = await _fetchCustomerDetails(orderData['user_id']?.toString() ?? '');
        }
        
        // Extract order items
        List<Map<String, dynamic>> items = [];
        if (orderData['items'] != null && orderData['items'] is List) {
          for (var item in orderData['items']) {
            items.add(_normalizeOrderItem(item));
          }
        } else if (orderData['order_items'] != null && orderData['order_items'] is List) {
          for (var item in orderData['order_items']) {
            items.add(_normalizeOrderItem(item));
          }
        }
        
        // Extract shipping data
        Map<String, dynamic> shipping = {};
        if (orderData['shipping'] != null) {
          shipping = orderData['shipping'];
        } else if (orderData['shipping_address'] != null) {
          shipping = {
            'address': orderData['shipping_address'],
            'method': orderData['shipping_method'] ?? 'Standard Delivery',
            'tracking_number': orderData['tracking_number'],
            'tracking_url': orderData['tracking_url'],
            'courier': orderData['courier'] ?? 'Default Courier',
          };
        }
        
        // Extract payment data
        Map<String, dynamic> payment = {};
        if (orderData['payment'] != null) {
          payment = orderData['payment'];
        } else {
          payment = {
            'method': orderData['payment_method'] ?? 'Unknown',
            'status': orderData['payment_status'] ?? 'pending',
            'transaction_id': orderData['transaction_id'] ?? 'Unknown',
            'amount': orderData['total_amount'] ?? orderData['total'] ?? 0,
            'currency': orderData['currency'] ?? 'IDR',
            'payment_date': orderData['payment_date'] ?? orderData['created_at'],
          };
        }
        
        // Normalize status
        String status = orderData['status']?.toString().toLowerCase() ?? 'pending';
        
        // Validate status - if invalid, default to 'pending'
        if (!statusOptions.contains(status)) {
          debugPrint('Invalid status detected: $status. Using default: pending');
          status = 'pending';
        }
        
        // Update state with data
        setState(() {
          orderDetails = orderData;
          orderItems = items;
          customerData = customer;
          shippingData = shipping;
          paymentData = payment;
          currentStatus = status;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load order details: ${response.statusCode}';
          isLoading = false;
        });
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
  
  // Normalize order item structure
  Map<String, dynamic> _normalizeOrderItem(dynamic item) {
    // Get product data
    String productName = '';
    String productImage = '';
    String productSku = '';
    
    if (item['product'] != null) {
      final product = item['product'];
      productName = product['name'] ?? product['title'] ?? 'Unknown Product';
      productImage = product['image'] ?? product['image_url'] ?? '';
      productSku = product['sku'] ?? product['code'] ?? '';
    } else {
      productName = item['name'] ?? item['product_name'] ?? 'Unknown Product';
      productImage = item['image'] ?? item['image_url'] ?? '';
      productSku = item['sku'] ?? item['product_sku'] ?? '';
    }
    
    // Get price and quantity
    double price = 0.0;
    if (item['price'] != null) {
      price = double.tryParse(item['price'].toString()) ?? 0.0;
    } else if (item['unit_price'] != null) {
      price = double.tryParse(item['unit_price'].toString()) ?? 0.0;
    }
    
    int quantity = item['quantity'] != null ? int.tryParse(item['quantity'].toString()) ?? 1 : 
      (item['qty'] != null ? int.tryParse(item['qty'].toString()) ?? 1 : 1);
    
    double subtotal = price * quantity;
    
    // Get variations/options
    List<Map<String, dynamic>> variations = [];
    if (item['variations'] != null && item['variations'] is List) {
      for (var variation in item['variations']) {
        variations.add({
          'name': variation['name'] ?? variation['option_name'] ?? 'Option',
          'value': variation['value'] ?? variation['option_value'] ?? 'Value',
        });
      }
    } else if (item['options'] != null && item['options'] is Map) {
      item['options'].forEach((key, value) {
        variations.add({
          'name': key,
          'value': value.toString(),
        });
      });
    }
    
    return {
      'id': item['id']?.toString() ?? '',
      'product_id': item['product_id']?.toString() ?? '',
      'name': productName,
      'image': productImage,
      'sku': productSku,
      'price': price,
      'quantity': quantity,
      'subtotal': subtotal,
      'variations': variations,
      'notes': item['notes'] ?? item['customer_notes'] ?? '',
    };
  }
  
  // Fetch customer details if not provided in order
  Future<Map<String, dynamic>> _fetchCustomerDetails(String userId) async {
    if (userId.isEmpty) {
      return {'name': 'Unknown Customer'};
    }
    
    try {
      final headers = await _getAuthHeaders();
      
      final response = await http.get(
        Uri.parse('${AppConfig.baseApiUrl}/v1/users/$userId'),
        headers: headers,
      ).timeout(AppConfig.apiTimeout);
      
      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        
        // Extract user data based on API response structure
        Map<String, dynamic> user = {};
        if (userData['data'] != null) {
          user = userData['data'];
        } else if (userData is Map<String, dynamic> && userData.containsKey('name')) {
          user = userData;
        } else {
          return {'name': 'Customer #$userId'};
        }
        
        return user;
      } else {
        return {'name': 'Customer #$userId'};
      }
    } catch (e) {
      debugPrint('Error fetching customer details: $e');
      return {'name': 'Customer #$userId'};
    }
  }
  
  // Update order status
  Future<void> updateOrderStatus(String newStatus) async {
    if (newStatus == currentStatus) {
      return; // No change needed
    }
    
    // Validate the new status
    if (!statusOptions.contains(newStatus)) {
      setState(() {
        statusUpdateError = 'Invalid status: $newStatus';
      });
      return;
    }
    
    setState(() {
      isUpdating = true;
      statusUpdateError = '';
    });
    
    try {
      final headers = await _getAuthHeaders();
      
      final response = await http.put(
        Uri.parse('${AppConfig.baseApiUrl}/v1/orders/${widget.orderId}/status'),
        headers: headers,
        body: json.encode({'status': newStatus}),
      ).timeout(AppConfig.apiTimeout);
      
      if (response.statusCode == 401) {
        _handleUnauthorized();
        return;
      } else if (response.statusCode == 200 || response.statusCode == 204) {
        // Success - update local state
        setState(() {
          currentStatus = newStatus;
          isUpdating = false;
        });
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status pesanan berhasil diubah menjadi ${_formatStatus(newStatus)}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Try to parse error message
        String errorMsg = 'Failed to update order status';
        
        try {
          final errorData = json.decode(response.body);
          if (errorData['message'] != null) {
            errorMsg = errorData['message'];
          } else if (errorData['error'] != null) {
            errorMsg = errorData['error'];
          }
        } catch (e) {
          errorMsg = 'Failed to update order status: ${response.statusCode}';
        }
        
        setState(() {
          statusUpdateError = errorMsg;
          isUpdating = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        statusUpdateError = e.toString();
        isUpdating = false;
      });
      
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
    if (status.isEmpty) return '';
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }
  
  // Get color for status
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
  
  // Format date with fallback
  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return 'Unknown date';
    
    DateTime? date;
    if (dateValue is DateTime) {
      date = dateValue;
    } else if (dateValue is String) {
      date = DateTime.tryParse(dateValue);
    }
    
    if (date == null) return 'Invalid date';
    
    return dateFormat.format(date);
  }
  
  // Calculate order totals
  Map<String, dynamic> _calculateOrderTotals() {
    double subtotal = 0.0;
    for (var item in orderItems) {
      subtotal += item['subtotal'];
    }
    
    double shipping = 0.0;
    if (orderDetails['shipping_cost'] != null) {
      shipping = double.tryParse(orderDetails['shipping_cost'].toString()) ?? 0.0;
    } else if (shippingData['cost'] != null) {
      shipping = double.tryParse(shippingData['cost'].toString()) ?? 0.0;
    }
    
    double tax = 0.0;
    if (orderDetails['tax'] != null) {
      tax = double.tryParse(orderDetails['tax'].toString()) ?? 0.0;
    }
    
    double discount = 0.0;
    if (orderDetails['discount'] != null) {
      discount = double.tryParse(orderDetails['discount'].toString()) ?? 0.0;
    }
    
    double total = 0.0;
    if (orderDetails['total_amount'] != null) {
      total = double.tryParse(orderDetails['total_amount'].toString()) ?? 0.0;
    } else if (orderDetails['total'] != null) {
      total = double.tryParse(orderDetails['total'].toString()) ?? 0.0;
    } else {
      total = subtotal + shipping + tax - discount;
    }
    
    return {
      'subtotal': subtotal,
      'shipping': shipping,
      'tax': tax,
      'discount': discount,
      'total': total,
    };
  }
  
  // Generate and share order invoice PDF
  Future<void> generateInvoicePdf() async {
    setState(() {
      isLoadingPdf = true;
    });
    
    // Request storage permission for Android
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
        if (!status.isGranted) {
          setState(() {
            isLoadingPdf = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Storage permission is required to save invoice'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
    }
    
    try {
      final pdf = pw.Document();
      final totals = _calculateOrderTotals();
      
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          header: (pw.Context context) {
            return pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'INVOICE',
                    style: pw.TextStyle(
                      fontSize: 28,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Invoice #${widget.orderId}',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'Date: ${_formatDate(orderDetails['created_at'])}',
                        style: const pw.TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
          build: (pw.Context context) {
            return [
              pw.SizedBox(height: 20),
              
              // Customer & Company Info
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Bill To:',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(customerData['name'] ?? 'Unknown Customer'),
                        pw.Text(customerData['email'] ?? 'No email provided'),
                        pw.Text(customerData['phone'] ?? 'No phone provided'),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'Company Name',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text('company@example.com'),
                        pw.Text('+1 234 567 890'),
                        pw.Text('123 Street Name, City'),
                      ],
                    ),
                  ),
                ],
              ),
              
              pw.SizedBox(height: 30),
              
              // Status
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey200,
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Order Status:',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      _formatStatus(currentStatus),
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 20),
              
              // Items Table
              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColors.grey300,
                  width: 1,
                ),
                columnWidths: {
                  0: const pw.FlexColumnWidth(1),
                  1: const pw.FlexColumnWidth(4),
                  2: const pw.FlexColumnWidth(1),
                  3: const pw.FlexColumnWidth(2),
                  4: const pw.FlexColumnWidth(2),
                },
                children: [
                  // Table Header
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey200,
                    ),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'No.',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Description',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Qty',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Price',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                          ),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Subtotal',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                          ),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  
                  // Table Rows for Items
                  ...orderItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    
                    String itemDescription = item['name'];
                    if ((item['variations'] as List).isNotEmpty) {
                      List<String> variationStrings = [];
                      for (var variation in item['variations']) {
                        variationStrings.add('${variation['name']}: ${variation['value']}');
                      }
                      itemDescription += '\n${variationStrings.join(', ')}';
                    }
                    
                    if (item['sku'].isNotEmpty) {
                      itemDescription += '\nSKU: ${item['sku']}';
                    }
                    
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('${index + 1}'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(itemDescription),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            '${item['quantity']}',
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Rp ${NumberFormat('#,###').format(item['price'])}',
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Rp ${NumberFormat('#,###').format(item['subtotal'])}',
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
              
              pw.SizedBox(height: 20),
              
              // Totals
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Row(
                      mainAxisSize: pw.MainAxisSize.min,
                      children: [
                        pw.Container(
                          width: 150,
                          child: pw.Text('Subtotal'),
                        ),
                        pw.Container(
                          width: 100,
                          child: pw.Text(
                            'Rp ${NumberFormat('#,###').format(totals['subtotal'])}',
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 5),
                    pw.Row(
                      mainAxisSize: pw.MainAxisSize.min,
                      children: [
                        pw.Container(
                          width: 150,
                          child: pw.Text('Shipping'),
                        ),
                        pw.Container(
                          width: 100,
                          child: pw.Text(
                            'Rp ${NumberFormat('#,###').format(totals['shipping'])}',
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    if (totals['tax'] > 0) ...[
                      pw.SizedBox(height: 5),
                      pw.Row(
                        mainAxisSize: pw.MainAxisSize.min,
                        children: [
                          pw.Container(
                            width: 150,
                            child: pw.Text('Tax'),
                          ),
                          pw.Container(
                            width: 100,
                            child: pw.Text(
                              'Rp ${NumberFormat('#,###').format(totals['tax'])}',
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (totals['discount'] > 0) ...[
                      pw.SizedBox(height: 5),
                      pw.Row(
                        mainAxisSize: pw.MainAxisSize.min,
                        children: [
                          pw.Container(
                            width: 150,
                            child: pw.Text('Discount'),
                          ),
                          pw.Container(
                            width: 100,
                            child: pw.Text(
                              '- Rp ${NumberFormat('#,###').format(totals['discount'])}',
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ],
                    pw.Divider(),
                    pw.Row(
                      mainAxisSize: pw.MainAxisSize.min,
                      children: [
                        pw.Container(
                          width: 150,
                          child: pw.Text(
                            'TOTAL',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        pw.Container(
                          width: 100,
                          child: pw.Text(
                            'Rp ${NumberFormat('#,###').format(totals['total'])}',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                            ),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 40),
              
              // Payment Details
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Payment Details',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text('Method: ${paymentData['method'] ?? 'Unknown'}'),
                    pw.Text('Status: ${_formatStatus(paymentData['status'] ?? 'pending')}'),
                    if (paymentData['transaction_id'] != null) 
                      pw.Text('Transaction ID: ${paymentData['transaction_id']}'),
                    if (paymentData['payment_date'] != null) 
                      pw.Text('Date: ${_formatDate(paymentData['payment_date'])}'),
                  ],
                ),
              ),
              
             pw.SizedBox(height: 20),
              
              // Shipping Details
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Shipping Details',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text('Method: ${shippingData['method'] ?? 'Standard Delivery'}'),
                    pw.Text('Courier: ${shippingData['courier'] ?? 'Default Courier'}'),
                    if (shippingData['tracking_number'] != null) 
                      pw.Text('Tracking Number: ${shippingData['tracking_number']}'),
                    if (shippingData['address'] != null) 
                      pw.Text('Address: ${shippingData['address']}'),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 40),
              
              // Thank You Note
              pw.Center(
                child: pw.Text(
                  'Thank you for your business!',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              
              pw.SizedBox(height: 10),
              
              pw.Center(
                child: pw.Text(
                  'For any questions regarding this invoice, please contact support@example.com',
                  style: const pw.TextStyle(
                    fontSize: 10,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ];
          },
          footer: (pw.Context context) {
            return pw.Footer(
              leading: pw.Text(
                'Generated on ${DateTime.now().toString().split('.')[0]}',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey700,
                ),
              ),
              trailing: pw.Text(
                'Page ${context.pageNumber} of ${context.pagesCount}',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey700,
                ),
              ),
            );
          },
        ),
      );
      
      // Save the PDF to a file
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/Order_${widget.orderId}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());
      
      // Share the PDF
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Order Invoice #${widget.orderId}',
        text: 'Please find attached the invoice for your order #${widget.orderId}',
      );
      
      setState(() {
        isLoadingPdf = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invoice generated and shared'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('Error generating PDF: $e');
      setState(() {
        isLoadingPdf = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate invoice: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totals = isLoading ? null : _calculateOrderTotals();
    
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Order #${widget.orderId}',
        showBackButton: true,
        actions: [
          if (!isLoading)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: fetchOrderDetails,
              tooltip: 'Refresh',
            ),
          if (!isLoading)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'pdf') {
                  generateInvoicePdf();
                } else if (value == 'share') {
                  Share.share(
                    'Order #${widget.orderId}\n'
                    'Status: ${_formatStatus(currentStatus)}\n'
                    'Customer: ${customerData['name'] ?? 'Unknown'}\n'
                    'Total: ${currencyFormat.format(totals?['total'] ?? 0)}\n'
                    'Date: ${_formatDate(orderDetails['created_at'])}',
                    subject: 'Order Details #${widget.orderId}',
                  );
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem<String>(
                  value: 'pdf',
                  child: Row(
                    children: [
                      Icon(Icons.picture_as_pdf, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Generate PDF'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.share, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Share Order Details'),
                    ],
                  ),
                ),
              ],
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
                      Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: fetchOrderDetails,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchOrderDetails,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Order Info Card
                        Card(
                          elevation: 2,
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
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _formatDate(orderDetails['created_at']),
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                
                                // Order Status
                                Row(
                                  children: [
                                    const Text(
                                      'Status:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(currentStatus).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: _getStatusColor(currentStatus),
                                        ),
                                      ),
                                      child: Text(
                                        _formatStatus(currentStatus),
                                        style: TextStyle(
                                          color: _getStatusColor(currentStatus),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    if (!isUpdating)
                                      PopupMenuButton<String>(
                                        icon: const Icon(Icons.edit),
                                        tooltip: 'Update Status',
                                        onSelected: updateOrderStatus,
                                        itemBuilder: (context) => statusOptions
                                            .where((status) => status != currentStatus)
                                            .map((status) => PopupMenuItem<String>(
                                                  value: status,
                                                  child: Text(_formatStatus(status)),
                                                ))
                                            .toList(),
                                      )
                                    else
                                      const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                  ],
                                ),
                                
                                if (statusUpdateError.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      statusUpdateError,
                                      style: TextStyle(
                                        color: Colors.red[700],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                
                                const SizedBox(height: 16),
                                
                                // Order Timeline
                                OrderTimeline(
                                  currentStatus: currentStatus,
                                  statusOptions: statusOptions,
                                  statusColors: {
                                    'pending': Colors.orange,
                                    'processing': Colors.blue,
                                    'shipped': Colors.indigo,
                                    'delivered': Colors.green,
                                    'cancelled': Colors.red,
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Order Items
                        const Text(
                          'Order Items',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Items List
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: orderItems.length,
                          itemBuilder: (context, index) {
                            final item = orderItems[index];
                            return OrderItemCard(
                              name: item['name'],
                              image: item['image'],
                              sku: item['sku'],
                              price: item['price'],
                              quantity: item['quantity'],
                              subtotal: item['subtotal'],
                              variations: item['variations'],
                              notes: item['notes'],
                              currencyFormat: currencyFormat,
                            );
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Order Totals
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Order Summary',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Subtotal'),
                                    Text(currencyFormat.format(totals?['subtotal'] ?? 0)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Shipping'),
                                    Text(currencyFormat.format(totals?['shipping'] ?? 0)),
                                  ],
                                ),
                                
                                if ((totals?['tax'] ?? 0) > 0) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Tax'),
                                      Text(currencyFormat.format(totals?['tax'] ?? 0)),
                                    ],
                                  ),
                                ],
                                
                                if ((totals?['discount'] ?? 0) > 0) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Discount'),
                                      Text('- ${currencyFormat.format(totals?['discount'] ?? 0)}'),
                                    ],
                                  ),
                                ],
                                
                                const Divider(height: 24),
                                
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Total',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      currencyFormat.format(totals?['total'] ?? 0),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Customer Details
                        const Text(
                          'Customer Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomerDetailsCard(
                          customerData: customerData,
                          onEmail: () {
                            if (customerData['email'] != null && customerData['email'].toString().isNotEmpty) {
                              final Uri emailUri = Uri(
                                scheme: 'mailto',
                                path: customerData['email'],
                                query: 'subject=Regarding%20Order%20%23${widget.orderId}',
                              );
                              launchUrl(emailUri);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Customer email not available'),
                                ),
                              );
                            }
                          },
                          onCall: () {
                            if (customerData['phone'] != null && customerData['phone'].toString().isNotEmpty) {
                              final Uri phoneUri = Uri(
                                scheme: 'tel',
                                path: customerData['phone'],
                              );
                              launchUrl(phoneUri);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Customer phone not available'),
                                ),
                              );
                            }
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Payment Details
                        const Text(
                          'Payment Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        PaymentDetailsCard(
                          paymentData: paymentData,
                          currencyFormat: currencyFormat,
                          formatDate: _formatDate,
                          formatStatus: _formatStatus,
                          getStatusColor: _getStatusColor,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Shipping Details
                        const Text(
                          'Shipping Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ShippingDetailsCard(
                          shippingData: shippingData,
                          onTrackShipment: () {
                            if (shippingData['tracking_url'] != null && 
                                shippingData['tracking_url'].toString().isNotEmpty) {
                              launchUrl(
                                Uri.parse(shippingData['tracking_url']),
                                mode: LaunchMode.externalApplication,
                              );
                            } else if (shippingData['tracking_number'] != null && 
                                       shippingData['tracking_number'].toString().isNotEmpty &&
                                       shippingData['courier'] != null) {
                              // Try to generate a tracking URL based on courier
                              final courier = shippingData['courier'].toString().toLowerCase();
                              String? trackingUrl;
                              
                              if (courier.contains('jne')) {
                                trackingUrl = 'https://www.jne.co.id/id/tracking/trace/${shippingData['tracking_number']}';
                              } else if (courier.contains('pos')) {
                                trackingUrl = 'https://www.posindonesia.co.id/en/tracking/${shippingData['tracking_number']}';
                              } else if (courier.contains('tiki')) {
                                trackingUrl = 'https://tiki.id/id/tracking?awb=${shippingData['tracking_number']}';
                              } else if (courier.contains('sicepat')) {
                                trackingUrl = 'https://www.sicepat.com/checkAwb/${shippingData['tracking_number']}';
                              } else if (courier.contains('anteraja')) {
                                trackingUrl = 'https://anteraja.id/tracking/${shippingData['tracking_number']}';
                              } else if (courier.contains('j&t') || courier.contains('jnt')) {
                                trackingUrl = 'https://www.jet.co.id/track/${shippingData['tracking_number']}';
                              }
                              
                              if (trackingUrl != null) {
                                launchUrl(
                                  Uri.parse(trackingUrl),
                                  mode: LaunchMode.externalApplication,
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Tracking link not available'),
                                  ),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Tracking information not available'),
                                ),
                              );
                            }
                          },
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Actions
                        if (isLoadingPdf)
                          const Center(
                            child: Column(
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text('Generating invoice PDF...'),
                              ],
                            ),
                          )
                        else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: generateInvoicePdf,
                                icon: const Icon(Icons.download),
                                label: const Text('Generate Invoice'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
    );
  }
}