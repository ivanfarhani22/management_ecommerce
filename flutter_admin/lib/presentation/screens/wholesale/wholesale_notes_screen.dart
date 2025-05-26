import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
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
    barrierDismissible: true,
    builder: (context) {
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;
      
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primaryContainer,
                      colorScheme.primaryContainer.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.receipt_long,
                        color: const Color.fromARGB(255, 255, 255, 255),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Detail Catatan Grosir',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close_rounded,
                        color: colorScheme.onPrimaryContainer,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Customer Info Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildElegantDetailRow(
                              context,
                              Icons.storefront_outlined,
                              'Toko',
                              note['customerName'] ?? 'Unknown',
                            ),
                            const SizedBox(height: 16),
                            _buildElegantDetailRow(
                              context,
                              Icons.calendar_today_outlined,
                              'Tanggal',
                              _formatDate(note['date']),
                            ),
                            const SizedBox(height: 16),
                            _buildElegantDetailRow(
                              context,
                              Icons.account_balance_wallet_outlined,
                              'Total Pembayaran',
                              'Rp ${_formatCurrency(note['totalAmount'] ?? 0.0)}',
                              isTotal: true,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Products Section
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.inventory_2_outlined,
                              color: colorScheme.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Daftar Produk',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Products List
                      if (note['items'] != null) ...[
                        ...() {
                          final validItems = _validateAndCleanItems(note['items']);
                          
                          if (validItems.isEmpty) {
                            return [_buildEmptyState(context, 'Tidak ada produk valid')];
                          }
                          
                          return validItems.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: colorScheme.outline.withOpacity(0.2),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.shadow.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: colorScheme.primary,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${index + 1}',
                                            style: TextStyle(
                                              color: colorScheme.onPrimary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          item['name'],
                                          style: theme.textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildProductDetail(
                                          context,
                                          'Kuantitas',
                                          '${item['quantity']}',
                                          Icons.straighten,
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildProductDetail(
                                          context,
                                          'Harga Satuan',
                                          'Rp ${_formatCurrency(item['price'])}',
                                          Icons.attach_money,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Subtotal',
                                          style: theme.textTheme.labelMedium?.copyWith(
                                            fontWeight: FontWeight.w500,
                                            color: Colors.green[700],
                                          ),
                                        ),
                                        Text(
                                          'Rp ${_formatCurrency((item['quantity'] as int) * (item['price'] as double))}',
                                          style: theme.textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList();
                        }(),
                      ] else ...[
                        _buildEmptyState(context, 'Tidak ada produk atau data tidak valid'),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildElegantDetailRow(
  BuildContext context,
  IconData icon,
  String label,
  String value, {
  bool isTotal = false,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isTotal 
              ? Colors.green.withOpacity(0.1)
              : colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isTotal ? Colors.green[700] : colorScheme.primary,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isTotal ? Colors.green[700] : colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildProductDetail(
  BuildContext context,
  String label,
  String value,
  IconData icon,
) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
      Text(
        value,
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ),
    ],
  );
}

Widget _buildEmptyState(BuildContext context, String message) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.orange.withOpacity(0.05),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Colors.orange.withOpacity(0.2),
      ),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange[700],
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.orange[800],
              fontWeight: FontWeight.w500,
            ),
          ),
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
    // Gunakan SpeedDial dari package flutter_speed_dial
    floatingActionButton: SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      activeForegroundColor: Colors.white,
      activeBackgroundColor: Theme.of(context).primaryColor,
      visible: true,
      closeManually: false,
      curve: Curves.bounceIn,
      overlayColor: Colors.black,
      overlayOpacity: 0.3,
      tooltip: 'Menu',
      heroTag: "speed-dial-hero-tag",
      elevation: 8.0,
      shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15), // Atur radius sesuai keinginan
      ),
      children: [
        SpeedDialChild(
          child: Icon(Icons.add),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddWholesaleNoteScreen(),
              ),
            );
            
            if (result != null) {
              _addNewNote(result);
            }
            
            await _refreshData();
          },
        ),
        SpeedDialChild(
          child: Icon(Icons.camera_alt),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CaptureReceiptScreen(),
              ),
            );
          },
        ),
      ],
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
  );
}
}
