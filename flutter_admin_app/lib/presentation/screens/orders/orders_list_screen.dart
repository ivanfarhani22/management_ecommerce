import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math'; // Import for min()
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart'; // Import for currency and date formatting
import './widgets/order_filter.dart';
import 'order_details_screen.dart';
import '../../../config/app_config.dart';
import '../../../config/routes.dart'; // Import for AppRoutes
import '../../widgets/app_bar.dart';
import './widgets/order_status_card.dart'; // Import OrderStatusCard widget

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});

  @override
  _OrdersListScreenState createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;
  String errorMessage = '';
  
  // Improved cache for user names with timestamp to manage cache invalidation
  final Map<String, Map<String, dynamic>> _userCache = {};
  
  String _selectedStatus = 'All';
  bool _showRecentOnly = false;
  final _secureStorage = const FlutterSecureStorage();
  
  // Available status options for updating
  final List<String> statusOptions = ['Pending', 'Processing', 'Completed', 'Cancelled'];
  
  // For Bottom Navigation
  int _currentIndex = 2; // Set to 2 for Orders tab
  
  // Format for currency
  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  // Flag to track if we're currently fetching user data
  bool _isFetchingUserData = false;

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

  // Improved method to get user name by user_id
  Future<String> _getUserNameById(String userId) async {
    // First check the cache
    if (_userCache.containsKey(userId) && 
        _userCache[userId]!.containsKey('name') && 
        _userCache[userId]!['name'] != null) {
      debugPrint('Using cached name for user_id $userId: ${_userCache[userId]!['name']}');
      return _userCache[userId]!['name']!;
    }
    
    try {
      debugPrint('Fetching user name for user_id: $userId');
      
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
        
        if (userData['success'] == true && userData['data'] != null) {
          // Using new API structure
          userName = userData['data']['name'] ?? 'Unknown User';
          
          // Store complete user data in cache
          _userCache[userId] = {
            'name': userName,
            'data': userData['data'],
            'timestamp': DateTime.now().millisecondsSinceEpoch
          };
        } else if (userData['data'] != null) {
          // Old API structure - fallback
          userName = userData['data']['name'] ?? 'Unknown User';
          
          // Store in cache
          _userCache[userId] = {
            'name': userName,
            'data': userData['data'],
            'timestamp': DateTime.now().millisecondsSinceEpoch
          };
        } else if (userData['name'] != null) {
          // Direct name field
          userName = userData['name'];
          
          // Store in cache
          _userCache[userId] = {
            'name': userName,
            'data': {'name': userName},
            'timestamp': DateTime.now().millisecondsSinceEpoch
          };
        } else {
          // Default fallback
          userName = 'Customer #$userId';
          
          // Still cache the failed attempt to prevent repeated requests
          _userCache[userId] = {
            'name': userName,
            'error': 'User data structure unrecognized',
            'timestamp': DateTime.now().millisecondsSinceEpoch
          };
        }
        
        debugPrint('Successfully fetched user name for $userId: $userName');
        return userName;
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
        return 'Customer #$userId';
      } else {
        debugPrint('Failed to fetch user name for $userId with status code: ${response.statusCode}');
        
        // Cache the failed attempt with error info
        _userCache[userId] = {
          'name': 'Customer #$userId',
          'error': 'API Error: ${response.statusCode}',
          'timestamp': DateTime.now().millisecondsSinceEpoch
        };
        
        return 'Customer #$userId';
      }
    } catch (e) {
      debugPrint('Error fetching user name for $userId: $e');
      
      // Cache the failed attempt with error info
      _userCache[userId] = {
        'name': 'Customer #$userId',
        'error': e.toString(),
        'timestamp': DateTime.now().millisecondsSinceEpoch
      };
      
      return 'Customer #$userId';
    }
  }

  // Enhanced method to prefetch multiple user names at once with better error handling
  Future<void> _prefetchMultipleUserNames(List<String> userIds) async {
    if (userIds.isEmpty) return;
    
    // Set fetching flag to true
    setState(() {
      _isFetchingUserData = true;
    });
    
    // Filter out IDs that were recently fetched (less than 5 minutes ago)
    final int currentTime = DateTime.now().millisecondsSinceEpoch;
    final int cacheValidityPeriod = 5 * 60 * 1000; // 5 minutes in milliseconds
    
    final List<String> uncachedIds = userIds.where((id) {
      // If not in cache or cache entry is older than 5 minutes
      return !_userCache.containsKey(id) || 
             !_userCache[id]!.containsKey('timestamp') ||
             (currentTime - _userCache[id]!['timestamp']) > cacheValidityPeriod;
    }).toList();
    
    if (uncachedIds.isEmpty) {
      setState(() {
        _isFetchingUserData = false;
      });
      return;
    }
    
    try {
      debugPrint('Batch fetching ${uncachedIds.length} user names...');
      
      // Get auth headers for the request
      final headers = await _getAuthHeaders();
      
      // Make API request to get user details in batch
      final response = await http.post(
        Uri.parse('${AppConfig.baseApiUrl}/v1/users/batch'),
        headers: headers,
        body: json.encode({'ids': uncachedIds}),
      ).timeout(AppConfig.apiTimeout);
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> users = responseData['data'];
          
          // Store all fetched users in the cache
          for (var user in users) {
            final String userId = user['id'].toString();
            final String userName = user['name'] ?? 'Customer #$userId';
            
            _userCache[userId] = {
              'name': userName,
              'data': user,
              'timestamp': currentTime
            };
            
            debugPrint('Cached batch user: $userId = $userName');
          }
          
          // Update orders with new user names
          _updateOrdersWithCachedNames();
        } else {
          debugPrint('Batch API response malformed: ${response.body}');
          // Fall back to individual requests
          await _fetchUsersIndividually(uncachedIds);
        }
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else if (response.statusCode == 404) {
        // The batch endpoint might not exist
        debugPrint('Batch endpoint not found. Falling back to individual requests.');
        await _fetchUsersIndividually(uncachedIds);
      } else {
        debugPrint('Failed to batch fetch user names. Status: ${response.statusCode}');
        // Fall back to individual requests
        await _fetchUsersIndividually(uncachedIds);
      }
    } catch (e) {
      debugPrint('Error in batch fetching user names: $e');
      // Fall back to individual requests
      await _fetchUsersIndividually(uncachedIds);
    } finally {
      // Set fetching flag to false
      setState(() {
        _isFetchingUserData = false;
      });
    }
  }
  
  // Helper method to fetch users one by one when batch fails
  Future<void> _fetchUsersIndividually(List<String> userIds) async {
    // Limit to 10 concurrent requests to avoid overloading the server
    const int concurrentLimit = 10;
    
    for (int i = 0; i < userIds.length; i += concurrentLimit) {
      final batch = userIds.sublist(i, min(i + concurrentLimit, userIds.length));
      await Future.wait(batch.map((userId) => _getUserNameById(userId)));
    }
    
    // Update orders list with fetched names
    _updateOrdersWithCachedNames();
  }
  
  // Helper method to update orders with cached names
  void _updateOrdersWithCachedNames() {
    setState(() {
      for (int i = 0; i < orders.length; i++) {
        final userId = orders[i]['user_id']?.toString();
        if (userId != null && 
            _userCache.containsKey(userId) && 
            _userCache[userId]!.containsKey('name')) {
          orders[i]['customer'] = _userCache[userId]!['name'];
        }
      }
    });
  }

  // Enhanced implementation of fetchOrders with better error handling and user data extraction
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
        
        // Check structure of response (could be 'orders', 'data', or direct array)
        List<dynamic> ordersList;
        if (data['orders'] != null) {
          ordersList = data['orders'];
        } else if (data['data'] != null) {
          ordersList = data['data'];
        } else if (data is List) {
          ordersList = data;
        } else {
          // Unexpected response structure
          debugPrint('Unexpected API response structure: ${data.keys}');
          throw Exception('Unexpected API response structure');
        }
        
        // First, collect all user_ids that need to be fetched
        Set<String> userIdsToFetch = {};
        
        // Temporary list to store order data
        List<Map<String, dynamic>> tempOrders = [];
        
        for (var order in ordersList) {
          String userId = '';
          String customerName = 'Unknown Customer';
          
          // Try various ways to get the user ID and name based on API response structure
          if (order['user_id'] != null) {
            userId = order['user_id'].toString();
            
            // Check if we already have this user in cache
            if (_userCache.containsKey(userId) && _userCache[userId]!.containsKey('name')) {
              customerName = _userCache[userId]!['name'];
            } else {
              userIdsToFetch.add(userId);
              customerName = 'Loading...'; // Temporary placeholder
            }
          } else if (order['user'] != null && order['user']['id'] != null) {
            userId = order['user']['id'].toString();
            customerName = order['user']['name'] ?? 'Unknown Customer';
            
            // Update cache with this user
            _userCache[userId] = {
              'name': customerName,
              'data': order['user'],
              'timestamp': DateTime.now().millisecondsSinceEpoch
            };
          } else if (order['customer_name'] != null) {
            // Direct customer name field
            customerName = order['customer_name'];
          }
          
          // Get order total amount - handle different possible field names
          double totalAmount = 0.0;
          if (order['total_amount'] != null) {
            totalAmount = double.tryParse(order['total_amount'].toString()) ?? 0.0;
          } else if (order['total'] != null) {
            totalAmount = double.tryParse(order['total'].toString()) ?? 0.0;
          } else if (order['amount'] != null) {
            totalAmount = double.tryParse(order['amount'].toString()) ?? 0.0;
          }
          
          tempOrders.add({
            'id': order['id'].toString(),
            'customer': customerName,
            'total': totalAmount,
            'status': _formatStatus(order['status'].toString()),
            'date': DateTime.tryParse(order['created_at']) ?? DateTime.now(),
            'user_id': userId,
          });
        }
        
        setState(() {
          orders = tempOrders;
          isLoading = false;
        });
        
        // Prefetch user names in batch if needed
        if (userIdsToFetch.isNotEmpty) {
          // Show a snackbar to indicate we're loading user data
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text('Memuat data pelanggan...')
                ],
              ),
              duration: const Duration(seconds: 2),
            ),
          );
          
          // Start prefetching in the background
          _prefetchMultipleUserNames(userIdsToFetch.toList());
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
          SnackBar(
            content: Text('Status pesanan berhasil diubah menjadi $newStatus'),
            backgroundColor: Colors.green,
          ),
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
        if (now.difference(orderDate).inDays > 30) { // 30 days for better UX
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

  // Improved method to refresh all customer names
  Future<void> _refreshAllCustomerNames() async {
    // Only proceed if not already fetching
    if (_isFetchingUserData) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sedang memperbarui nama pelanggan...'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Memperbarui nama pelanggan...'),
        duration: Duration(seconds: 2),
      ),
    );
    
    // Collect all user IDs from orders
    Set<String> userIdsToFetch = {};
    
    for (var order in orders) {
      final userId = order['user_id'];
      if (userId != null && userId.toString().isNotEmpty) {
        userIdsToFetch.add(userId.toString());
        
        // Temporarily set to "Loading..." while fetching
        setState(() {
          order['customer'] = 'Loading...';
        });
      }
    }
    
    // Clear the cache to force refresh
    _userCache.clear();
    
    // Fetch all user names
    if (userIdsToFetch.isNotEmpty) {
      await _prefetchMultipleUserNames(userIdsToFetch.toList());
      
      // Notify completion
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama pelanggan berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada data pelanggan untuk diperbarui'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _viewOrderDetails(String orderId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailsScreen(orderId: orderId),
      ),
    ).then((_) => fetchOrders()); // Refresh after returning
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Daftar Pesanan',
        showBackButton: false,
        actions: [
          // Add a refresh customer names button with better UI feedback
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(
                  Icons.person_search,
                  color: const Color.fromARGB(255, 255, 255, 255), // Ganti warna di sini
                ),
                tooltip: 'Segarkan Nama Pelanggan',
                onPressed: _isFetchingUserData ? null : _refreshAllCustomerNames,
              ),
              if (_isFetchingUserData)
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: const Color.fromARGB(255, 255, 255, 255), // Ganti warna di sini
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
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
                        onPressed: fetchOrders,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refreshOrders,
                  child: filteredOrders.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          itemCount: filteredOrders.length,
                          padding: const EdgeInsets.all(12),
                          itemBuilder: (context, index) {
                            final order = filteredOrders[index];
                            return OrderStatusCard(
                              orderNumber: order['id'],
                              customerName: order['customer'],
                              total: order['total'],
                              status: order['status'],
                              date: order['date'],
                              onTap: () => _viewOrderDetails(order['id']),
                            );
                          },
                        ),
                ),
      bottomNavigationBar: _buildBottomNavigation(),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshOrders,
        tooltip: 'Refresh Pesanan',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined, 
            size: 64, 
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada pesanan ditemukan',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          if (_selectedStatus != 'All' || _showRecentOnly) ...[
            const SizedBox(height: 8),
            Text(
              'Coba ubah filter untuk melihat pesanan lainnya',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.filter_alt_off),
              label: const Text('Reset Filter'),
              onPressed: () {
                _applyFilter('All', false);
              },
            ),
          ],
        ],
      ),
    );
  }

  // Bottom Navigation Bar implementation
  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
        
        // Handle navigation based on index
        switch (index) {
          case 0:
            AppRoutes.navigateTo(context, AppRoutes.dashboard);
            break;
          case 1:
            AppRoutes.navigateTo(context, AppRoutes.inventory);
            break;
          case 2:
            // Already on orders page
            break;
          case 3:
            AppRoutes.navigateTo(context, AppRoutes.transactions);
            break;
          case 4:
            // More options - show a modal bottom sheet with additional options
            _showMoreOptions();
            break;
        }
      },
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory),
          label: 'Inventory',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt),
          label: 'Transactions',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.more_horiz),
          label: 'More',
        ),
      ],
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Financial Reports'),
              onTap: () {
                Navigator.pop(context);
                AppRoutes.navigateTo(context, AppRoutes.financialReports);
              },
            ),
            ListTile(
              leading: const Icon(Icons.store),
              title: const Text('Wholesale Notes'),
              onTap: () {
                Navigator.pop(context);
                AppRoutes.navigateTo(context, AppRoutes.wholesaleNotes);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                AppRoutes.replaceWith(context, AppRoutes.login);
              },
            ),
          ],
        );
      },
    );
  }
}