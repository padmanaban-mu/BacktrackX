/// A single error type used across the app for any failed API call,
/// so screens only ever need to catch one exception type and show
/// `e.message` directly to the user.
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}
