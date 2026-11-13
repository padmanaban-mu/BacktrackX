import '../models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Fully offline auth service.
class AuthService {
  static const String _offlineUserKey = 'offline_user_data';

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    return _createOfflineSession(name, email);
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    // In offline mode, just log them in as long as they provide an email.
    return _createOfflineSession(email.split('@').first, email);
  }

  Future<UserModel> getCurrentUser(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_offlineUserKey);
    if (str != null) {
      try {
        final data = jsonDecode(str);
        return UserModel.fromJson(data);
      } catch (_) {}
    }
    // Fallback if missing
    return UserModel(id: 'offline_user', name: 'Student', email: 'student@offline.com', role: 'student');
  }

  Future<Map<String, dynamic>> _createOfflineSession(String name, String email) async {
    final user = {
      '_id': 'offline_user_${DateTime.now().millisecondsSinceEpoch}',
      'name': name,
      'email': email,
    };
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_offlineUserKey, jsonEncode(user));
    
    return {
      'user': UserModel.fromJson(user),
      'token': 'offline_dummy_token_12345',
    };
  }
}
