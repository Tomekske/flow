import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/log.dart';

class StorageService {
  static const String _storageKey = 'flowtrack_logs';

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
}
