import '../models/user.dart';
import 'api_client.dart';
import '../../config/app_config.dart';  // Import AppConfig

class AuthApi {
  final ApiClient apiClient;

  AuthApi(this.apiClient);

  Future<User> login(String email, String password) async {
    try {
      final response = await apiClient.post('/v1/login', body: {
        'email': email,
        'password': password,
        'app_version': AppConfig.appVersion,  // Include app version
      });

      // Validate the login response
      if (response['token'] == null || response['user'] == null) {
        throw Exception('Invalid login response');
      }

      // Save token to secure storage and AppConfig
      await apiClient.saveToken(response['token']);

      // Create user from response
      User user = User.fromJson(response['user']);
      
      // Add token to user
      user = User(
        id: user.id,
        name: user.name,
        email: user.email,
        token: response['token'],
        profilePicture: user.profilePicture != null ? 
            apiClient.getImageUrl(user.profilePicture) : null,  // Use helper for image URL
        role: user.role,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
      );

      return user;
    } catch (e) {
      if (AppConfig().isDebugMode) {
        print('Login error: $e');
      }
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
        'app_version': AppConfig.appVersion,  // Include app version
      });

      if (response['token'] == null || response['user'] == null) {
        throw Exception('Invalid registration response');
      }

      // Save token
      await apiClient.saveToken(response['token']);

      // Create user from response and format profile picture URL if exists
      User user = User.fromJson(response['user']);
      
      return User(
        id: user.id,
        name: user.name, 
        email: user.email,
        token: response['token'],
        profilePicture: user.profilePicture != null ? 
            apiClient.getImageUrl(user.profilePicture) : null,
        role: user.role,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
      );
    } catch (e) {
      if (AppConfig().isDebugMode) {
        print('Registration error: $e');
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      // Only attempt to call logout API if we have a token
      final token = await apiClient.secureStorage.read(key: 'auth_token');
      if (token != null && token.isNotEmpty) {
        await apiClient.post('/v1/logout');
      }
      
      // Always delete the token regardless of API call result
      await apiClient.deleteToken();
    } catch (e) {
      if (AppConfig().isDebugMode) {
        print('Logout error: $e');
      }
      // Still delete token even if API call fails
      await apiClient.deleteToken();
      rethrow;
    }
  }

  Future<User> getCurrentUser() async {
    try {
      final response = await apiClient.get('/v1/me');
      User user = User.fromJson(response);
      
      // Format profile picture URL if exists
      return User(
        id: user.id,
        name: user.name,
        email: user.email,
        token: user.token,
        profilePicture: user.profilePicture != null ? 
            apiClient.getImageUrl(user.profilePicture) : null,
        role: user.role,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
      );
    } catch (e) {
      if (AppConfig().isDebugMode) {
        print('Get current user error: $e');
      }
      rethrow;
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await apiClient.post('/v1/forgot-password', body: {
        'email': email,
        'app_version': AppConfig.appVersion,  // Include app version
      });
    } catch (e) {
      if (AppConfig().isDebugMode) {
        print('Forgot password error: $e');
      }
      rethrow;
    }
  }
  
  // New method to refresh token if needed
  Future<bool> refreshTokenIfNeeded() async {
    try {
      final response = await apiClient.post('/v1/refresh-token');
      if (response['token'] != null) {
        await apiClient.saveToken(response['token']);
        return true;
      }
      return false;
    } catch (e) {
      if (AppConfig().isDebugMode) {
        print('Token refresh error: $e');
      }
      return false;
    }
  }
}