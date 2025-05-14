import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../data/models/transaction.dart';
import './widgets/payment_method_selector.dart';

class AddOfflineTransactionScreen extends StatefulWidget {
  const AddOfflineTransactionScreen({super.key});

  @override
  State<AddOfflineTransactionScreen> createState() => _AddOfflineTransactionScreenState();
}

class _AddOfflineTransactionScreenState extends State<AddOfflineTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _orderIdController = TextEditingController(text: '0'); // Default value to ensure orderId is not null
  final _notesController = TextEditingController();
  final _stripeTokenController = TextEditingController(); // Added for Stripe token
  
  DateTime _selectedDate = DateTime.now();
  // Changed to match backend expectations - must be 'stripe' or 'paypal'
  String _selectedPaymentMethod = 'paypal'; 
  bool _isLoading = false;

  // Updated to match backend validation requirements
  final List<String> _validPaymentMethods = ['stripe', 'paypal']; 

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _orderIdController.dispose();
    _notesController.dispose();
    _stripeTokenController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitTransaction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final transactionRepository = Provider.of<TransactionRepository>(context, listen: false);
      
      // Parse amount - remove any formatting characters first
      String amountText = _amountController.text.replaceAll(RegExp(r'[^\d]'), '');
      double amount = double.parse(amountText);

      // Create transaction object with necessary field modifications
      final transaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch, // Using milliseconds as int
        amount: amount,
        paymentMethod: _selectedPaymentMethod, // Now using 'stripe' or 'paypal'
        status: 'completed', // Changed from 'success' to 'completed' to match API expectations
        // Make sure orderId is a valid ID from the database
        orderId: int.parse(_orderIdController.text),
        transactionId: 'TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
        transactionDate: _selectedDate,
        reference: _referenceController.text.isEmpty ? null : _referenceController.text,
        // Add stripe token if using stripe payment method
        stripeToken: _selectedPaymentMethod == 'stripe' ? _stripeTokenController.text : null,
      );

      // Save transaction
      await transactionRepository.createTransaction(transaction);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction added successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Return to previous screen with result
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('Error saving transaction: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save transaction: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Offline Transaction'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Amount field
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Amount (Rp)',
                        prefixText: 'Rp ',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        
                        // Remove any formatting characters first
                        String amountText = value.replaceAll(RegExp(r'[^\d]'), '');
                        
                        if (double.tryParse(amountText) == null) {
                          return 'Please enter a valid amount';
                        }
                        
                        if (double.parse(amountText) <= 0) {
                          return 'Amount must be greater than zero';
                        }
                        
                        return null;
                      },
                      // Format the amount as the user types
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          // Remove any non-digit characters
                          String digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
                          
                          if (digitsOnly.isNotEmpty) {
                            // Parse as double
                            double amount = double.parse(digitsOnly);
                            
                            // Format the value
                            String formattedValue = amount.toStringAsFixed(0);
                            
                            // Only update if different to avoid infinite loops
                            if (formattedValue != value) {
                              _amountController.value = TextEditingValue(
                                text: formattedValue,
                                selection: TextSelection.collapsed(offset: formattedValue.length),
                              );
                            }
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Date picker
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Transaction Date',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Payment method selector - Modified to use valid payment methods
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 4, bottom: 8),
                          child: Text(
                            'Payment Method',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        // Modified PaymentMethodSelector to use valid methods
                        PaymentMethodSelector(
                          initialValue: _selectedPaymentMethod,
                          validMethods: _validPaymentMethods, // Pass valid methods to the selector
                          onPaymentMethodSelected: (String method) {
                            setState(() {
                              _selectedPaymentMethod = method;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Order ID field (required in model and must be valid)
                    TextFormField(
                      controller: _orderIdController,
                      decoration: const InputDecoration(
                        labelText: 'Order ID',
                        border: OutlineInputBorder(),
                        hintText: 'Enter a valid order ID from the database',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an order ID';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid order ID (numbers only)';
                        }
                        // Note: We can't validate if the ID exists without checking the database
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Show Stripe Token field only when Stripe is selected
                    if (_selectedPaymentMethod == 'stripe')
                      Column(
                        children: [
                          TextFormField(
                            controller: _stripeTokenController,
                            decoration: const InputDecoration(
                              labelText: 'Stripe Token',
                              border: OutlineInputBorder(),
                              hintText: 'Enter valid Stripe token',
                            ),
                            validator: (value) {
                              if (_selectedPaymentMethod == 'stripe' && (value == null || value.isEmpty)) {
                                return 'Stripe token is required for stripe payments';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    
                    // Reference number field (optional)
                    TextFormField(
                      controller: _referenceController,
                      decoration: const InputDecoration(
                        labelText: 'Reference Number (Optional)',
                        border: OutlineInputBorder(),
                        hintText: 'E.g., Receipt number, invoice number',
                      ),
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 16),
                    
                    // Notes field (optional)
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (Optional)',
                        border: OutlineInputBorder(),
                        hintText: 'Additional information about this transaction',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),
                    
                    // Submit button
                    ElevatedButton(
                      onPressed: _submitTransaction,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(
                        'SAVE TRANSACTION',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}