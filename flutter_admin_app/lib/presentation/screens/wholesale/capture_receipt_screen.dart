import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import './widgets/receipt_image_viewer.dart';

class CaptureReceiptScreen extends StatefulWidget {
  const CaptureReceiptScreen({super.key});

  @override
  _CaptureReceiptScreenState createState() => _CaptureReceiptScreenState();
}

class _CaptureReceiptScreenState extends State<CaptureReceiptScreen> {
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _receiptImages = [];

  Future<void> _captureImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _receiptImages.add(image);
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images != null) {
      setState(() {
        _receiptImages.addAll(images);
      });
    }
  }

  void _viewImage(XFile image) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReceiptImageViewer(imagePath: image.path),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Unggah Bukti Pembayaran'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _receiptImages.isEmpty
                ? Center(
                    child: Text(
                      'Belum ada gambar yang diunggah',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  )
                : GridView.builder(
                    padding: EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _receiptImages.length,
                    itemBuilder: (context, index) {
                      final image = _receiptImages[index];
                      return GestureDetector(
                        onTap: () => _viewImage(image),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(
                              File(image.path),
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                icon: Icon(
                                  Icons.delete_forever,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _receiptImages.removeAt(index);
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _captureImage,
                  icon: Icon(Icons.camera_alt),
                  label: Text('Kamera'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _pickImageFromGallery,
                  icon: Icon(Icons.photo_library),
                  label: Text('Galeri'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _receiptImages.isNotEmpty ? _uploadReceipts : null,
              child: Text('Unggah Bukti'),
            ),
          ),
        ],
      ),
    );
  }

  void _uploadReceipts() {
    // TODO: Implement receipt upload logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bukti pembayaran berhasil diunggah')),
    );
    Navigator.pop(context);
  }
}