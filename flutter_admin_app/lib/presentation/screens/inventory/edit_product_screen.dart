import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/image_picker_widget.dart';
import '../../widgets/error_dialog.dart';
import '../../widgets/confirmation_dialog.dart';
import 'dart:io';

class EditProductScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const EditProductScreen({super.key, required this.product});

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form Controllers
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _stockController;
  late TextEditingController _priceController;
  
  // Dropdown values
  late String _selectedCategory;
  File? _selectedImage;
  bool _isLoading = false;

  // Category list
  final List<String> _categories = [
    'Bahan Makanan',
    'Elektronik',
    'Pakaian',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing product data
    _nameController = TextEditingController(text: widget.product['name']);
    _descriptionController = TextEditingController(text: widget.product['description'] ?? '');
    _stockController = TextEditingController(text: widget.product['stock'].toString());
    _priceController = TextEditingController(text: widget.product['price'].toString());
    _selectedCategory = widget.product['category'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _stockController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _updateProduct() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        // TODO: Implement actual product update logic
        final productData = {
          ...widget.product,
          'name': _nameController.text,
          'description': _descriptionController.text,
          'category': _selectedCategory,
          'stock': int.parse(_stockController.text),
          'price': double.parse(_priceController.text),
          'image': _selectedImage ?? widget.product['image'],
        };

        await Future.delayed(const Duration(seconds: 2));
        
        // Show success dialog
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Produk Berhasil Diperbarui'),
            content: Text('${_nameController.text} telah diperbarui.'),
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
          title: 'Gagal Memperbarui Produk', 
          message: e.toString()
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _deleteProduct() async {
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
        // TODO: Implement actual product delete logic
        await Future.delayed(const Duration(seconds: 2));
        
        // Show success dialog
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
      } catch (e) {
        // Show error dialog
        ErrorDialog.show(
          context, 
          title: 'Gagal Menghapus Produk', 
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
        title: const Text('Edit Produk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteProduct,
          ),
        ],
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
                  initialImagePath: widget.product['image'],
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

              // Update Button
              CustomButton(
                text: 'Perbarui Produk',
                onPressed: _updateProduct,
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