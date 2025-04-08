import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback? onEdit;

  const ProductCard({
    super.key,
    required this.product,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isLowStock = product['stock'] < 75; // Example low stock threshold

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Product Image or Placeholder
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
                image: product['image'] != null
                    ? DecorationImage(
                        image: FileImage(product['image']),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: product['image'] == null
                  ? const Center(
                      child: Icon(
                        Icons.image,
                        color: Colors.grey,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product['category'],
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.inventory,
                        size: 16,
                        color: isLowStock ? Colors.orange : Colors.green,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Stok: ${product['stock']}',
                        style: TextStyle(
                          color: isLowStock ? Colors.orange : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Price and Edit Button
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Rp ${product['price']}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.grey),
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