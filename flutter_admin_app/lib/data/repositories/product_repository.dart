import '../api/product_api.dart';
import '../local/database_helper.dart';
import '../models/product.dart';

class ProductRepository {
  final ProductApi productApi;
  final DatabaseHelper databaseHelper;

  ProductRepository({
    required this.productApi,
    required this.databaseHelper,
  });

  Future<List<Product>> getAllProducts() async {
    try {
      // First, try to fetch from API
      final apiProducts = await productApi.getAllProducts();
      
      // Cache products in local database
      for (var product in apiProducts) {
        await databaseHelper.insert('products', product.toJson());
      }
      
      return apiProducts;
    } catch (e) {
      // If API fails, try to fetch from local database
      final localProducts = await databaseHelper.query('products');
      return localProducts.map((json) => Product.fromJson(json)).toList();
    }
  }

  Future<Product> getProductById(int productId) async {
    try {
      // Try to fetch from API first
      return await productApi.getProductById(productId);
    } catch (e) {
      // Fallback to local database
      final localProduct = await databaseHelper.query(
        'products', 
        where: 'id = ?', 
        whereArgs: [productId]
      );
      
      if (localProduct.isNotEmpty) {
        return Product.fromJson(localProduct.first);
      }
      
      rethrow;
    }
  }

  Future<Product> createProduct(Product product) async {
    try {
      final createdProduct = await productApi.createProduct(product);
      
      // Cache in local database
      await databaseHelper.insert('products', createdProduct.toJson());
      
      return createdProduct;
    } catch (e) {
      rethrow;
    }
  }

  Future<Product> updateProduct(Product product) async {
    try {
      final updatedProduct = await productApi.updateProduct(product);
      
      // Update in local database
      await databaseHelper.update(
        'products', 
        updatedProduct.toJson(),
        where: 'id = ?',
        whereArgs: [updatedProduct.id]
      );
      
      return updatedProduct;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteProduct(int productId) async {
    try {
      await productApi.deleteProduct(productId);
      
      // Remove from local database
      await databaseHelper.delete(
        'products', 
        where: 'id = ?', 
        whereArgs: [productId]
      );
    } catch (e) {
      rethrow;
    }
  }
}