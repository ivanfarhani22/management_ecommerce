import 'package:flutter/material.dart';
import './widgets/transaction_card.dart';
import 'add_offline_transaction_screen.dart';
import 'transaction_details_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  _TransactionsScreenState createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  List<Map<String, dynamic>> transactions = [
    // Sample transaction data
    {
      'id': '001',
      'type': 'Penjualan',
      'amount': 250000,
      'date': DateTime.now(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaksi'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddOfflineTransactionScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TransactionDetailsScreen(
                    transactionId: transaction['id'],
                  ),
                ),
              );
            },
            child: TransactionCard(
              transactionId: transaction['id'],
              type: transaction['type'],
              amount: transaction['amount'],
              date: transaction['date'],
            ),
          );
        },
      ),
    );
  }
}