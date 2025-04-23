import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
    
    // Fetch categories from API
    _fetchCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _stockController.dispose();
    _priceController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                    // Image Picker
                    Center(
                     child: ImagePickerWidget(
                      initialImageUrl: _currentImageUrl, // Now using the full URL
                      onImageSelected: (image) {
                        setState(() {
                          _selectedImage = image;
                        });
                      },
                      allowCropping: true,
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

                    // Category Dropdown
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

                    // Stock
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

                    // Price
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