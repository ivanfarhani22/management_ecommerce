import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'add_wholesale_note_screen.dart';
import 'capture_receipt_screen.dart';
import './widgets/wholesale_item_card.dart';
import '../../widgets/app_bar.dart';
import '../../../config/routes.dart';
import '../../../config/app_config.dart';


class WholesaleNotesScreen extends StatefulWidget {
  const WholesaleNotesScreen({super.key});

  @override
  _WholesaleNotesScreenState createState() => _WholesaleNotesScreenState();
}

class _WholesaleNotesScreenState extends State<WholesaleNotesScreen> {
  List<Map<String, dynamic>> wholesaleNotes = [];
  bool isLoading = true;
  int _currentIndex = 4; // Set to 1 since this is the wholesale notes screen

  @override
  void initState() {
    super.initState();
    _loadWholesaleNotes();
  }

  // Helper method untuk konversi ke double dengan aman
  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  // Helper method untuk konversi ke int dengan aman
  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  // Method untuk validasi dan membersihkan data item
  List<Map<String, dynamic>> _validateAndCleanItems(dynamic items) {
    if (items == null) return [];
    
    if (items is! List) {
      print('❌ Items is not a List: ${items.runtimeType}');
      return [];
    }
    
    List<Map<String, dynamic>> cleanItems = [];
    
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      
      if (item is Map) {
        // Validasi field yang diperlukan
        final cleanItem = <String, dynamic>{
          'name': item['name']?.toString() ?? 'Unknown Item',
          'quantity': _toInt(item['quantity']),
          'price': _toDouble(item['price']),
        };
        cleanItems.add(cleanItem);
        print('✅ Clean item added: $cleanItem');
      } else {
        print('❌ Invalid item type at index $i: ${item.runtimeType}');
      }
    }
    
