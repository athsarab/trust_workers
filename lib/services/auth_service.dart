import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../utils/api_config.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';

  // Get stored auth token
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Get stored user ID
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  // Store auth token and user ID
  Future<void> _storeAuthData(String token, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userIdKey, userId);
  }

  // Clear auth data
  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  // Sign up with email and password
  Future<Map<String, dynamic>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required UserModel userModel,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.register),
        headers: ApiConfig.headers,
        body: jsonEncode({
          'name': userModel.name,
          'email': email,
          'password': password,
          'phone': userModel.phone,
          'user_type': userModel.userType.toString().split('.').last,
          'job_category': userModel.jobCategory,
          'experience': userModel.experience,
          'province': userModel.province,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['success'] == true) {
          // Store auth data
          await _storeAuthData(data['token'], data['user']['id'].toString());
          return {
            'success': true,
            'user': data['user'],
            'token': data['token']
          };
        } else {
          throw Exception(data['message'] ?? 'Registration failed');
        }
      } else {
        throw Exception(data['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Failed to create account: ${e.toString()}');
    }
  }

  // Sign in with email and password
  Future<Map<String, dynamic>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.login),
        headers: ApiConfig.headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['success'] == true) {
          // Store auth data
          await _storeAuthData(data['token'], data['user']['id'].toString());
          return {
            'success': true,
            'user': data['user'],
            'token': data['token']
          };
        } else {
          throw Exception(data['message'] ?? 'Login failed');
        }
      } else {
        throw Exception(data['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Failed to sign in: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      final token = await getAuthToken();
      if (token != null) {
        // Optional: Call logout endpoint to invalidate token on server
        await http.post(
          Uri.parse(ApiConfig.logout),
          headers: ApiConfig.getAuthHeaders(token),
        );
      }

      await _clearAuthData();
    } catch (e) {
      // Even if server call fails, clear local data
      await _clearAuthData();
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }

  // Get user data
  Future<UserModel?> getUserData() async {
    try {
      final token = await getAuthToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse(ApiConfig.getUserProfile),
        headers: ApiConfig.getAuthHeaders(token),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return UserModel.fromMap(data['user'], data['user']['id'].toString());
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user data: ${e.toString()}');
    }
  }

  // Update user data
  Future<void> updateUserData(UserModel userModel) async {
    try {
      final token = await getAuthToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.put(
        Uri.parse(ApiConfig.updateProfile),
        headers: ApiConfig.getAuthHeaders(token),
        body: jsonEncode(userModel.toMap()),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200 || data['success'] != true) {
        throw Exception(data['message'] ?? 'Update failed');
      }
    } catch (e) {
      throw Exception('Failed to update user data: ${e.toString()}');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/reset_password.php'),
        headers: ApiConfig.headers,
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200 || data['success'] != true) {
        throw Exception(data['message'] ?? 'Failed to send reset email');
      }
    } catch (e) {
      throw Exception('Failed to send reset email: ${e.toString()}');
    }
  }
}
