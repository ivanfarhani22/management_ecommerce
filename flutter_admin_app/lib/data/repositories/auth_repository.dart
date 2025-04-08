import '../api/auth_api.dart';
import '../local/secure_storage.dart';
import '../models/user.dart';

class AuthRepository {
  final AuthApi authApi;
  final SecureStorageHelper secureStorage;

  AuthRepository({
    required this.authApi,
    required this.secureStorage,
  });

Future<User> login(String email, String password) async {
  try {
    final user = await authApi.login(email, password);
    
    // Pastikan token tidak null
    if (user.token == null || user.token!.isEmpty) {
      throw Exception('Token tidak valid');
    }
    
    // Simpan token
    await secureStorage.saveAuthToken(user.token!);
    await secureStorage.saveUserEmail(email);
    return user;
  } catch (e) {
    rethrow;
  }
}

Future<User> register({
  required String name,
  required String email,
  required String password,
}) async {
  try {
    final user = await authApi.register(
      name: name,
      email: email,
      password: password,
    );
    
    // Tambahkan validasi token
    if (user.token == null || user.token!.isEmpty) {
      throw Exception('Token tidak valid');
    }
    
    // Store token securely after successful registration
    await secureStorage.saveAuthToken(user.token!);
    await secureStorage.saveUserEmail(email);
    return user;
  } catch (e) {
    rethrow;
  }
}

  Future<void> logout() async {
    try {
      await authApi.logout();
      // Clear stored token and user info
      await secureStorage.removeAuthToken();
      await secureStorage.delete(key: 'user_email');
    } catch (e) {
      rethrow;
    }
  }

  Future<User> getCurrentUser() async {
    try {
      return await authApi.getCurrentUser();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await authApi.forgotPassword(email);
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> getStoredToken() async {
    return await secureStorage.getAuthToken();
  }

  Future<String?> getStoredEmail() async {
    return await secureStorage.getUserEmail();
  }
}