    return cleanItems;
  }

  // Method debug untuk melihat struktur data
  void _debugPrintNoteStructure(Map<String, dynamic> note) {
    print('🐛 === DEBUG NOTE STRUCTURE ===');
    print('🐛 Note keys: ${note.keys.toList()}');
    print('🐛 Customer: ${note['customerName']}');
    print('🐛 Total: ${note['totalAmount']}');
    print('🐛 Date: ${note['date']}');
    print('🐛 Items: ${note['items']}');
    print('🐛 Items type: ${note['items'].runtimeType}');
    
    if (note['items'] != null) {
      final items = note['items'];
      if (items is List) {
        print('🐛 Items length: ${items.length}');
        for (int i = 0; i < items.length; i++) {
          print('🐛 Item $i: ${items[i]}');
          print('🐛 Item $i type: ${items[i].runtimeType}');
          if (items[i] is Map) {
            final item = items[i] as Map;
            print('🐛 Item $i keys: ${item.keys.toList()}');
            print('🐛 Item $i name: ${item['name']}');
            print('🐛 Item $i quantity: ${item['quantity']}');
            print('🐛 Item $i price: ${item['price']}');
          }
        }
      }
    }
    print('🐛 === END DEBUG ===');
  }

  Future<void> _loadWholesaleNotes() async {
    print('🔄 Mulai loading wholesale notes...');
    setState(() {
      isLoading = true;
    });
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final notesJson = prefs.getString('wholesale_notes');
      
      print('📖 Loading notes from SharedPreferences: $notesJson');
      
      if (notesJson != null && notesJson.isNotEmpty && notesJson != 'null') {
        print('✅ Found notes data, parsing...');
        final List<dynamic> notesList = json.decode(notesJson);
        setState(() {
          wholesaleNotes = notesList.map((note) => {
            ...Map<String, dynamic>.from(note),
            'date': DateTime.parse(note['date'].toString()),
          }).toList();
        });
        
        print('✅ Loaded ${wholesaleNotes.length} notes from SharedPreferences');
        print('📝 Notes: $wholesaleNotes');
      } else {
        print('❌ No notes found in SharedPreferences');
        setState(() {
          wholesaleNotes = [];
        });
        
        // Coba buat data dummy untuk testing
        print('🧪 Creating test data...');
        await _createTestData();
      }
    } catch (e) {
      print('❌ Error loading wholesale notes: $e');
      setState(() {
        wholesaleNotes = [];
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Method untuk membuat data test (hapus setelah testing)
  Future<void> _createTestData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final testData = [
        {
          'id': 'test-1',
          'customerName': 'Test Customer',
          'totalAmount': 100000.0,
          'date': DateTime.now().toIso8601String(),
          'items': [
            {'name': 'Test Product', 'quantity': 2, 'price': 50000.0}
          ]
        }
      ];
      
      await prefs.setString('wholesale_notes', json.encode(testData));
      print('🧪 Test data created');
      
      // Reload setelah membuat test data
      await _loadWholesaleNotes();
    } catch (e) {
      print('❌ Error creating test data: $e');
    }
  }

  Future<void> _saveWholesaleNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notesJson = json.encode(
        wholesaleNotes.map((note) => {
          ...note,
          'date': note['date'].toIso8601String(),
        }).toList(),
      );
      await prefs.setString('wholesale_notes', notesJson);
      
      print('Saved ${wholesaleNotes.length} notes to SharedPreferences');
    } catch (e) {
      print('Error saving wholesale notes: $e');
    }
  }

  void _addNewNote(Map<String, dynamic> newNote) {
    setState(() {
      wholesaleNotes.insert(0, newNote);
    });
    _saveWholesaleNotes();
    
    print('Added new note. Total notes: ${wholesaleNotes.length}');
  }

  void _deleteNote(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Catatan'),
        content: Text('Apakah Anda yakin ingin menghapus catatan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                wholesaleNotes.removeAt(index);
              });
              _saveWholesaleNotes();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Catatan berhasil dihapus')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Hapus'),
          ),
        ],
      ),
    );
  }

  // Method untuk refresh data
  Future<void> _refreshData() async {
    await _loadWholesaleNotes();
  }

  void _showNoteDetails(Map<String, dynamic> note) {
    // Debug print untuk melihat struktur data
    _debugPrintNoteStructure(note);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detail Catatan Grosir'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Pelanggan', note['customerName'] ?? 'Unknown'),
              SizedBox(height: 8),
              _buildDetailRow('Tanggal', _formatDate(note['date'])),
              SizedBox(height: 8),
              _buildDetailRow('Total', 'Rp ${_formatCurrency(note['totalAmount'] ?? 0.0)}'),
              SizedBox(height: 16),
              Text(
                'Daftar Produk:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              // Perbaikan bagian items
              if (note['items'] != null) ...[
                ...() {
                  final validItems = _validateAndCleanItems(note['items']);
                  
                  if (validItems.isEmpty) {
                    return [
                      Card(
                        color: Colors.orange[50],
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Icon(Icons.warning, color: Colors.orange),
                              SizedBox(width: 8),
                              Text(
                                'Tidak ada produk valid',
                                style: TextStyle(color: Colors.orange[800]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ];
                  }
                  
                  return validItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    
                    return Card(
                      color: Colors.grey[50],
                      margin: EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${index + 1}. ${item['name']}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Qty: ${item['quantity']}',
                              style: TextStyle(fontSize: 13),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Harga: Rp ${_formatCurrency(item['price'])}',
                              style: TextStyle(fontSize: 13),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Subtotal: Rp ${_formatCurrency((item['quantity'] as int) * (item['price'] as double))}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList();
                }(),
              ] else ...[
                Card(
                  color: Colors.orange[50],
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Tidak ada produk atau data tidak valid',
                          style: TextStyle(color: Colors.orange[800]),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown Date';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
        
        // Handle navigation based on index
        switch (index) {
          case 0:
            AppRoutes.navigateTo(context, AppRoutes.dashboard);
            break;
          case 1:
            AppRoutes.navigateTo(context, AppRoutes.inventory);
            break;
          case 2:
            AppRoutes.navigateTo(context, AppRoutes.orders);
            break;
          case 3:
            AppRoutes.navigateTo(context, AppRoutes.transactions);
            break;
          case 4:
            // More options - could show a modal bottom sheet with additional options
            _showMoreOptions();
            break;
        }
      },
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory),
          label: 'Inventory',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt),
          label: 'Transactions',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.more_horiz),
          label: 'More',
        ),
      ],
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Financial Reports'),
              onTap: () {
                Navigator.pop(context);
                AppRoutes.navigateTo(context, AppRoutes.financialReports);
              },
            ),
            ListTile(
              leading: const Icon(Icons.store),
              title: const Text('Wholesale Notes'),
              onTap: () {
                Navigator.pop(context);
                AppRoutes.navigateTo(context, AppRoutes.wholesaleNotes);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                AppRoutes.replaceWith(context, AppRoutes.login);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Catatan Grosir')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        showBackButton: false,
        title: 'Catatan Grosir',
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            color: const Color.fromARGB(255, 255, 255, 255),
            onPressed: _refreshData,
          ),
          IconButton(
            icon: Icon(Icons.camera_alt),
            color: const Color.fromARGB(255, 255, 255, 255),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CaptureReceiptScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.add),
            color: const Color.fromARGB(255, 255, 255, 255),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddWholesaleNoteScreen(),
                ),
              );
              
              if (result != null) {
                _addNewNote(result);
              }
              
              // Refresh data setelah kembali dari halaman add
              await _refreshData();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: wholesaleNotes.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.note_add, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Belum ada catatan grosir',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 8),
                    Text('Tap tombol + untuk menambah catatan baru'),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshData,
                      child: Text('Refresh'),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.all(8),
                itemCount: wholesaleNotes.length,
                itemBuilder: (context, index) {
                  final note = wholesaleNotes[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Icon(Icons.receipt),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      title: Text(
                        note['customerName'] ?? 'Unknown Customer',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_formatDate(note['date'])),
                          Text(
                            'Rp ${_formatCurrency(note['totalAmount'] ?? 0.0)}',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'detail',
                            child: Row(
                              children: [
                                Icon(Icons.info),
                                SizedBox(width: 8),
                                Text('Detail'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Hapus', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'detail') {
                            _showNoteDetails(note);
                          } else if (value == 'delete') {
                            _deleteNote(index);
                          }
                        },
                      ),
                      onTap: () {
                        _showNoteDetails(note);
                      },
                    ),
                  );
                },
              ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }
}