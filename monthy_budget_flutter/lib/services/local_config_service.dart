import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/local_dashboard_config.dart';
import '../models/notification_preferences.dart';
import '../models/onboarding_state.dart';
import '../theme/app_colors.dart';

class LocalConfigService {
  static const _key = 'dashboard_config';
  static const _themeKey = 'theme_mode';
  static const _notifKey = 'notification_prefs';
  static const _paletteKey = 'color_palette';
  static const _onboardingKey = 'onboarding_state';
  static const _lastUserKey = 'last_user_id';

  Future<LocalDashboardConfig> load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json == null) return const LocalDashboardConfig();
    return LocalDashboardConfig.fromJsonString(json);
  }

  Future<void> save(LocalDashboardConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, config.toJsonString());
  }

  Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_themeKey);
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await prefs.setString(_themeKey, value);
  }

  Future<AppColorPalette> loadColorPalette() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_paletteKey);
    final result = AppColorPalette.values.firstWhere(
      (p) => p.name == value,
      orElse: () => AppColorPalette.calm,
    );
    // Heal legacy stored values (ocean/emerald/violet/teal/sunset) by
    // re-persisting as 'calm' so future reads match the collapsed enum.
    if (result.name != value) {
      await prefs.setString(_paletteKey, result.name);
    }
    return result;
  }

  Future<void> saveColorPalette(AppColorPalette palette) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_paletteKey, palette.name);
  }

  Future<OnboardingState> loadOnboardingState() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_onboardingKey);
    return s != null ? OnboardingState.fromJsonString(s) : const OnboardingState();
  }

  Future<void> saveOnboardingState(OnboardingState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_onboardingKey, state.toJsonString());
  }

  Future<void> clearOnboardingState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingKey);
  }

  /// Returns true if the user changed (and local data was cleared).
  Future<bool> checkUserChanged(String currentUserId) async {
    final prefs = await SharedPreferences.getInstance();
    final lastUserId = prefs.getString(_lastUserKey);
    if (lastUserId == currentUserId) return false;
    // New user on this device — clear per-user local data
    await prefs.remove(_onboardingKey);
    await prefs.setString(_lastUserKey, currentUserId);
    return true;
  }

  Future<NotificationPreferences> loadNotificationPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_notifKey);
    if (json == null) return NotificationPreferences();
    return NotificationPreferences.fromJsonString(json);
  }

  Future<void> saveNotificationPreferences(
      NotificationPreferences config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_notifKey, config.toJsonString());
  }
}
