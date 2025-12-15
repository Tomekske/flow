import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/log.dart';

class StorageService {
  static const String _storageKey = 'flowtrack_logs';
  static const String _settingsKey = 'flowtrack_settings';

  Future<List<Log>> loadLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? logsJson = prefs.getString(_storageKey);
    if (logsJson != null) {
      final List<dynamic> decoded = jsonDecode(logsJson);
      return decoded.map((item) => Log.fromJson(item)).toList();
    }
    return [];
  }

  Future<void> saveLogs(List<Log> logs) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(logs.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  // --- Settings ---
  Future<Map<String, dynamic>> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final String? settingsJson = prefs.getString(_settingsKey);
    if (settingsJson != null) {
      return jsonDecode(settingsJson);
    }
    return {'theme': 'light', 'goal': 2.0}; // Defaults
  }

  Future<void> saveSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(settings));
  }
}
