import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentDetailsCard extends StatelessWidget {
  final Map<String, dynamic> paymentData;
  final NumberFormat currencyFormat;
  final Function(dynamic) formatDate;
  final Function(String) formatStatus;
  final Function(String) getStatusColor;

  const PaymentDetailsCard({
    Key? key,
    required this.paymentData,
    required this.currencyFormat,
    required this.formatDate,
    required this.formatStatus,
    required this.getStatusColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract payment details with fallbacks
    final method = paymentData['method'] ?? 'Unknown';
    final status = (paymentData['status'] ?? 'pending').toString().toLowerCase();
    final transactionId = paymentData['transaction_id'];
    final amount = paymentData['amount'] != null
        ? double.tryParse(paymentData['amount'].toString()) ?? 0.0
        : 0.0;
    final currency = paymentData['currency'] ?? 'IDR';
    final paymentDate = paymentData['payment_date'];
    
    // Get appropriate payment method icon
    IconData methodIcon = _getPaymentMethodIcon(method);
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Payment Method
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(
                    methodIcon,
                    color: Colors.grey[800],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatMethodName(method),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (transactionId != null)
                        Text(
                          'Transaction ID: $transactionId',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Payment Status
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
                    color: getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: getStatusColor(status),
                    ),
                  ),
                  child: Text(
                    formatStatus(status),
                    style: TextStyle(
                      color: getStatusColor(status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            
            // Payment Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Amount',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  currencyFormat.format(amount),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            
            // Payment Date
            if (paymentDate != null) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Date',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    formatDate(paymentDate),
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
            
            // Payment Notes
            if (paymentData['notes'] != null && 
                paymentData['notes'].toString().isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Payment Notes',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(paymentData['notes'].toString()),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  // Get icon for payment method
  IconData _getPaymentMethodIcon(String method) {
    final lowerMethod = method.toLowerCase();
    
    if (lowerMethod.contains('credit') || 
        lowerMethod.contains('card') || 
        lowerMethod.contains('visa') || 
        lowerMethod.contains('mastercard')) {
      return Icons.credit_card;
    } else if (lowerMethod.contains('transfer') || 
               lowerMethod.contains('bank')) {
      return Icons.account_balance;
    } else if (lowerMethod.contains('cash')) {
      return Icons.money;
    } else if (lowerMethod.contains('paypal')) {
      return Icons.payment;
    } else if (lowerMethod.contains('wallet') || 
               lowerMethod.contains('ewallet') || 
               lowerMethod.contains('e-wallet')) {
      return Icons.account_balance_wallet;
    } else if (lowerMethod.contains('cod') || 
               lowerMethod.contains('delivery')) {
      return Icons.local_shipping;
    } else {
      return Icons.payment;
    }
  }
  
  // Format payment method name
  String _formatMethodName(String method) {
    if (method.isEmpty) return 'Unknown';
    
    // Handle common abbreviations
    if (method.toLowerCase() == 'cod') {
      return 'Cash on Delivery';
    }
    
    // Convert to title case
    return method.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}