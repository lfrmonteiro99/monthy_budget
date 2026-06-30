import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_settings.dart';

/// App settings (#632 increment 8). Storage-only; persistence (SettingsService)
/// and all derived logic stay in AppHome, which calls [set] with the result.
class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => const AppSettings();
  void set(AppSettings value) => state = value;
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
