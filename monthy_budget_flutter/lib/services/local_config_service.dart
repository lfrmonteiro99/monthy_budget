import 'package:shared_preferences/shared_preferences.dart';
import '../models/local_dashboard_config.dart';

class LocalConfigService {
  static const _key = 'dashboard_config';

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
}
