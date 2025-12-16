import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/log.dart';

/// A repository implementation that uses [SharedPreferences] for local data persistence.
///
/// This class handles the low-level serialization (JSON encoding) and
/// deserialization (JSON decoding) of [Log] objects and application settings.
/// It acts as the "Source of Truth" for data stored on the device.
class SharedPreferencesRepository {
  static const String _storageKey = 'flowtrack_logs';
  static const String _settingsKey = 'flowtrack_settings';
  static const Map<String, dynamic> _defaultSettings = {
    'theme': 'light',
    'goal': 2.0,
  };

  final SharedPreferences _prefs;

  /// Creates a [SharedPreferencesRepository] with a pre-initialized [_prefs] instance.
  SharedPreferencesRepository(this._prefs);

  /// Retrieves the list of saved [Log] entries from local storage.
  ///
  /// Returns a [Future] that completes with a list of logs.
  /// If no data is found, it returns an empty list `[]`.
  Future<List<Log>> loadLogs() async {
    try {
      final String? logsJson = _prefs.getString(_storageKey);

      if (logsJson != null) {
        final List<dynamic> decoded = jsonDecode(logsJson);
        return decoded.map((item) => Log.fromJson(item)).toList();
      }

      return [];
    } catch (e) {
      // Log the error or rethrow with context
      return [];
    }
  }

  /// Persists a list of [Log] entries to local storage.
  ///
  /// The [logs] list is converted to a JSON string before being saved.
  /// This overwrites any previously stored logs.
  Future<void> saveLogs(List<Log> logs) async {
    try {
      final String encoded = jsonEncode(logs.map((e) => e.toJson()).toList());
      await _prefs.setString(_storageKey, encoded);
    } catch (e) {
      // Log error or rethrow with context
      rethrow;
    }
  }

  /// Retrieves application settings (e.g., theme, daily goals).
  ///
  /// Returns a Map of key-value pairs.
  /// If no settings are found on disk, it returns a default map:
  /// `{'theme': 'light', 'goal': 2.0}`.
  Future<Map<String, dynamic>> loadSettings() async {
    final String? settingsJson = _prefs.getString(_settingsKey);

    if (settingsJson != null) {
      return jsonDecode(settingsJson);
    }

    return Map<String, dynamic>.from(_defaultSettings);
  }

  /// Persists the application [settings] map to local storage.
  ///
  /// The map is JSON-encoded before saving.
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    await _prefs.setString(_settingsKey, jsonEncode(settings));
  }
}
