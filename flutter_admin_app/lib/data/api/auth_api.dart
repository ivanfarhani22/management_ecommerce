import '../models/user.dart';
import 'api_client.dart';

class AuthApi {
  final ApiClient apiClient;

  AuthApi(this.apiClient);

Future<User> login(String email, String password) async {
  try {
    final response = await apiClient.post('/v1/login', body: {
      'email': email,
      'password': password,
    });

    // Pastikan response memiliki token dan user
    if (response['token'] == null || response['user'] == null) {
      throw Exception('Invalid login response');
    }

    User user = User.fromJson(response['user']);
    
    // Tambahkan token ke user
    user = User(
      id: user.id,
      name: user.name,
      email: user.email,
      token: response['token'], // Tambahkan token
      profilePicture: user.profilePicture,
      role: user.role,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );

    return user;
  } catch (e) {
    print('Login error: $e');
    rethrow;
  }
}
  Future<User> register({
    required String name, 
    required String email, 
    required String password
  }) async {
    try {
      final response = await apiClient.post('/v1/register', body: {
        'name': name,
        'email': email,
        'password': password,
      });

      await apiClient.secureStorage.write(
        key: 'auth_token', 
        value: response['token']
      );

      return User.fromJson(response['user']);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await apiClient.post('/v1/logout');
      await apiClient.secureStorage.delete(key: 'auth_token');
    } catch (e) {
      rethrow;
    }
  }

  Future<User> getCurrentUser() async {
    try {
      final response = await apiClient.get('/v1/me');
      return User.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await apiClient.post('/v1/forgot-password', body: {
        'email': email,
      });
    } catch (e) {
      rethrow;
    }
  }
}