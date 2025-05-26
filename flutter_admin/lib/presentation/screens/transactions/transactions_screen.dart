import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import './widgets/transaction_card.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../data/models/transaction.dart';
import 'add_offline_transaction_screen.dart';
import 'transaction_details_screen.dart';
import '../../widgets/app_bar.dart';
import '../../../config/routes.dart'; // Import for AppRoutes



class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  _TransactionsScreenState createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  bool _isLoading = true;
  List<Transaction> _transactions = [];
  String _filterStatus = 'all';
  String? _errorMessage;
  late TransactionRepository _transactionRepository;
  bool _didInit = false;
  final _secureStorage = const FlutterSecureStorage();
  int _currentIndex = 3; // Set to 3 for Transactions tab
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Mendapatkan repository di didChangeDependencies
    _transactionRepository = Provider.of<TransactionRepository>(context, listen: false);
    
    // Hanya load data sekali saat widget pertama kali dibuat
    if (!_didInit) {
      _didInit = true;
      
      // Gunakan addPostFrameCallback untuk menunda pemanggilan _loadTransactions()
      // hingga setelah build selesai
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _loadTransactions();
      });
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
  
  Future<void> _loadTransactions() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      List<Transaction> transactions;
      
      print('Loading transactions with filter: $_filterStatus');
      
      if (_filterStatus == 'all') {
        transactions = await _transactionRepository.getAllTransactions();
      } else {
        transactions = await _transactionRepository.getTransactionsByStatus(_filterStatus);
      }
      
      print('Loaded ${transactions.length} transactions');
      
      if (!mounted) return;
      
      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      print('Error in _loadTransactions: $e');
      
      if (!mounted) return;
      
      // Check if the error is due to unauthorized access - be more specific to avoid false positives
      if (e.toString().contains('User is not authenticated') || 
          e.toString().contains('401') || 
          e.toString().toLowerCase().contains('unauthorized')) {
        // Only handle unauthorized if we're still on this screen
        if (mounted && ModalRoute.of(context)?.isCurrent == true) {
          _handleUnauthorized();
        }
        return;
      }
      
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      
      // Gunakan addPostFrameCallback untuk menampilkan SnackBar
      // setelah proses build selesai
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load transactions: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    }
  }
  
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Status'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterOption('All', 'all'),
              _buildFilterOption('Success', 'success'),
              _buildFilterOption('Pending', 'pending'),
              _buildFilterOption('Failed', 'failed'),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFilterOption(String label, String value) {
    return ListTile(
      title: Text(label),
      leading: Radio<String>(
        value: value,
        groupValue: _filterStatus,
        onChanged: (newValue) {
          setState(() {
            _filterStatus = newValue!;
          });
          Navigator.pop(context);
          _loadTransactions();
        },
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
            AppRoutes.navigateTo(context, AppRoutes.orders);
            break;
          case 3:
            // Already on transactions page
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

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: CustomAppBar(
      title: 'Transactions',
      showBackButton: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list),
          color: const Color.fromARGB(255, 255, 255, 255),
          onPressed: _showFilterDialog,
        ),
        // Hapus IconButton add karena sudah dipindah ke FAB
      ],
    ),
    body: RefreshIndicator(
      onRefresh: _loadTransactions,
      child: _buildBody(),
    ),
    bottomNavigationBar: _buildBottomNavigation(),
    // Tambahkan FloatingActionButton di pojok kanan bawah
    floatingActionButton: FloatingActionButton(
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddOfflineTransactionScreen(),
          ),
        );
        
        if (result == true && mounted) {
          _loadTransactions();
        }
      },
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      child: const Icon(Icons.add),
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
  );
}

Widget _buildBody() {
  if (_isLoading) {
    return const Center(child: CircularProgressIndicator());
  }
  
  if (_errorMessage != null) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: $_errorMessage', 
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTransactions,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
  
  if (_transactions.isEmpty) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No transactions found'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTransactions,
              child: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
  
  return ListView.builder(
    padding: const EdgeInsets.all(8),
    itemCount: _transactions.length,
    itemBuilder: (context, index) {
      final transaction = _transactions[index];
      return GestureDetector(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TransactionDetailsScreen(
                transactionId: transaction.id.toString(),
              ),
            ),
          );
          
          if (result == true && mounted) {
            _loadTransactions();
          }
        },
        child: TransactionCard(
          transactionId: transaction.id.toString(),
          type: transaction.paymentMethod,
          amount: transaction.amount,
          date: transaction.transactionDate ?? DateTime.now(),
          status: transaction.status,
        ),
      );
    },
  );
}
}