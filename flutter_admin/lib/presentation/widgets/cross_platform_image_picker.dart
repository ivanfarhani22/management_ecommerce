import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:html' as html show File, FileReader, Url, Blob;

class CrossPlatformImagePicker extends StatefulWidget {
  final Function(dynamic) onImageSelected;
  final bool allowCropping;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? iconColor;
  final String? placeholderText;

  const CrossPlatformImagePicker({
    super.key,
    required this.onImageSelected,
    this.allowCropping = false,
    this.width = 200,
    this.height = 200,
    this.backgroundColor,
    this.iconColor,
    this.placeholderText,
  });

  @override
  _CrossPlatformImagePickerState createState() => _CrossPlatformImagePickerState();
}

class _CrossPlatformImagePickerState extends State<CrossPlatformImagePicker> {
  final ImagePicker _picker = ImagePicker();
  dynamic _selectedImage;
  String? _previewUrl;
  bool _isLoading = false;

  @override
  void dispose() {
    // Clean up web preview URL if it exists
    if (kIsWeb && _previewUrl != null) {
      html.Url.revokeObjectUrl(_previewUrl!);
    }
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() {
        _isLoading = true;
      });

      if (kIsWeb) {
        await _pickImageWeb(source);
      } else {
        await _pickImageMobile(source);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImageMobile(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1000,
      maxHeight: 1000,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _previewUrl = null; // Not needed for mobile
      });
      widget.onImageSelected(_selectedImage);
    }
  }

  Future<void> _pickImageWeb(ImageSource source) async {
    // For web, we can only use gallery
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1000,
      maxHeight: 1000,
    );

    if (pickedFile != null) {
      // Read the file as bytes
      final bytes = await pickedFile.readAsBytes();
      
      // Clean up previous URL if it exists
      if (_previewUrl != null) {
        html.Url.revokeObjectUrl(_previewUrl!);
      }
      
      // Create a blob and URL for preview
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      
      setState(() {
        _selectedImage = bytes;
        _previewUrl = url;
      });
      
      widget.onImageSelected(_selectedImage);
    }
  }

  Widget _buildImagePreview() {
    if (_selectedImage == null) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: 50,
              color: widget.iconColor ?? Colors.grey.shade600,
            ),
            if (widget.placeholderText != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  widget.placeholderText!,
                  style: TextStyle(color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      );
    }

    if (kIsWeb && _previewUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          _previewUrl!,
          width: widget.width,
          height: widget.height,
          fit: BoxFit.cover,
        ),
      );
    } else if (!kIsWeb && _selectedImage is File) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          _selectedImage,
          width: widget.width,
          height: widget.height,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.broken_image,
        size: 50,
        color: widget.iconColor ?? Colors.grey.shade600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => _showImageSourceDialog(),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Image preview
              _buildImagePreview(),
              
              // Loading indicator
              if (_isLoading)
                Container(
                  width: widget.width,
                  height: widget.height,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => _showImageSourceDialog(),
              icon: const Icon(Icons.photo_library),
              label: const Text('Pilih Gambar'),
            ),
            if (_selectedImage != null) ...[
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    if (kIsWeb && _previewUrl != null) {
                      html.Url.revokeObjectUrl(_previewUrl!);
                      _previewUrl = null;
                    }
                    _selectedImage = null;
                  });
                  widget.onImageSelected(null);
                },
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text('Hapus', style: TextStyle(color: Colors.red)),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Future<void> _showImageSourceDialog() async {
    if (kIsWeb) {
      // For web, just pick from gallery directly
      await _pickImage(ImageSource.gallery);
    } else {
      // For mobile, show a dialog with options
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Ambil Gambar Dari'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Kamera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeri'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      );
    }
  }
}