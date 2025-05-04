import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import './widgets/transaction_card.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../data/models/transaction.dart';
import 'add_offline_transaction_screen.dart';
import 'transaction_details_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddOfflineTransactionScreen(),
                ),
              );
              
              if (result == true) {
                _loadTransactions();
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadTransactions,
        child: _buildBody(),
      ),
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
            
            if (result == true) {
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