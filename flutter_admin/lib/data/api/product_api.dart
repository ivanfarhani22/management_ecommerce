import '../models/product.dart';
import 'api_client.dart';

class ProductApi {
  final ApiClient apiClient;

  ProductApi(this.apiClient);

  Future<List<Product>> getAllProducts() async {
    try {
      final response = await apiClient.get('/v1/products');
      return (response as List)
        .map((productJson) => Product.fromJson(productJson))
        .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Product> getProductById(int productId) async {
    try {
      final response = await apiClient.get('/v1/products/$productId');
      return Product.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<Product> createProduct(Product product) async {
    try {
      final response = await apiClient.post('/v1/products', body: product.toJson());
      return Product.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<Product> updateProduct(Product product) async {
    try {
      final response = await apiClient.put('/v1/products/${product.id}', body: product.toJson());
      return Product.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteProduct(int productId) async {
    try {
      await apiClient.delete('/v1/products/$productId');
    } catch (e) {
      rethrow;
    }
  }
}