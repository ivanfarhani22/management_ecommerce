import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../../config/app_config.dart';
import '../models/order.dart';

class OrderService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _secureStorage.read(key: 'auth_token');
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}',
    };
  }
  
  Future<List<Order>> getAllOrders() async {
    final headers = await _getAuthHeaders();
    
    try {
      debugPrint('Fetching all orders');
      
      final response = await http.get(
        Uri.parse('${AppConfig.baseApiUrl}/v1/orders'),
        headers: headers,
      ).timeout(AppConfig.apiTimeout);
      
      if (response.statusCode == 200) {
        final List<dynamic> decodedData = json.decode(response.body);
        return decodedData.map((json) => Order.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch orders (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('Exception in getAllOrders: $e');
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> getOrderDetails(String orderId) async {
    final headers = await _getAuthHeaders();
    
    try {
      debugPrint('Fetching order details for: $orderId');
      
      final response = await http.get(
        Uri.parse('${AppConfig.baseApiUrl}/v1/orders/$orderId'),
        headers: headers,
      ).timeout(AppConfig.apiTimeout);
      
      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body (first 100 chars): ${response.body.length > 100 ? response.body.substring(0, 100) + '...' : response.body}');
      
      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        return decodedData;
      } else if (response.statusCode == 403) {
        // Handle authorization failure specifically
        throw Exception('You are not authorized to view this order');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        try {
          final errorData = json.decode(response.body);
          final errorMessage = errorData['message'] ?? errorData['error'] ?? 'Failed to fetch order details';
          throw Exception(errorMessage);
        } catch (e) {
          throw Exception('Failed to fetch order details (${response.statusCode})');
        }
      }
    } catch (e) {
      debugPrint('Exception in getOrderDetails: $e');
      rethrow; // Re-throw to be handled by the calling method
    }
  }
  
  Future<Order> createOrder(Order order) async {
    final headers = await _getAuthHeaders();
    
    try {
      debugPrint('Creating new order');
      
      final response = await http.post(
        Uri.parse('${AppConfig.baseApiUrl}/v1/orders'),
        headers: headers,
        body: json.encode(order.toJson()),
      ).timeout(AppConfig.apiTimeout);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Order.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create order (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('Exception in createOrder: $e');
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> updateOrderStatus(String orderId, String status) async {
    final headers = await _getAuthHeaders();
    
    try {
      debugPrint('Updating order status: $orderId to $status');
      
      final response = await http.put(
        Uri.parse('${AppConfig.baseApiUrl}/v1/orders/$orderId/status'),
        headers: headers,
        body: json.encode({'status': status}),
      ).timeout(AppConfig.apiTimeout);
      
      debugPrint('Response status code: ${response.statusCode}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else if (response.statusCode == 403) {
        throw Exception('You are not authorized to update this order');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        try {
          final errorData = json.decode(response.body);
          final errorMessage = errorData['message'] ?? errorData['error'] ?? 'Failed to update order status';
          throw Exception(errorMessage);
        } catch (e) {
          throw Exception('Failed to update order status (${response.statusCode})');
        }
      }
    } catch (e) {
      debugPrint('Exception in updateOrderStatus: $e');
      rethrow;
    }
  }
}