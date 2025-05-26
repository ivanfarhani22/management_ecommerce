import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../data/models/transaction.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../widgets/app_bar.dart';

class TransactionDetailsScreen extends StatefulWidget {
  final String transactionId;

  const TransactionDetailsScreen({
    super.key,
    required this.transactionId,
  });

  @override
  State<TransactionDetailsScreen> createState() => _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  bool _isLoading = true;
  Transaction? _transaction;
  String? _errorMessage;
  final _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadTransactionDetails();
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

  Future<void> _loadTransactionDetails() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final transactionRepository = Provider.of<TransactionRepository>(context, listen: false);
      // Fixed: Pass widget.transactionId directly as it's already a String
      final transaction = await transactionRepository.getTransactionById(widget.transactionId);
      
      if (!mounted) return;
      
      setState(() {
        _transaction = transaction;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading transaction details: $e');
      
      if (!mounted) return;
      
      // Check if the error is due to unauthorized access
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
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    switch (status.toLowerCase()) {
      case 'success':
        badgeColor = Colors.green;
        break;
      case 'pending':
        badgeColor = Colors.orange;
        break;
      case 'failed':
        badgeColor = Colors.red;
        break;
      default:
        badgeColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: badgeColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: const Color.fromARGB(255, 255, 255, 255),
          onPressed: () => Navigator.pop(context),
        ),
         title: const Text('Detail Transaksi'),
        actions: [
          if (_transaction != null && (_transaction!.status == 'pending' || _transaction!.status == 'failed'))
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) async {
                if (value == 'retry') {
                  // Handle retry payment
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Retry payment functionality will be implemented')),
                  );
                } else if (value == 'cancel') {
                  // Handle cancel transaction
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Cancel Transaction'),
                      content: const Text('Are you sure you want to cancel this transaction?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('No'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Yes'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    try {
                      final transactionRepository = Provider.of<TransactionRepository>(context, listen: false);
                      // Fixed: Directly pass the transaction ID as a String
                      await transactionRepository.cancelTransaction(widget.transactionId);
                      
                      if (!mounted) return;
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Transaction cancelled successfully')),
                      );
                      
                      // Refresh transaction details
                      _loadTransactionDetails();
                      
                      // Return result to previous screen
                      Navigator.pop(context, true);
                    } catch (e) {
                      if (!mounted) return;
                      
                      // Check for unauthorized errors here too
                      if (e.toString().contains('User is not authenticated') || 
                          e.toString().contains('401') || 
                          e.toString().toLowerCase().contains('unauthorized')) {
                        // Only handle unauthorized if we're still on this screen
                        if (mounted && ModalRoute.of(context)?.isCurrent == true) {
                          _handleUnauthorized();
                        }
                        return;
                      }
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to cancel transaction: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'retry',
                  child: Row(
                    children: [
                      Icon(Icons.refresh, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Retry Payment'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'cancel',
                  child: Row(
                    children: [
                      Icon(Icons.cancel, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Cancel Transaction'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
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
                        onPressed: _loadTransactionDetails,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : _transaction == null
                  ? const Center(
                      child: Text('Transaction not found'),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Transaction amount card
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Total Amount',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Rp ${_transaction!.amount.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildStatusBadge(_transaction!.status),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),
                          const Text(
                            'Transaction Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  _buildDetailRow('Transaction ID', '#${_transaction!.id}'),
                                  const Divider(),
                                  _buildDetailRow(
                                    'Date',
                                    _transaction!.transactionDate != null
                                        ? '${_transaction!.transactionDate!.day}/${_transaction!.transactionDate!.month}/${_transaction!.transactionDate!.year} ${_transaction!.transactionDate!.hour}:${_transaction!.transactionDate!.minute.toString().padLeft(2, '0')}'
                                        : 'Not available',
                                  ),
                                  const Divider(),
                                  _buildDetailRow('Payment Method', _transaction!.paymentMethod),
                                  if (_transaction!.reference != null) ...[
                                    const Divider(),
                                    _buildDetailRow('Reference', _transaction!.reference!),
                                  ],
                                  ...[
                                  const Divider(),
                                  _buildDetailRow('Order ID', '#${_transaction!.orderId}'),
                                ],
                                ],
                              ),
                            ),
                          ),

                          if (_transaction!.status == 'failed') ...[
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () {
                                // Handle retry payment
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Retry payment functionality will be implemented')),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              child: const Text(
                                'RETRY PAYMENT',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],

                          if (_transaction!.status == 'success') ...[
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () {
                                // Handle download receipt
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Download receipt functionality will be implemented')),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.receipt),
                                  SizedBox(width: 8),
                                  Text(
                                    'DOWNLOAD RECEIPT',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
    );
  }
}