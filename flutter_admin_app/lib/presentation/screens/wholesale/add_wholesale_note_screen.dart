import 'package:flutter/material.dart';

class AddWholesaleNoteScreen extends StatefulWidget {
  const AddWholesaleNoteScreen({super.key});

  @override
  _AddWholesaleNoteScreenState createState() => _AddWholesaleNoteScreenState();
}

class _AddWholesaleNoteScreenState extends State<AddWholesaleNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  String _customerName = '';
  final List<Map<String, dynamic>> _items = [];

  void _addItem() {
    showDialog(
      context: context,
      builder: (context) => _buildAddItemDialog(),
    );
  }

  AlertDialog _buildAddItemDialog() {
    String itemName = '';
    int quantity = 0;
    double price = 0.0;

    return AlertDialog(
      title: Text('Tambah Produk'),
      content: Form(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Nama Produk'),
              onChanged: (value) => itemName = value,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Kuantitas'),
              keyboardType: TextInputType.number,
              onChanged: (value) => quantity = int.tryParse(value) ?? 0,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Harga'),
              keyboardType: TextInputType.number,
              onChanged: (value) => price = double.tryParse(value) ?? 0.0,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _items.add({
                'name': itemName,
                'quantity': quantity,
                'price': price,
              });
            });
            Navigator.pop(context);
          },
          child: Text('Tambah'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Catatan Grosir'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Nama Pelanggan',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Masukkan nama pelanggan';
                }
                return null;
              },
              onSaved: (value) => _customerName = value ?? '',
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daftar Produk',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                ElevatedButton.icon(
                  onPressed: _addItem,
                  icon: Icon(Icons.add),
                  label: Text('Tambah Produk'),
                ),
              ],
            ),
            SizedBox(height: 16),
            _items.isEmpty
                ? Center(child: Text('Belum ada produk'))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return ListTile(
                        title: Text(item['name']),
                        subtitle: Text(
                          'Kuantitas: ${item['quantity']} | Harga: Rp ${item['price']}',
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _items.removeAt(index);
                            });
                          },
                        ),
                      );
                    },
                  ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitWholesaleNote,
              child: Text('Simpan Catatan Grosir'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitWholesaleNote() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tambahkan minimal satu produk')),
        );
        return;
      }

      // TODO: Implement save wholesale note logic
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Catatan grosir berhasil disimpan')),
      );

      Navigator.pop(context);
    }
  }
}