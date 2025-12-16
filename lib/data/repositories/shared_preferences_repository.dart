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
}
