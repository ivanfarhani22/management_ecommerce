import 'package:flutter/material.dart';

class PaymentMethodSelector extends StatefulWidget {
  final String initialValue;
  final Function(String) onPaymentMethodSelected;
  final List<String> validMethods;

  const PaymentMethodSelector({
    super.key, 
    required this.initialValue,
    required this.onPaymentMethodSelected,
    this.validMethods = const ['bank_transfer', 'cash', 'credit_card'],
  });

  @override
  State<PaymentMethodSelector> createState() => _PaymentMethodSelectorState();
}

class _PaymentMethodSelectorState extends State<PaymentMethodSelector> {
  late String _selectedMethod;
  
  @override
  void initState() {
    super.initState();
    _selectedMethod = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    // Map of payment methods to their display names and icons
    final Map<String, Map<String, dynamic>> methodDetails = {
      'bank_transfer': {
        'displayName': 'Bank Transfer',
        'icon': Icons.account_balance,
      },
      'cash': {
        'displayName': 'Cash',
        'icon': Icons.money,
      },
      'credit_card': {
        'displayName': 'Credit Card',
        'icon': Icons.credit_card,
      },
      // Add more payment methods as needed
    };

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: widget.validMethods.map((method) {
          final isSelected = _selectedMethod == method;
          final details = methodDetails[method] ?? {
            'displayName': method,
            'icon': Icons.payment,
          };
          
          return ListTile(
            leading: Icon(
              details['icon'],
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade600,
            ),
            title: Text(
              details['displayName'],
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
              ),
            ),
            tileColor: isSelected ? Colors.grey.shade100 : null,
            onTap: () {
              setState(() {
                _selectedMethod = method;
              });
              widget.onPaymentMethodSelected(method);
            },
            trailing: isSelected
                ? Icon(
                    Icons.check_circle,
                    color: Theme.of(context).primaryColor,
                  )
                : null,
          );
        }).toList(),
      ),
    );
  }
}