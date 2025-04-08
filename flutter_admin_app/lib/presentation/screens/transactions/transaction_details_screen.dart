import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final String transactionId;

  const TransactionDetailsScreen({
    super.key, 
    required this.transactionId,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Fetch actual transaction details based on transactionId
    final transaction = {
      'id': transactionId,
      'type': 'Penjualan',
      'amount': 250000.0,
      'date': DateTime.now(),
      'paymentMethod': 'Tunai',
      'description': 'Penjualan produk di toko',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDetailCard(context, transaction),
            const SizedBox(height: 16),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context, Map<String, dynamic> transaction) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informasi Transaksi',
              style: Theme.of(context).textTheme.titleLarge, // Replaced headline6
            ),
            const SizedBox(height: 16),
            _buildDetailRow('ID Transaksi', transaction['id']),
            _buildDetailRow('Tipe', transaction['type']),
            _buildDetailRow(
              'Jumlah', 
              NumberFormat.currency(
                locale: 'id_ID', 
                symbol: 'Rp ',
                decimalDigits: 0,
              ).format(transaction['amount'])
            ),
            _buildDetailRow(
              'Tanggal', 
              DateFormat('dd MMMM yyyy HH:mm').format(transaction['date'])
            ),
            _buildDetailRow('Metode Pembayaran', transaction['paymentMethod']),
            const SizedBox(height: 16),
            Text(
              'Deskripsi',
              style: Theme.of(context).textTheme.titleSmall, // Replaced subtitle1
            ),
            Text(transaction['description'] ?? '-'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // TODO: Implement print or share transaction
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cetak transaksi')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: const Text('Cetak'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // TODO: Implement delete transaction
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Hapus Transaksi'),
                  content: const Text('Apakah Anda yakin ingin menghapus transaksi ini?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Implement actual deletion
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Hapus'),
                    ),
                  ],
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Hapus'),
          ),
        ),
      ],
    );
  }
}