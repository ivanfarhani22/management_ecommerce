import 'package:flutter/material.dart';
import 'add_wholesale_note_screen.dart';
import './widgets/wholesale_item_card.dart';

class WholesaleNotesScreen extends StatefulWidget {
  const WholesaleNotesScreen({super.key});

  @override
  _WholesaleNotesScreenState createState() => _WholesaleNotesScreenState();
}

class _WholesaleNotesScreenState extends State<WholesaleNotesScreen> {
  List<Map<String, dynamic>> wholesaleNotes = [
    {
      'id': '001',
      'customerName': 'Toko Maju Jaya',
      'totalAmount': 5000000,
      'date': DateTime.now(),
      'items': [
        {'name': 'Beras', 'quantity': 50, 'price': 100000},
        {'name': 'Minyak Goreng', 'quantity': 20, 'price': 50000},
      ],
    },
    // Add more sample wholesale notes
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catatan Grosir'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddWholesaleNoteScreen(),
                ),
              ).then((_) {
                // Refresh notes or add new note logic
                setState(() {});
              });
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: wholesaleNotes.length,
        itemBuilder: (context, index) {
          final note = wholesaleNotes[index];
          return WholesaleItemCard(
            customerName: note['customerName'],
            totalAmount: note['totalAmount'],
            date: note['date'],
            onTap: () {
              // TODO: Navigate to wholesale note details
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Detail Catatan Grosir')),
              );
            },
          );
        },
      ),
    );
  }
}