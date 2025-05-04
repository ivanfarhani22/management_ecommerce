import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../data/models/transaction.dart';
import '../../../utils/currency_formatter.dart';

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

  @override
  void initState() {
    super.initState();
    _loadTransactionDetails();
  }

  Future<void> _loadTransactionDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final transactionRepository = Provider.of<TransactionRepository>(context, listen: false);
      // Fixed: Pass widget.transactionId directly as it's already a String
      final transaction = await transactionRepository.getTransactionById(widget.transactionId);
      
      setState(() {
        _transaction = transaction;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading transaction details: $e');
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
              style: TextStyle(fontSize: 16),
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
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
        title: Text('Detail Transaksi'),
        actions: [
          if (_transaction != null && (_transaction!.status == 'pending' || _transaction!.status == 'failed'))
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'retry') {
                  // Handle retry payment
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Retry payment functionality will be implemented')),
                  );
                } else if (value == 'cancel') {
                  // Handle cancel transaction
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Cancel Transaction'),
                      content: Text('Are you sure you want to cancel this transaction?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text('No'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text('Yes'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    try {
                      final transactionRepository = Provider.of<TransactionRepository>(context, listen: false);
                      // Fixed: Directly pass the transaction ID as a String
                      await transactionRepository.cancelTransaction(widget.transactionId);
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Transaction cancelled successfully')),
                      );
                      
                      // Refresh transaction details
                      _loadTransactionDetails();
                      
                      // Return result to previous screen
                      Navigator.pop(context, true);
                    } catch (e) {
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
                PopupMenuItem(
                  value: 'retry',
                  child: Row(
                    children: [
                      Icon(Icons.refresh, color: Theme.of(context).primaryColor),
                      SizedBox(width: 8),
                      Text('Retry Payment'),
                    ],
                  ),
                ),
                PopupMenuItem(
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
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: $_errorMessage',
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadTransactionDetails,
                        child: Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : _transaction == null
                  ? Center(
                      child: Text('Transaction not found'),
                    )
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(16),
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
                              padding: EdgeInsets.all(16),
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
                                  SizedBox(height: 8),
                                  Text(
                                    'Rp ${_transaction!.amount.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  _buildStatusBadge(_transaction!.status),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: 24),
                          Text(
                            'Transaction Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  _buildDetailRow('Transaction ID', '#${_transaction!.id}'),
                                  Divider(),
                                  _buildDetailRow(
                                    'Date',
                                    _transaction!.transactionDate != null
                                        ? '${_transaction!.transactionDate!.day}/${_transaction!.transactionDate!.month}/${_transaction!.transactionDate!.year} ${_transaction!.transactionDate!.hour}:${_transaction!.transactionDate!.minute.toString().padLeft(2, '0')}'
                                        : 'Not available',
                                  ),
                                  Divider(),
                                  _buildDetailRow('Payment Method', _transaction!.paymentMethod),
                                  if (_transaction!.reference != null) ...[
                                    Divider(),
                                    _buildDetailRow('Reference', _transaction!.reference!),
                                  ],
                                  if (_transaction!.orderId != null) ...[
                                    Divider(),
                                    _buildDetailRow('Order ID', '#${_transaction!.orderId}'),
                                  ],
                                ],
                              ),
                            ),
                          ),

                          if (_transaction!.status == 'failed') ...[
                            SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () {
                                // Handle retry payment
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Retry payment functionality will be implemented')),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                minimumSize: Size(double.infinity, 50),
                              ),
                              child: Text(
                                'RETRY PAYMENT',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],

                          if (_transaction!.status == 'success') ...[
                            SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () {
                                // Handle download receipt
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Download receipt functionality will be implemented')),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                minimumSize: Size(double.infinity, 50),
                              ),
                              child: Row(
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