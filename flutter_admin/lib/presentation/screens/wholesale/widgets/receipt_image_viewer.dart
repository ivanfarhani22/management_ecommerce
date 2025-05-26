import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ReceiptImageViewer extends StatelessWidget {
  final String imagePath;

  const ReceiptImageViewer({
    super.key, 
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    // Check if file exists
    final file = File(imagePath);
    if (!file.existsSync()) {
      return Scaffold(
        appBar: AppBar(title: Text('Pratinjau Bukti')),
        body: Center(
          child: Text('Gambar tidak ditemukan', 
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: const Color.fromARGB(255, 255, 255, 255),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Pratinjau Bukti'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever),
            color: const Color.fromARGB(255, 255, 255, 255),
            onPressed: () {
              _showDeleteConfirmationDialog(context);
            },
          ),
        ],
      ),
      body: PhotoView(
        imageProvider: FileImage(file),
        minScale: PhotoViewComputedScale.contained * 0.8,
        maxScale: PhotoViewComputedScale.covered * 2,
        initialScale: PhotoViewComputedScale.contained,
        backgroundDecoration: BoxDecoration(
          color: Colors.black,
        ),
        loadingBuilder: (context, event) => Center(
          child: CircularProgressIndicator(),
        ),
        errorBuilder: (context, error, stackTrace) => Center(
          child: Text(
            'Gagal memuat gambar',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Bukti'),
        content: Text('Apakah Anda yakin ingin menghapus bukti ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement actual file deletion logic
              File(imagePath).deleteSync();
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close image viewer
            },
            child: Text('Hapus'),
          ),
        ],
      ),
    );
  }
}