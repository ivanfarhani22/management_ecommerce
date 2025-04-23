import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../config/app_config.dart'; // Import AppConfig

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final Map<int, String> categoryNames;
  final VoidCallback? onEdit;

  const ProductCard({
    super.key,
    required this.product,
    required this.categoryNames,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    // Mendapatkan nama produk, kategori, dan stok dengan null safety
    final String productName = product['name']?.toString() ?? 'Unknown Product';
    final int categoryId = int.tryParse(product['category_id']?.toString() ?? '0') ?? 0;
    final String productCategory = categoryNames[categoryId] ?? 'Uncategorized';
    final String productPrice = product['price']?.toString() ?? '0';
    final int productStock = int.tryParse(product['stock']?.toString() ?? '0') ?? 0;
    final String? productImageUrl = product['image']?.toString();
    
    // Menangani gambar, baik dari String URL, File, atau API path
    Widget buildImage() {
      // Periksa apakah gambar adalah URL, File, path API, atau null
      if (productImageUrl != null && productImageUrl.isNotEmpty) {
        // Coba load dari network jika terlihat seperti URL
        if (productImageUrl.startsWith('http')) {
          return Image.network(
            productImageUrl,
            fit: BoxFit.cover,
            width: 80,
            height: 80,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.image_not_supported, size: 80);
            },
          );
        }
        // Jika gambar adalah path relatif API (misalnya "uploads/products/image.jpg")
        else if (!productImageUrl.startsWith('/') && !productImageUrl.contains('://')) {
          // Gabungkan dengan baseApiUrl
          final fullImageUrl = '${AppConfig.storageBaseUrl}/$productImageUrl';
          // debugPrint('Image URL: http://127.0.0.1:8000/storage/$productImageUrl');
          return Image.network(
            fullImageUrl,
            fit: BoxFit.cover,
            width: 80,
            height: 80,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Error loading image from API: $error');
              return const Icon(Icons.image_not_supported, size: 80);
            },
          );
        }
        // Jika bukan URL namun adalah path file
        else if (product['image'] is File) {
          // Jika image adalah tipe File langsung (dari picker misalnya)
          return Image.file(
            product['image'] as File,
            fit: BoxFit.cover,
            width: 80,
            height: 80,
          );
        } else {
          // Fallback ke icon jika bukan URL atau File
          return const Icon(Icons.inventory_2_outlined, size: 80);
        }
      }
      
      // Fallback jika tidak ada gambar
      return const Icon(Icons.inventory_2_outlined, size: 80);
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: buildImage(),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    productCategory,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp$productPrice',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        productStock > 75 ? Icons.check_circle : Icons.warning,
                        color: productStock > 75 ? Colors.green : Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Stock: $productStock',
                        style: TextStyle(
                          color: productStock > 75 ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: onEdit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}