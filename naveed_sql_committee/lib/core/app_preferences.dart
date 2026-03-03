import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  AppPreferences._();

  static const _committeeStatusFilterKey = 'committee_status_filter';

  static Future<String> getCommitteeStatusFilter() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_committeeStatusFilterKey) ?? 'All';
  }

  static Future<void> setCommitteeStatusFilter(String status) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_committeeStatusFilterKey, status);
  }
}
