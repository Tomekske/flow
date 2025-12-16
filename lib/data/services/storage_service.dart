import 'package:flow/data/repositories/supabase_repository.dart';
import 'package:flutter/foundation.dart';

import '../models/log.dart';
import '../repositories/shared_preferences_repository.dart';

/// A service that acts as the bridge between the application's domain logic
/// and the data layer ([SharedPreferencesRepository]).
///
/// This class handles business rules for data storage, such as error handling
/// and validation (e.g., preventing empty saves), ensuring the UI interacts
/// with a clean API regardless of the underlying storage method.
class StorageService {
  final SharedPreferencesRepository _localRepo;
  final SupabaseRepository _remoteRepo;

  /// Creates a [StorageService] requiring a [_repository] instance.
  StorageService(this._localRepo, this._remoteRepo);

  /// Retrieves the list of [Log] entries safely.
  ///
  /// This method wraps the repository call in a try-catch block.
  /// If an error occurs during data retrieval (e.g., corruption),
  /// it gracefully returns an empty list `[]` instead of crashing the app.
  Future<List<Log>> loadLogs() async {
    try {
      return _localRepo.loadLogs();
    } catch (e) {
      debugPrint('Failed to load logs: $e');
      return [];
    }
  }

  /// Delegates directly to the repository to persist the [logs] list.
  /// Accepts empty lists, allowing intentional clearing of all logs.
  Future<void> saveLogs(List<Log> logs) async {
    await _localRepo.saveLogs(logs);
  }

  /// Retrieves the current application settings.
  ///
  /// Delegates directly to the repository to fetch the settings map.
  Future<Map<String, dynamic>> loadSettings() async {
    try {
      return _remoteRepo.loadSettings();
    } catch (e) {
      debugPrint('Failed to load settings: $e');
      // Return defaults on error
      return {'theme': 'light', 'drinking_goal': 2.0};
    }
  }

  /// Saves the updated application [settings].
  ///
  /// Persists the provided map to storage via the repository.
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    try {
      final theme = settings['theme'] as String;
      final drinkingGoal = (settings['drinking_goal'] as num).toDouble();
      await _remoteRepo.saveSettings(theme, drinkingGoal);
    } catch (e) {
      debugPrint('Failed to save settings: $e');
      rethrow;
    }
  }
}
