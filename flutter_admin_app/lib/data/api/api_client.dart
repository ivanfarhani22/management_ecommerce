import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../config/app_config.dart';  // Import AppConfig

class ApiClient {
  final http.Client httpClient;
  final FlutterSecureStorage secureStorage;
  
  // Remove baseUrl parameter as we'll use AppConfig
  ApiClient({
    http.Client? client,
    FlutterSecureStorage? storage,
  }) : 
    httpClient = client ?? http.Client(),
    secureStorage = storage ?? const FlutterSecureStorage();

  // Get the base URL from AppConfig
  String get baseUrl => AppConfig.baseApiUrl;

  Future<String?> get _token async {
    // First try to get token from secure storage
    String? storedToken = await secureStorage.read(key: 'auth_token');
    
    // If not available in secure storage, try from AppConfig
    if (storedToken == null || storedToken.isEmpty) {
      final configToken = AppConfig().getApiToken();
      if (configToken.isNotEmpty) {
        return configToken;
      }
    }
    
    return storedToken;
  }

  Future<Map<String, String>> get _headers async {
    final token = await _token;
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': token != null && token.isNotEmpty ? 'Bearer $token' : '',
    };
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final response = await httpClient.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _headers,
      ).timeout(AppConfig.apiTimeout);  // Use timeout from AppConfig
      
      return _handleResponse(response);
    } catch (e) {
      if (AppConfig().isDebugMode) {
        print('GET request failed: $e');
      }
      throw Exception('Failed to load data: $e');
    }
  }

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final response = await httpClient.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _headers,
        body: json.encode(body),
      ).timeout(AppConfig.apiTimeout);  // Use timeout from AppConfig
      
      return _handleResponse(response);
    } catch (e) {
      if (AppConfig().isDebugMode) {
        print('POST request failed: $e');
      }
      throw Exception('Failed to post data: $e');
    }
  }

  Future<dynamic> put(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final response = await httpClient.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _headers,
        body: json.encode(body),
      ).timeout(AppConfig.apiTimeout);  // Use timeout from AppConfig
      
      return _handleResponse(response);
    } catch (e) {
      if (AppConfig().isDebugMode) {
        print('PUT request failed: $e');
      }
      throw Exception('Failed to update data: $e');
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await httpClient.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _headers,
      ).timeout(AppConfig.apiTimeout);  // Use timeout from AppConfig
      
      return _handleResponse(response);
    } catch (e) {
      if (AppConfig().isDebugMode) {
        print('DELETE request failed: $e');
      }
      throw Exception('Failed to delete data: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    // Log response in debug mode
    if (AppConfig().isDebugMode) {
      print('API Response [${response.statusCode}]: ${response.body}');
    }
    
    switch (response.statusCode) {
      case 200:
      case 201:
        return json.decode(response.body);
      case 400:
        throw Exception('Bad Request: ${response.body}');
      case 401:
        throw Exception('Unauthorized: Please log in again');
      case 403:
        throw Exception('Forbidden: You do not have permission');
      case 404:
        throw Exception('Not Found');
      case 500:
        throw Exception('Server Error');
      default:
        throw Exception('Unexpected error occurred');
    }
  }

  // Additional utility methods for token management
  Future<void> saveToken(String token) async {
    await secureStorage.write(key: 'auth_token', value: token);
    // Also save to AppConfig for in-memory access
    AppConfig().setApiToken(token);
  }

  Future<void> deleteToken() async {
    await secureStorage.delete(key: 'auth_token');
    // Also clear from AppConfig
    AppConfig().setApiToken('');
  }
  
  // Helper method to get image URL with fallback logic from AppConfig
  String getImageUrl(String? path) {
    return AppConfig.getImageUrl(path);
  }
}