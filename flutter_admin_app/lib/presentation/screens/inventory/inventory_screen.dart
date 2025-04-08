import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../widgets/app_bar.dart';
import '../../../config/routes.dart';
import '../../../config/app_config.dart';
import './widgets/product_card.dart';
import './widgets/stock_filter.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  String _debugResponse = ''; // Add this for debugging

  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _showLowStockOnly = false;
  int _currentIndex = 1; // Set to 1 for Inventory tab

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _debugResponse = '';
    });

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseApiUrl}/v1/products'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // Add authorization headers if needed
          // 'Authorization': 'Bearer $token',
        },
      ).timeout(AppConfig.apiTimeout);

      // Save raw response for debugging
      setState(() {
        _debugResponse = 'Status Code: ${response.statusCode}\nBody: ${response.body}';
      });

      if (response.statusCode == 200) {
        // Try different approaches to parse the response
        try {
          final decoded = json.decode(response.body);
          
          // Check if response is directly a list
          if (decoded is List) {
            setState(() {
              _products = List<Map<String, dynamic>>.from(
                decoded.map((item) => item is Map ? Map<String, dynamic>.from(item) : {})
              );
              _isLoading = false;
            });
            return;
          }
          
          // Check for data key
          if (decoded is Map && decoded.containsKey('data')) {
            final data = decoded['data'];
            
            if (data is List) {
              setState(() {
                _products = List<Map<String, dynamic>>.from(
                  data.map((item) => item is Map ? Map<String, dynamic>.from(item) : {})
                );
                _isLoading = false;
              });
              return;
            }
          }
          
          // Check if products is directly in the root
          if (decoded is Map && decoded.containsKey('products')) {
            final products = decoded['products'];
            
            if (products is List) {
              setState(() {
                _products = List<Map<String, dynamic>>.from(
                  products.map((item) => item is Map ? Map<String, dynamic>.from(item) : {})
                );
                _isLoading = false;
              });
              return;
            }
          }
          
          // If we got here, we couldn't find a valid product list
          setState(() {
            _hasError = true;
            _errorMessage = 'Could not find product data in server response. Check debug info.';
            _isLoading = false;
            _products = [];
          });
        } catch (parseError) {
          setState(() {
            _hasError = true;
            _errorMessage = 'Error parsing server response: ${parseError.toString()}';
            _isLoading = false;
            _products = [];
          });
        }
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to load products. Server returned ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Error connecting to the server: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredProducts {
    return _products.where((product) {
      // Added null checks
      final productName = product['name']?.toString() ?? '';
      final productCategory = product['category']?.toString() ?? '';
      final productStock = product['stock']?.toString() ?? '0';
      
      final matchesSearch = productName
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      
      final matchesCategory = _selectedCategory == 'All' || 
          productCategory == _selectedCategory;
      
      final matchesStockFilter = !_showLowStockOnly || 
          (int.tryParse(productStock) ?? 0) < 75; // Example low stock threshold with null safety

      return matchesSearch && matchesCategory && matchesStockFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Inventory',
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    _showFilterBottomSheet();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildProductsList(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/inventory/add-product').then((_) {
            // Refresh products list when returning from add product screen
            _fetchProducts();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProductsList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_hasError) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Show debug information
              if (_debugResponse.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Debug Info (API Response):',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _debugResponse,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              ElevatedButton(
                onPressed: _fetchProducts,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_products.isEmpty) {
      return const Center(
        child: Text(
          'No products available',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    if (_filteredProducts.isEmpty) {
      return const Center(
        child: Text(
          'No products found',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchProducts,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filteredProducts.length,
        itemBuilder: (context, index) {
          final product = _filteredProducts[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ProductCard(
              product: product,
              onEdit: () {
                Navigator.of(context).pushNamed(
                  '/inventory/edit-product',
                  arguments: product,
                ).then((_) {
                  // Refresh products list when returning from edit product screen
                  _fetchProducts();
                });
              },
            ),
          );
        },
      ),
    );
  }

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
            // Already on inventory
            break;
          case 2:
            AppRoutes.navigateTo(context, AppRoutes.orders);
            break;
          case 3:
            AppRoutes.navigateTo(context, AppRoutes.transactions);
            break;
          case 4:
            // More options - could show a modal bottom sheet with additional options
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

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return StockFilter(
              selectedCategory: _selectedCategory,
              showLowStockOnly: _showLowStockOnly,
              onCategoryChanged: (category) {
                setSheetState(() {
                  _selectedCategory = category;
                });
                setState(() {
                  _selectedCategory = category;
                });
              },
              onLowStockToggle: (value) {
                setSheetState(() {
                  _showLowStockOnly = value;
                });
                setState(() {
                  _showLowStockOnly = value;
                });
              },
              onApply: () {
                Navigator.of(context).pop();
              },
            );
          },
        );
      },
    );
  }
}