import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';

/// First screen shown when the app launches. Silently checks whether a
/// valid JWT is already saved (auto-login) via AuthProvider, then routes
/// to the Dashboard (if logged in) or the Login screen (if not).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Small delay so the branding is actually visible, then check the session.
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    final isLoggedIn = await authProvider.tryAutoLogin();
    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed(
      isLoggedIn ? AppRoutes.dashboard : AppRoutes.login,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset('assets/icon.jpg', width: 100, height: 100),
            ),
            const SizedBox(height: 16),
            const Text(
              AppStrings.appName,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
