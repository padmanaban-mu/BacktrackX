import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../utils/api_exception.dart';

enum AuthStatus { idle, loading, authenticated, error }

/// Holds all authentication state (user, token, loading, error) and exposes
/// it to the UI via ChangeNotifier. Screens NEVER call AuthService directly
/// — they always go through this provider, which also persists the JWT.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  static const String _tokenKey = 'jwt_token';

  AuthStatus _status = AuthStatus.idle;
  UserModel? _user;
  String? _token;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get token => _token;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isAuthenticated => _token != null;

  /// Called once from the Splash Screen to silently check whether a JWT
  /// from a previous session is still saved and valid.
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString(_tokenKey);
    if (savedToken == null) return false;

    try {
      final currentUser = await _authService.getCurrentUser(savedToken);
      _token = savedToken;
      _user = currentUser;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (_) {
      // Token expired or invalid -- clear it and fall back to the login screen.
      await prefs.remove(_tokenKey);
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _setLoading();
    try {
      final result = await _authService.login(email: email, password: password);
      await _saveSession(result['user'] as UserModel, result['token'] as String);
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } catch (_) {
      _setError('Unable to connect to the server. Please check your connection.');
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading();
    try {
      final result = await _authService.register(name: name, email: email, password: password);
      await _saveSession(result['user'] as UserModel, result['token'] as String);
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } catch (_) {
      _setError('Unable to connect to the server. Please check your connection.');
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    _user = null;
    _token = null;
    _status = AuthStatus.idle;
    notifyListeners();
  }

  Future<void> _saveSession(UserModel user, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    _user = user;
    _token = token;
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }
}
