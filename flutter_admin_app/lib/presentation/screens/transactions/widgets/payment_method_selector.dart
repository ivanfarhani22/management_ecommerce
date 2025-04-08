import 'package:flutter/material.dart';

class PaymentMethodSelector extends StatefulWidget {
  final Function(String) onPaymentMethodSelected;

  const PaymentMethodSelector({
    super.key, 
    required this.onPaymentMethodSelected,
  });

  @override
  _PaymentMethodSelectorState createState() => _PaymentMethodSelectorState();
}

class _PaymentMethodSelectorState extends State<PaymentMethodSelector> {
  final List<Map<String, String>> _paymentMethods = [
    {'name': 'Tunai', 'icon': 'assets/icons/cash.png'},
    {'name': 'Transfer', 'icon': 'assets/icons/transfer.png'},
    {'name': 'E-Wallet', 'icon': 'assets/icons/e-wallet.png'},
  ];

  String? _selectedPaymentMethod;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _paymentMethods.length,
      itemBuilder: (context, index) {
        final method = _paymentMethods[index];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedPaymentMethod = method['name'];
            });
            widget.onPaymentMethodSelected(method['name']!);
          },
          child: Container(
            decoration: BoxDecoration(
              color: _selectedPaymentMethod == method['name'] 
                ? Colors.blue.shade100 
                : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _selectedPaymentMethod == method['name'] 
                  ? Colors.blue 
                  : Colors.transparent,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  method['icon']!,
                  width: 48,
                  height: 48,
                ),
                SizedBox(height: 8),
                Text(
                  method['name']!,
                  style: TextStyle(
                    fontWeight: _selectedPaymentMethod == method['name'] 
                      ? FontWeight.bold 
                      : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}