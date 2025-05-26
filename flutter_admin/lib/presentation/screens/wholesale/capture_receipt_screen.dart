import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import './widgets/receipt_image_viewer.dart';

class CaptureReceiptScreen extends StatefulWidget {
  const CaptureReceiptScreen({super.key});

  @override
  _CaptureReceiptScreenState createState() => _CaptureReceiptScreenState();
}

class _CaptureReceiptScreenState extends State<CaptureReceiptScreen> {
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> _receiptImages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedImages();
  }

  Future<void> _loadSavedImages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final imagesJson = prefs.getString('receipt_images');
      
      if (imagesJson != null) {
        final List<dynamic> imagesList = json.decode(imagesJson);
        setState(() {
          _receiptImages = imagesList.map((img) => Map<String, dynamic>.from(img)).toList();
        });
      }
    } catch (e) {
      print('Error loading saved images: $e');
    }
  }

  Future<void> _saveImagesList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final imagesJson = json.encode(_receiptImages);
      await prefs.setString('receipt_images', imagesJson);
    } catch (e) {
      print('Error saving images list: $e');
    }
  }

  Future<bool> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Izin kamera diperlukan untuk mengambil foto'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Pengaturan',
            onPressed: () => openAppSettings(),
          ),
        ),
      );
      return false;
    }
    return true;
  }

  Future<String> _saveImageToLocalStorage(XFile image) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final receiptDir = Directory('${appDir.path}/receipts');
      
      if (!await receiptDir.exists()) {
        await receiptDir.create(recursive: true);
      }

      final fileName = 'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = File('${receiptDir.path}/$fileName');
      
      await savedImage.writeAsBytes(await image.readAsBytes());
      return savedImage.path;
    } catch (e) {
      print('Error saving image: $e');
      throw e;
    }
  }

  Future<void> _captureImage() async {
    if (!await _requestCameraPermission()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      
      if (image != null) {
        final savedPath = await _saveImageToLocalStorage(image);
        
        setState(() {
          _receiptImages.add({
            'path': savedPath,
            'name': 'Foto ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
            'date': DateTime.now().toIso8601String(),
          });
        });
        
        await _saveImagesList();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Foto berhasil disimpan'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil foto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      
      for (XFile image in images) {
        final savedPath = await _saveImageToLocalStorage(image);
        
        setState(() {
          _receiptImages.add({
            'path': savedPath,
            'name': 'Galeri ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
            'date': DateTime.now().toIso8601String(),
          });
        });
      }
      
      if (images.isNotEmpty) {
        await _saveImagesList();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${images.length} foto berhasil disimpan'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memilih foto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _viewImage(Map<String, dynamic> imageData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReceiptImageViewer(
          imagePath: imageData['path'],
        ),
      ),
    );
  }

  Future<void> _deleteImage(int index) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Foto'),
        content: Text('Apakah Anda yakin ingin menghapus foto ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final imageData = _receiptImages[index];
                final file = File(imageData['path']);
                
                if (await file.exists()) {
                  await file.delete();
                }
                
                setState(() {
                  _receiptImages.removeAt(index);
                });
                
                await _saveImagesList();
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Foto berhasil dihapus'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal menghapus foto: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAllImages() async {
    if (_receiptImages.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Semua Foto'),
        content: Text('Apakah Anda yakin ingin menghapus semua foto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                for (final imageData in _receiptImages) {
                  final file = File(imageData['path']);
                  if (await file.exists()) {
                    await file.delete();
                  }
                }
                
                setState(() {
                  _receiptImages.clear();
                });
                
                await _saveImagesList();
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Semua foto berhasil dihapus'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal menghapus foto: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Hapus Semua'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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
        title: Text('Bukti Pembayaran'),
        actions: [
          if (_receiptImages.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_sweep),
              color: const Color.fromARGB(255, 255, 255, 255),
              onPressed: _deleteAllImages,
            ),
        ],
      ),
      body: Column(
        children: [
          if (_isLoading)
            LinearProgressIndicator(),
          Expanded(
            child: _receiptImages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Belum ada foto yang disimpan',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Ambil foto atau pilih dari galeri',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: _receiptImages.length,
                    itemBuilder: (context, index) {
                      final imageData = _receiptImages[index];
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _viewImage(imageData),
                                child: Image.file(
                                  File(imageData['path']),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],
                                      child: Icon(
                                        Icons.broken_image,
                                        size: 48,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    imageData['name'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _formatDate(DateTime.parse(imageData['date'])),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => _deleteImage(index),
                                        child: Icon(
                                          Icons.delete,
                                          size: 16,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _captureImage,
                    icon: Icon(Icons.camera_alt, color: Colors.white,),
                    label: Text('Ambil Foto'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _pickImageFromGallery,
                    icon: Icon(Icons.photo_library, color: Colors.white,),
                    label: Text('Galeri'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}