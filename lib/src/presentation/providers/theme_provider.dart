import 'package:codemy_app/src/core/utils/logger.dart';
import 'package:codemy_app/src/core/utils/persistence.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Custom theme mode enum for shadcn_flutter
enum ShadcnThemeMode {
  light,
  dark,
  system;

  String get displayName {
    switch (this) {
      case ShadcnThemeMode.light:
        return 'Light';
      case ShadcnThemeMode.dark:
        return 'Dark';
      case ShadcnThemeMode.system:
        return 'System';
    }
  }

  Brightness? get brightness {
    switch (this) {
      case ShadcnThemeMode.light:
        return Brightness.light;
      case ShadcnThemeMode.dark:
        return Brightness.dark;
      case ShadcnThemeMode.system:
        return null; // Let system decide
    }
  }
}

// Theme mode provider
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ShadcnThemeMode>(
  () {
    return ThemeModeNotifier();
  },
);

// Theme mode notifier
class ThemeModeNotifier extends Notifier<ShadcnThemeMode> {
  static const String _themeKey = 'theme_mode';

  @override
  ShadcnThemeMode build() {
    // Initialize with system theme as default
    return ShadcnThemeMode.system;
  }

  Future<void> initializeTheme() async {
    try {
      final savedTheme = await PersistenceUtils.readString(_themeKey);
      if (savedTheme != null) {
        state = _parseThemeMode(savedTheme);
      }
    } catch (e) {
      // If there's an error, keep the default system theme
      Logger.error('Error initializing theme: $e');
    }
  }

  Future<void> setThemeMode(ShadcnThemeMode themeMode) async {
    state = themeMode;
    try {
      await PersistenceUtils.writeString(_themeKey, themeMode.name);
    } catch (e) {
      Logger.error('Error saving theme preference: $e');
    }
  }

  ShadcnThemeMode _parseThemeMode(String themeString) {
    switch (themeString) {
      case 'light':
        return ShadcnThemeMode.light;
      case 'dark':
        return ShadcnThemeMode.dark;
      case 'system':
      default:
        return ShadcnThemeMode.system;
    }
  }
}
