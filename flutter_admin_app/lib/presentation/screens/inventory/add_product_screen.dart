import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/image_picker_widget.dart';
import '../../widgets/error_dialog.dart';
import 'dart:io';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form Controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _stockController = TextEditingController();
  final _priceController = TextEditingController();
  
  // Dropdown values
  String _selectedCategory = 'Jam';
  File? _selectedImage;
  bool _isLoading = false;

  // Category list
  final List<String> _categories = [
    'Jam',
    'Elektronik',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _stockController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _saveProduct() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        // TODO: Implement actual product save logic
        final productData = {
          'name': _nameController.text,
          'description': _descriptionController.text,
          'category': _selectedCategory,
          'stock': int.parse(_stockController.text),
          'price': double.parse(_priceController.text),
          'image': _selectedImage,
        };

        await Future.delayed(const Duration(seconds: 2));
        
        // Show success dialog
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Produk Berhasil Ditambahkan'),
            content: Text('${_nameController.text} telah ditambahkan ke inventori.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Go back to inventory
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } catch (e) {
        // Show error dialog
        ErrorDialog.show(
          context, 
          title: 'Gagal Menambahkan Produk', 
          message: e.toString()
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Produk Baru'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Picker
              Center(
                child: ImagePickerWidget(
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
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
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
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Save Button
              CustomButton(
                text: 'Simpan Produk',
                onPressed: _saveProduct,
                isLoading: _isLoading,
                icon: Icons.save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}