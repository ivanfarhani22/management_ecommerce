import 'package:flutter/material.dart';
import './widgets/payment_method_selector.dart';

class AddOfflineTransactionScreen extends StatefulWidget {
  const AddOfflineTransactionScreen({super.key});

  @override
  _AddOfflineTransactionScreenState createState() => _AddOfflineTransactionScreenState();
}

class _AddOfflineTransactionScreenState extends State<AddOfflineTransactionScreen> {
  final _formKey = GlobalKey<FormState>();  // Added <FormState> for type safety
  String _selectedPaymentMethod = '';
  double _amount = 0.0;
  String _description = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Transaksi Offline'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Jumlah',
                  prefixText: 'Rp ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan jumlah transaksi';
                  }
                  // Added input validation for numeric value
                  if (double.tryParse(value) == null) {
                    return 'Masukkan angka yang valid';
                  }
                  return null;
                },
                onSaved: (value) {
                  _amount = double.parse(value ?? '0');
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Deskripsi',
                ),
                maxLines: 3,
                onSaved: (value) {
                  _description = value ?? '';
                },
              ),
              SizedBox(height: 16),
              Text(
                'Metode Pembayaran',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              PaymentMethodSelector(
                onPaymentMethodSelected: (method) {
                  setState(() {
                    _selectedPaymentMethod = method;
                  });
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitTransaction,
                child: Text('Simpan Transaksi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitTransaction() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      // Validate payment method selection
      if (_selectedPaymentMethod.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pilih metode pembayaran')),
        );
        return;
      }

      // TODO: Implement transaction saving logic
      print('Transaction Details:');
      print('Amount: Rp $_amount');
      print('Description: $_description');
      print('Payment Method: $_selectedPaymentMethod');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transaksi berhasil disimpan')),
      );

      Navigator.pop(context);
    }
  }
}