import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb;

class ImagePickerWidget extends StatefulWidget {
  final String? initialImageUrl;
  final Function(File) onImageSelected;
  final bool allowCropping;
  final double size;

  const ImagePickerWidget({
    super.key,
    this.initialImageUrl,
    required this.onImageSelected,
    this.allowCropping = false,
    this.size = 150.0,
  });

  @override
  _ImagePickerWidgetState createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  Future<bool> _requestPermission(Permission permission) async {
    if (kIsWeb) return true; // Web tidak memerlukan permission
    
    var status = await permission.status;
    
    if (status.isGranted) {
      return true;
    }
    
    if (status.isDenied) {
      status = await permission.request();
      return status.isGranted;
    }
    
    if (status.isPermanentlyDenied) {
      // Tampilkan dialog untuk membuka settings
      _showPermissionDialog(permission);
      return false;
    }
    
    return false;
  }

  void _showPermissionDialog(Permission permission) {
    String permissionName = permission == Permission.camera ? 'Kamera' : 'Penyimpanan';
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Izin $permissionName Diperlukan'),
          content: Text(
            'Aplikasi memerlukan akses $permissionName untuk mengambil foto. '
            'Silakan aktifkan izin di pengaturan aplikasi.',
          ),
          actions: [
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Buka Pengaturan'),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }

  void _showPermissionDeniedSnackBar(String permissionName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Izin $permissionName diperlukan untuk menggunakan fitur ini'),
        backgroundColor: Colors.orange,
        action: SnackBarAction(
          label: 'Pengaturan',
          onPressed: () => openAppSettings(),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      // Request permission berdasarkan source
      bool hasPermission = false;
      
      if (source == ImageSource.camera) {
        hasPermission = await _requestPermission(Permission.camera);
        if (!hasPermission) {
          _showPermissionDeniedSnackBar('kamera');
          return;
        }
      } else {
        // Untuk gallery, cek permission storage
        if (Platform.isAndroid) {
          // Android 13+ menggunakan permission yang berbeda
          if (await Permission.photos.status.isDenied) {
            hasPermission = await _requestPermission(Permission.photos);
          } else {
            hasPermission = await _requestPermission(Permission.storage);
          }
        } else if (Platform.isIOS) {
          hasPermission = await _requestPermission(Permission.photos);
        } else {
          hasPermission = true; // Platform lain
        }
        
        if (!hasPermission) {
          _showPermissionDeniedSnackBar('penyimpanan');
          return;
        }
      }

      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 80,
      );

      if (picked != null) {
        File imageFile = File(picked.path);
        
        if (widget.allowCropping &&
            !kIsWeb &&
            (defaultTargetPlatform == TargetPlatform.android || 
             defaultTargetPlatform == TargetPlatform.iOS)) {
          final croppedFile = await _cropImage(imageFile);
          if (croppedFile != null) {
            imageFile = croppedFile;
          } else {
            // User canceled cropping
            return;
          }
        } else if (widget.allowCropping) {
          debugPrint('Image cropping is not supported on this platform: ${defaultTargetPlatform.name}');
        }

        setState(() {
          _selectedImage = imageFile;
        });
        
        widget.onImageSelected(imageFile);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      String errorMessage = 'Error saat memilih gambar. Silakan coba lagi.';
      
      // Handle specific errors
      if (e.toString().contains('camera_access_denied')) {
        errorMessage = 'Akses kamera ditolak. Silakan aktifkan izin kamera di pengaturan.';
      } else if (e.toString().contains('photo_access_denied')) {
        errorMessage = 'Akses galeri ditolak. Silakan aktifkan izin penyimpanan di pengaturan.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<File?> _cropImage(File imageFile) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Theme.of(context).primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Crop Image',
          ),
        ],
      );

      if (croppedFile != null) {
        return File(croppedFile.path);
      }
    } catch (e) {
      debugPrint('Error cropping image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error saat memotong gambar. Silakan coba lagi.'),
          backgroundColor: Colors.red,
        ),
      );
    }
    return null;
  }

  // Method untuk check permission status (optional, untuk debugging)
  Future<void> _checkPermissionStatus() async {
    if (kIsWeb) return;
    
    final cameraStatus = await Permission.camera.status;
    final storageStatus = await Permission.storage.status;
    final photosStatus = await Permission.photos.status;
    
    debugPrint('Camera permission: ${cameraStatus.name}');
    debugPrint('Storage permission: ${storageStatus.name}');
    debugPrint('Photos permission: ${photosStatus.name}');
  }

  @override
  void initState() {
    super.initState();
    // Uncomment untuk debug permission status
    // _checkPermissionStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _selectedImage != null
                    ? Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('Error loading local image: $error');
                          return const Icon(Icons.broken_image, size: 50, color: Colors.grey);
                        },
                      )
                    : widget.initialImageUrl != null
                        ? Image.network(
                            widget.initialImageUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / 
                                        loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint('Error loading network image: $error');
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Gagal memuat gambar',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                  ),
                                ],
                              );
                            },
                          )
                        : const Icon(Icons.image, size: 50, color: Colors.grey),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                icon: const Icon(Icons.add_a_photo, color: Colors.white),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return SafeArea(
                        child: Wrap(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.photo_library),
                              title: const Text('Pilih dari Galeri'),
                              onTap: () {
                                Navigator.of(context).pop();
                                _pickImage(ImageSource.gallery);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.photo_camera),
                              title: const Text('Ambil Foto'),
                              onTap: () {
                                Navigator.of(context).pop();
                                _pickImage(ImageSource.camera);
                              },
                            ),
                            if (_selectedImage != null || widget.initialImageUrl != null)
                              ListTile(
                                leading: const Icon(Icons.delete, color: Colors.red),
                                title: const Text('Hapus Gambar', style: TextStyle(color: Colors.red)),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  setState(() {
                                    _selectedImage = null;
                                  });
                                  // Pass null to indicate image was removed
                                  // Note: This requires updating the parent widget to handle null
                                  // widget.onImageSelected(null);
                                },
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Tap untuk mengubah gambar',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }
}