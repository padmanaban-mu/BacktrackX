import 'package:flutter/material.dart';
import '../models/settings_model.dart';
import '../services/settings_service.dart';
import '../constants/app_colors.dart';

/// Manages user preferences (animation speed, sound, dark mode, hints).
/// Persists settings via SettingsService → SharedPreferences.
class SettingsProvider extends ChangeNotifier {
  final SettingsService _settingsService = SettingsService();

  bool _isLoading = false;
  SettingsModel _settings = const SettingsModel(
    animationSpeed: 1.0,
    soundEnabled: true,
    darkMode: false,
    showHints: true,
  );

  bool get isLoading => _isLoading;
  SettingsModel get settings => _settings;

  double get animationSpeed => _settings.animationSpeed;
  bool get soundEnabled => _settings.soundEnabled;
  bool get darkMode => _settings.darkMode;
  bool get showHints => _settings.showHints;

  /// Loads saved settings from SharedPreferences.
  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      _settings = await _settingsService.loadSettings();
    } catch (_) {
      // Use defaults if loading fails
    }
    
    if (_settings.darkMode) {
      AppColors.setDarkMode();
    } else {
      AppColors.setLightMode();
    }
    
    _isLoading = false;
    notifyListeners();
  }

  /// Updates animation speed and persists.
  Future<void> setAnimationSpeed(double speed) async {
    _settings = _settings.copyWith(animationSpeed: speed);
    notifyListeners();
    await _settingsService.saveSettings(_settings);
  }

  /// Toggles sound and persists.
  Future<void> toggleSound() async {
    _settings = _settings.copyWith(soundEnabled: !_settings.soundEnabled);
    notifyListeners();
    await _settingsService.saveSettings(_settings);
  }

  /// Toggles dark mode and persists.
  Future<void> toggleDarkMode() async {
    _settings = _settings.copyWith(darkMode: !_settings.darkMode);
    if (_settings.darkMode) {
      AppColors.setDarkMode();
    } else {
      AppColors.setLightMode();
    }
    notifyListeners();
    await _settingsService.saveSettings(_settings);
  }

  /// Toggles hints and persists.
  Future<void> toggleHints() async {
    _settings = _settings.copyWith(showHints: !_settings.showHints);
    notifyListeners();
    await _settingsService.saveSettings(_settings);
  }
}
