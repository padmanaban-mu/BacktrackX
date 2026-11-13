import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_exception.dart';

/// The ONE place that knows how to talk HTTP to the backend.
/// Every feature service (auth, and later sudoku/progress/etc.) uses this
/// instead of calling package:http directly, so headers, JSON decoding,
/// and error handling are never duplicated.
class ApiService {
  // Prevents a hung/unreachable connection from stalling the app forever
  // (e.g. the splash screen never navigating). See Bug 3 in the debug report.
  static const Duration _timeoutDuration = Duration(seconds: 10);

  Future<Map<String, dynamic>> post(
    String url,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: _buildHeaders(token),
            body: jsonEncode(body),
          )
          .timeout(_timeoutDuration);
      return _processResponse(response);
    } on TimeoutException {
      throw ApiException('Server is taking too long to respond. Please check your connection and try again.');
    }
  }

  Future<Map<String, dynamic>> get(String url, {String? token}) async {
    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: _buildHeaders(token),
          )
          .timeout(_timeoutDuration);
      return _processResponse(response);
    } on TimeoutException {
      throw ApiException('Server is taking too long to respond. Please check your connection and try again.');
    }
  }

  Map<String, String> _buildHeaders(String? token) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Decodes the backend's standard envelope:
  ///   success -> { success: true, data: {...}, message: "..." }
  ///   failure -> { success: false, error: { code, message } }
  Map<String, dynamic> _processResponse(http.Response response) {
    late final Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException('Unable to reach the server. Please try again.');
    }

    final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
    if (!isSuccess) {
      final message = decoded['error']?['message'] ?? 'Something went wrong';
      throw ApiException(message);
    }
    return decoded;
  }
}
