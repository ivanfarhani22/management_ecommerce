import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/image_picker_widget.dart';
import '../../widgets/error_dialog.dart';
import '../../widgets/confirmation_dialog.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import '../../../config/app_config.dart';

class EditProductScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const EditProductScreen({super.key, required this.product});

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _secureStorage = const FlutterSecureStorage();
  final _imagePicker = ImagePicker();
  
  // Form Controllers
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _stockController;
  late TextEditingController _priceController;
  
  // State variables
  int? _selectedCategoryId;
  String? _selectedCategoryName;
  File? _selectedImage;
  String? _currentImageUrl;
  bool _isLoading = false;
  bool _isFetchingCategories = true;
  int _androidSdkVersion = 0;

  // Categories from API
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing product data
    _nameController = TextEditingController(text: widget.product['name']);
    _descriptionController = TextEditingController(text: widget.product['description'] ?? '');
    _stockController = TextEditingController(text: widget.product['stock'].toString());
    _priceController = TextEditingController(text: widget.product['price'].toString());
    
    // Fix image URL by prepending the base URL if it's not already a full URL
    final imageUrl = widget.product['image'];
    if (imageUrl != null && imageUrl.isNotEmpty) {
      if (imageUrl.startsWith('http')) {
        _currentImageUrl = imageUrl;
      } else {
        // Add the storage URL prefix
        _currentImageUrl = '${AppConfig.storageBaseUrl}/$imageUrl';
      }
      debugPrint('Image URL set to: $_currentImageUrl');
    }
    
    _selectedCategoryId = widget.product['category_id'];
    
    // Initialize app
    _initializeApp();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _stockController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    await _getAndroidVersion();
    await _fetchCategories();
    // HAPUS _checkAndRequestPermissions() dari init karena sekarang per-action
  }

  Future<void> _getAndroidVersion() async {
    if (Platform.isAndroid) {
      try {
        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        _androidSdkVersion = androidInfo.version.sdkInt;
        debugPrint('Android SDK Version: $_androidSdkVersion');
      } catch (e) {
        debugPrint('Error getting Android version: $e');
        _androidSdkVersion = 30; // Default to API 30 if error
      }
    }
  }

  // Method untuk request camera permission (HANYA untuk kamera)
  Future<bool> _requestCameraPermission() async {
    try {
      debugPrint('Requesting camera permission only');
      
      PermissionStatus cameraStatus = await Permission.camera.status;
      debugPrint('Camera permission status: $cameraStatus');
      
      if (cameraStatus != PermissionStatus.granted) {
        cameraStatus = await Permission.camera.request();
        debugPrint('Camera permission after request: $cameraStatus');
        
        if (cameraStatus == PermissionStatus.permanentlyDenied) {
          _showPermissionDialog('Kamera', true);
          return false;
        } else if (cameraStatus != PermissionStatus.granted) {
          _showPermissionDialog('Kamera', false);
          return false;
        }
      }
      
      debugPrint('✓ Camera permission granted');
      return true;
    } catch (e) {
      debugPrint('Error requesting camera permission: $e');
      _showPermissionErrorDialog(e.toString());
      return false;
    }
  }

  // Dialog untuk permission
  void _showPermissionDialog(String permissionType, bool isPermanentlyDenied) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Izin Diperlukan'),
        content: Text(
          isPermanentlyDenied
              ? 'Aplikasi memerlukan izin $permissionType untuk mengambil foto produk. '
                'Izin telah ditolak secara permanen. Silakan berikan izin di pengaturan aplikasi.'
              : 'Aplikasi memerlukan izin $permissionType untuk mengambil foto produk. '
                'Silakan berikan izin untuk melanjutkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (isPermanentlyDenied) {
                openAppSettings();
              } else {
                _requestCameraPermission();
              }
            },
            child: Text(isPermanentlyDenied ? 'Buka Pengaturan' : 'Coba Lagi'),
          ),
        ],
      ),
    );
  }

  // Dialog untuk error permission
  void _showPermissionErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error Permission'),
        content: Text(
          'Terjadi kesalahan saat meminta izin: $error\n\n'
          'Catatan:\n'
          '• CAMERA permission diperlukan untuk kamera\n'
          '• GALLERY tidak memerlukan permission di Android 10+\n\n'
          'Pastikan manifest sudah benar dan coba restart aplikasi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Method untuk pick image - SUDAH DIPERBAIKI UNTUK GALLERY TANPA PERMISSION
  Future<void> _pickImage(ImageSource source) async {
    try {
      debugPrint('Attempting to pick image from: $source');
      
      // HANYA untuk camera yang perlu check permission
      if (source == ImageSource.camera) {
        bool hasPermission = await _requestCameraPermission();
        if (!hasPermission) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Izin kamera diperlukan untuk mengambil foto'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }
      // Untuk gallery, LANGSUNG TANPA permission check
      else if (source == ImageSource.gallery) {
        debugPrint('Gallery access - no permission required for Android 10+ scoped storage');
      }

      // Langsung pick image tanpa additional permission check untuk gallery
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        debugPrint('Image picked successfully: ${imageFile.path}');
        
        // Optional: Crop image
        final croppedFile = await _cropImage(imageFile);
        
        setState(() {
          _selectedImage = croppedFile ?? imageFile;
        });
        
        debugPrint('Image selected and set: ${_selectedImage?.path}');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                source == ImageSource.camera 
                    ? 'Foto berhasil diambil dari kamera'
                    : 'Gambar berhasil dipilih dari galeri'
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        debugPrint('No image was selected');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                source == ImageSource.camera 
                    ? 'Tidak ada foto yang diambil'
                    : 'Tidak ada gambar yang dipilih'
              ),
              backgroundColor: Colors.grey,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      
      if (mounted) {
        String errorMessage = 'Gagal mengambil gambar';
        
        if (source == ImageSource.camera) {
          if (e.toString().toLowerCase().contains('permission') || 
              e.toString().toLowerCase().contains('denied')) {
            errorMessage = 'Izin kamera tidak diberikan';
          } else if (e.toString().toLowerCase().contains('camera') && 
                     e.toString().toLowerCase().contains('unavailable')) {
            errorMessage = 'Kamera tidak tersedia saat ini';
          } else {
            errorMessage = 'Gagal mengambil foto dari kamera';
          }
        } else {
          // Gallery errors
          if (e.toString().toLowerCase().contains('no application found') ||
             e.toString().toLowerCase().contains('no activity found')) {
            errorMessage = 'Tidak ada aplikasi galeri yang tersedia';
          } else {
            errorMessage = 'Gagal membuka galeri';
          }
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<File?> _cropImage(File imageFile) async {
    try {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Gambar',
            toolbarColor: Theme.of(context).primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9
            ],
          ),
          IOSUiSettings(
            title: 'Crop Gambar',
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9
            ],
          ),
        ],
      );

      if (croppedFile != null) {
        return File(croppedFile.path);
      }
    } catch (e) {
      debugPrint('Error cropping image: $e');
      // Return original image if cropping fails
    }
    return null;
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    // Get token from secure storage
    final token = await _secureStorage.read(key: 'auth_token');
    
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}',
    };
  }

  Future<void> _fetchCategories() async {
    setState(() => _isFetchingCategories = true);

    try {
      debugPrint('Fetching categories from: ${AppConfig.baseApiUrl}/v1/categories');
      
      // Use authentication header
      final headers = await _getAuthHeaders();
      
      final response = await http.get(
        Uri.parse('${AppConfig.baseApiUrl}/v1/categories'),
        headers: headers,
      ).timeout(AppConfig.apiTimeout);

      debugPrint('Status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body.substring(0, min(100, response.body.length))}...');

      if (response.body.trim().startsWith('<!DOCTYPE html>') ||
          response.body.trim().startsWith('<html>')) {
        throw FormatException('Received HTML instead of JSON. Check your API endpoint and server configuration.');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          setState(() {
            _categories = List<Map<String, dynamic>>.from(data['data']);
            
            // Find the category name based on the product's category_id
            if (_selectedCategoryId != null) {
              final category = _categories.firstWhere(
                (cat) => cat['id'] == _selectedCategoryId,
                orElse: () => {'id': _selectedCategoryId, 'name': 'Unknown Category'},
              );
              _selectedCategoryName = category['name'];
            } else if (_categories.isNotEmpty) {
              _selectedCategoryId = _categories[0]['id'];
              _selectedCategoryName = _categories[0]['name'];
            }
          });
        }
      } else if (response.statusCode == 401) {
        // Handle unauthorized case - redirect to login
        _handleUnauthorized();
        throw Exception('Unauthorized: Please login again');
      } else {
        throw Exception('Failed to load categories: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      ErrorDialog.show(
        context,
        title: 'Gagal Memuat Kategori',
        message: 'Detail error: ${e.toString()}',
      );

      setState(() {
        _categories = [
          {'id': 1, 'name': 'Default Category'},
          {'id': 2, 'name': 'Other'},
        ];
        if (_selectedCategoryId == null) {
          _selectedCategoryId = 1;
          _selectedCategoryName = 'Default Category';
        }
      });
    } finally {
      setState(() => _isFetchingCategories = false);
    }
  }

  void _handleUnauthorized() {
    // Delete invalid token
    _secureStorage.delete(key: 'auth_token');
    
    // Show dialog and redirect to login page
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Sesi Berakhir'),
        content: const Text('Silakan login kembali untuk melanjutkan.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to login page and remove all previous routes
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateProduct() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        debugPrint('Updating product at: ${AppConfig.baseApiUrl}/v1/products/${widget.product['id']}');

        // Get auth token for the request
        final token = await _secureStorage.read(key: 'auth_token');
        
        // Create multipart request
        final request = http.MultipartRequest(
          'POST', // Some APIs use POST with _method=PUT for file uploads
          Uri.parse('${AppConfig.baseApiUrl}/v1/products/${widget.product['id']}'),
        );

        // Add authorization headers
        request.headers.addAll({
          'Accept': 'application/json',
          'Authorization': 'Bearer ${token ?? ''}',
        });

        // Add method override for RESTful API
        request.fields['_method'] = 'PUT';

        // Add text fields
        request.fields['name'] = _nameController.text;
        request.fields['description'] = _descriptionController.text;
        request.fields['price'] = _priceController.text;
        request.fields['stock'] = _stockController.text;
        request.fields['category_id'] = _selectedCategoryId.toString();
        request.fields['is_active'] = '1';

        // Add image file if selected
        if (_selectedImage != null) {
          final fileName = path.basename(_selectedImage!.path);
          final fileExtension = path.extension(fileName).toLowerCase().replaceFirst('.', '');
          
          // Determine the correct MIME type based on file extension
          String mimeType;
          switch (fileExtension) {
            case 'jpg':
            case 'jpeg':
              mimeType = 'image/jpeg';
              break;
            case 'png':
              mimeType = 'image/png';
              break;
            case 'gif':
              mimeType = 'image/gif';
              break;
            case 'webp':
              mimeType = 'image/webp';
              break;
            default:
              mimeType = 'image/jpeg'; // Default to JPEG if unknown
          }
          
          request.files.add(
            await http.MultipartFile.fromPath(
              'image',
              _selectedImage!.path,
              contentType: MediaType.parse(mimeType),
            ),
          );
        }

        debugPrint('Sending multipart request...');
        
        // Send the request
        final streamedResponse = await request.send().timeout(AppConfig.apiTimeout);
        final response = await http.Response.fromStream(streamedResponse);

        debugPrint('Status code: ${response.statusCode}');
        debugPrint('Response body: ${response.body.substring(0, min(100, response.body.length))}...');

        if (response.body.trim().startsWith('<!DOCTYPE html>') ||
            response.body.trim().startsWith('<html>')) {
          throw FormatException('Received HTML instead of JSON. Check your API endpoint and server configuration.');
        }

        if (response.statusCode == 401) {
          _handleUnauthorized();
          throw Exception('Unauthorized: Please login again');
        } else if (response.statusCode == 200 || response.statusCode == 201) {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Produk Berhasil Diperbarui'),
              content: Text('${_nameController.text} telah diperbarui.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          Map<String, dynamic>? errorData;
          try {
            errorData = json.decode(response.body);
          } catch (e) {
            throw Exception('Error (${response.statusCode}): ${response.body}');
          }
          throw Exception(errorData?['message'] ?? 'Gagal memperbarui produk (${response.statusCode})');
        }
      } catch (e) {
        debugPrint('Error updating product: $e');
        ErrorDialog.show(
          context,
          title: 'Gagal Memperbarui Produk',
          message: 'Detail error: ${e.toString()}',
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteProduct() async {
    final confirmDelete = await ConfirmationDialog.show(
      context,
      title: 'Hapus Produk',
      message: 'Apakah Anda yakin ingin menghapus produk ${widget.product['name']}?',
      confirmText: 'Hapus',
      cancelText: 'Batal',
    );

    if (confirmDelete == true) {
      setState(() => _isLoading = true);

      try {
        debugPrint('Deleting product at: ${AppConfig.baseApiUrl}/v1/products/${widget.product['id']}');

        // Get auth headers
        final headers = await _getAuthHeaders();
        
        // Send DELETE request
        final response = await http.delete(
          Uri.parse('${AppConfig.baseApiUrl}/v1/products/${widget.product['id']}'),
          headers: headers,
        ).timeout(AppConfig.apiTimeout);

        debugPrint('Status code: ${response.statusCode}');
        debugPrint('Response body: ${response.body.substring(0, min(100, response.body.length))}...');

        if (response.statusCode == 401) {
          _handleUnauthorized();
          throw Exception('Unauthorized: Please login again');
        } else if (response.statusCode == 200 || response.statusCode == 204) {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Produk Berhasil Dihapus'),
              content: Text('${widget.product['name']} telah dihapus dari inventori.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          Map<String, dynamic>? errorData;
          try {
            errorData = json.decode(response.body);
          } catch (e) {
            throw Exception('Error (${response.statusCode}): ${response.body}');
          }
          throw Exception(errorData?['message'] ?? 'Gagal menghapus produk (${response.statusCode})');
        }
      } catch (e) {
        debugPrint('Error deleting product: $e');
        ErrorDialog.show(
          context,
          title: 'Gagal Menghapus Produk',
          message: 'Detail error: ${e.toString()}',
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  int min(int a, int b) {
    return a < b ? a : b;
  }

  // Method untuk show image picker options - UPDATED
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Pilih Sumber Gambar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text('Ambil dari Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_selectedImage != null || _currentImageUrl != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Hapus Gambar'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedImage = null;
                      _currentImageUrl = null;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Gambar telah dihapus'),
                        backgroundColor: Colors.orange,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(
          color: Color.fromARGB(255, 255, 255, 255),
        ),
        title: const Text('Edit Produk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteProduct,
          ),
        ],
        

      ),
      body: _isFetchingCategories
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // IMAGE PICKER SECTION - UPDATED (mengganti ImagePickerWidget dengan implementasi manual)
                    Center(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _showImagePickerOptions,
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: _selectedImage != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        _selectedImage!,
                                        width: 150,
                                        height: 150,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : _currentImageUrl != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            _currentImageUrl!,
                                            width: 150,
                                            height: 150,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return const Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.broken_image,
                                                    size: 50,
                                                    color: Colors.grey,
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    'Gambar tidak dapat dimuat',
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 12,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        )
                                      : const Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.add_a_photo,
                                              size: 50,
                                              color: Colors.grey,
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Tambah Gambar',
                                              style: TextStyle(color: Colors.grey),
                                            ),
                                          ],
                                        ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Ketuk untuk menambah/mengubah gambar',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Product Name
                    CustomTextField(
                      controller: _nameController,
                      labelText: 'Nama Produk',
                      prefixIcon: Icons.label,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama produk tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description
                    CustomTextField(
                      controller: _descriptionController,
                      labelText: 'Deskripsi',
                      prefixIcon: Icons.description,
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Deskripsi tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _selectedCategoryId,
                      decoration: InputDecoration(
                        labelText: 'Kategori',
                        prefixIcon: const Icon(Icons.category),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: _categories.map<DropdownMenuItem<int>>((category) {
                        return DropdownMenuItem<int>(
                          value: category['id'] as int,
                          child: Text(category['name'] as String),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryId = value;
                          _selectedCategoryName = _categories.firstWhere((cat) => cat['id'] == value)['name'] as String;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Pilih kategori produk';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _stockController,
                      labelText: 'Stok',
                      prefixIcon: Icons.inventory,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Stok tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _priceController,
                      labelText: 'Harga',
                      prefixIcon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Harga tidak boleh kosong';
                        }
                        try {
                          double.parse(value);
                        } catch (_) {
                          return 'Format harga tidak valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                     // Update Button
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : CustomButton(
                            text: 'Perbarui Produk',
                            onPressed: _updateProduct,
                            icon: Icons.save,
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}

                   