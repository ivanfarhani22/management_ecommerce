import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AddWholesaleNoteScreen extends StatefulWidget {
  const AddWholesaleNoteScreen({super.key});

  @override
  _AddWholesaleNoteScreenState createState() => _AddWholesaleNoteScreenState();
}

class _AddWholesaleNoteScreenState extends State<AddWholesaleNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final List<Map<String, dynamic>> _items = [];
  final Uuid _uuid = Uuid();

  @override
  void dispose() {
    _customerNameController.dispose();
    super.dispose();
  }

  void _addItem() {
    showDialog(
      context: context,
      builder: (context) => _AddItemDialog(
        onItemAdded: (item) {
          setState(() {
            _items.add(item);
          });
        },
      ),
    );
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  double _calculateTotal() {
    return _items.fold(0.0, (total, item) => 
      total + (item['quantity'] * item['price']));
  }

  // Method untuk menyimpan data ke SharedPreferences
  Future<void> _saveToLocalStorage(Map<String, dynamic> newNote) async {
    try {
      print('🔄 Mulai menyimpan data ke SharedPreferences...');
      print('📝 Data yang akan disimpan: $newNote');
      
      final prefs = await SharedPreferences.getInstance();
      
      // Ambil data yang sudah ada
      final existingNotesJson = prefs.getString('wholesale_notes');
      List<Map<String, dynamic>> existingNotes = [];
      
      print('📖 Data existing: $existingNotesJson');
      
      if (existingNotesJson != null && existingNotesJson.isNotEmpty) {
        final List<dynamic> notesList = json.decode(existingNotesJson);
        existingNotes = notesList.map((note) => Map<String, dynamic>.from(note)).toList();
      }
      
      print('📊 Jumlah notes existing: ${existingNotes.length}');
      
      // Tambahkan note baru di awal list
      final noteToSave = {
        ...newNote,
        'date': newNote['date'].toIso8601String(), // Convert DateTime to string
      };
      
      existingNotes.insert(0, noteToSave);
      
      print('📝 Note yang disimpan: $noteToSave');
      print('📊 Total notes setelah ditambah: ${existingNotes.length}');
      
      // Simpan kembali ke SharedPreferences
      final updatedNotesJson = json.encode(existingNotes);
      print('💾 JSON yang akan disimpan: $updatedNotesJson');
      
      final saveResult = await prefs.setString('wholesale_notes', updatedNotesJson);
      print('✅ Hasil save: $saveResult');
      
      // Verifikasi data tersimpan
      final verifyData = prefs.getString('wholesale_notes');
      print('🔍 Verifikasi data tersimpan: $verifyData');
      
      print('✅ Data berhasil disimpan ke SharedPreferences');
      print('📊 Total notes: ${existingNotes.length}');
      
    } catch (e) {
      print('❌ Error saving to SharedPreferences: $e');
      rethrow; // Re-throw error agar bisa ditangani di UI
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: const Color.fromARGB(255, 255, 255, 255),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Tambah Catatan Grosir'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _customerNameController,
              decoration: InputDecoration(
                labelText: 'Nama Pelanggan',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Masukkan nama pelanggan';
                }
                return null;
              },
            ),
            SizedBox(height: 24),
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
                  style: ElevatedButton.styleFrom(
                    iconColor: const Color.fromARGB(255, 255, 255, 255),
                  ),
                  
                  label: Text('Tambah Produk'),
                ),
              ],
            ),
            SizedBox(height: 16),
            _items.isEmpty
                ? Card(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.inventory_2, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Belum ada produk', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text('${index + 1}'),
                              ),
                              title: Text(item['name']),
                              subtitle: Text(
                                'Kuantitas: ${item['quantity']} | Harga: Rp ${_formatCurrency(item['price'])}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Rp ${_formatCurrency(item['quantity'] * item['price'])}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _removeItem(index),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      if (_items.isNotEmpty) ...[
                        SizedBox(height: 16),
                        Card(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total:',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Rp ${_formatCurrency(_calculateTotal())}',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submitWholesaleNote,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Simpan Catatan Grosir',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitWholesaleNote() async {
    print('🚀 Submit wholesale note dipanggil');
    
    if (_formKey.currentState!.validate()) {
      if (_items.isEmpty) {
        print('⚠️ Tidak ada item, menampilkan snackbar');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tambahkan minimal satu produk'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      print('✅ Validasi berhasil, mulai proses simpan');
      print('📝 Customer: ${_customerNameController.text.trim()}');
      print('📊 Items: $_items');
      print('💰 Total: ${_calculateTotal()}');

      // Tampilkan loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Menyimpan data...'),
            ],
          ),
        ),
      );

      try {
        final newNote = {
          'id': _uuid.v4(),
          'customerName': _customerNameController.text.trim(),
          'totalAmount': _calculateTotal(),
          'date': DateTime.now(),
          'items': List<Map<String, dynamic>>.from(_items),
        };

        print('📋 New note created: $newNote');

        // Simpan ke SharedPreferences
        await _saveToLocalStorage(newNote);

        print('✅ Data berhasil disimpan');

        // Tutup loading dialog
        Navigator.pop(context);

        // Tampilkan success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Catatan grosir berhasil disimpan'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // Tunggu sebentar agar user bisa melihat snackbar
        await Future.delayed(Duration(milliseconds: 500));

        // Kembali ke halaman sebelumnya dengan membawa data
        Navigator.pop(context, newNote);
        
      } catch (e) {
        print('❌ Error in _submitWholesaleNote: $e');
        
        // Tutup loading dialog
        Navigator.pop(context);
        
        // Tampilkan error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan catatan: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } else {
      print('❌ Validasi form gagal');
    }
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}

class _AddItemDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onItemAdded;

  const _AddItemDialog({required this.onItemAdded});

  @override
  _AddItemDialogState createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  final _itemNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _dialogFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _itemNameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Tambah Produk'),
      content: Form(
        key: _dialogFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _itemNameController,
              decoration: InputDecoration(
                labelText: 'Nama Produk',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Masukkan nama produk';
                }
                return null;
              },
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: 'Kuantitas',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Masukkan kuantitas';
                }
                if (int.tryParse(value) == null || int.parse(value) <= 0) {
                  return 'Kuantitas harus berupa angka positif';
                }
                return null;
              },
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: 'Harga',
                border: OutlineInputBorder(),
                prefixText: 'Rp ',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Masukkan harga';
                }
                if (double.tryParse(value) == null || double.parse(value) <= 0) {
                  return 'Harga harus berupa angka positif';
                }
                return null;
              },
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
            if (_dialogFormKey.currentState!.validate()) {
              final item = {
                'name': _itemNameController.text,
                'quantity': int.parse(_quantityController.text),
                'price': double.parse(_priceController.text),
              };
              widget.onItemAdded(item);
              Navigator.pop(context);
            }
          },
          child: Text('Tambah'),
        ),
      ],
    );
  }
}