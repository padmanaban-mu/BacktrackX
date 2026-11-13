import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings_model.dart';

class SettingsService {
  static const String _animationSpeedKey = 'animationSpeed';
  static const String _soundEnabledKey = 'soundEnabled';
  static const String _darkModeKey = 'darkMode';
  static const String _showHintsKey = 'showHints';

  Future<SettingsModel> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    final animationSpeed = prefs.getDouble(_animationSpeedKey) ?? 1.0;
    final soundEnabled = prefs.getBool(_soundEnabledKey) ?? true;
    final darkMode = prefs.getBool(_darkModeKey) ?? false;
    final showHints = prefs.getBool(_showHintsKey) ?? true;

    return SettingsModel(
      animationSpeed: animationSpeed,
      soundEnabled: soundEnabled,
      darkMode: darkMode,
      showHints: showHints,
    );
  }

  Future<void> saveSettings(SettingsModel settings) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setDouble(_animationSpeedKey, settings.animationSpeed);
    await prefs.setBool(_soundEnabledKey, settings.soundEnabled);
    await prefs.setBool(_darkModeKey, settings.darkMode);
    await prefs.setBool(_showHintsKey, settings.showHints);
  }
}
