import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageHelper {
  // Singleton instance
  static final SecureStorageHelper instance = SecureStorageHelper._internal();
  final FlutterSecureStorage _secureStorage;

  // Private konstruktor
  SecureStorageHelper._internal() 
    : _secureStorage = const FlutterSecureStorage(
        aOptions: AndroidOptions(
          encryptedSharedPreferences: true,
        ),
      );

  // Write a secure value with optional error handling
  Future<bool> write({required String key, required String value}) async {
    try {
      await _secureStorage.write(key: key, value: value);
      return true;
    } catch (e) {
      print('Error writing to secure storage: $e');
      return false;
    }
  }

  // Read a secure value with optional default
  Future<String?> read({required String key, String? defaultValue}) async {
    try {
      return await _secureStorage.read(key: key) ?? defaultValue;
    } catch (e) {
      print('Error reading from secure storage: $e');
      return defaultValue;
    }
  }

  // Delete a secure value
  Future<bool> delete({required String key}) async {
    try {
      await _secureStorage.delete(key: key);
      return true;
    } catch (e) {
      print('Error deleting from secure storage: $e');
      return false;
    }
  }

  // Check if a key exists
  Future<bool> containsKey({required String key}) async {
    try {
      return await _secureStorage.containsKey(key: key);
    } catch (e) {
      print('Error checking key in secure storage: $e');
      return false;
    }
  }

  // Delete all secure storage
  Future<bool> deleteAll() async {
    try {
      await _secureStorage.deleteAll();
      return true;
    } catch (e) {
      print('Error deleting all from secure storage: $e');
      return false;
    }
  }

  // Metode spesifik untuk token
  Future<bool> saveAuthToken(String token) async {
    return await write(key: 'auth_token', value: token);
  }

  Future<String?> getAuthToken() async {
    return await read(key: 'auth_token');
  }

  Future<bool> removeAuthToken() async {
    return await delete(key: 'auth_token');
  }

  // Metode spesifik untuk email
  Future<bool> saveUserEmail(String email) async {
    return await write(key: 'user_email', value: email);
  }

  Future<String?> getUserEmail() async {
    return await read(key: 'user_email');
  }
}