import '../models/log.dart';
import '../repositories/shared_preferences_repository.dart';

/// A service that acts as the bridge between the application's domain logic
/// and the data layer ([SharedPreferencesRepository]).
///
/// This class handles business rules for data storage, such as error handling
/// and validation (e.g., preventing empty saves), ensuring the UI interacts
/// with a clean API regardless of the underlying storage method.
class StorageService {
  final SharedPreferencesRepository _repository;

  /// Creates a [StorageService] requiring a [_repository] instance.
  StorageService(this._repository);

  /// Retrieves the list of [Log] entries safely.
  ///
  /// This method wraps the repository call in a try-catch block.
  /// If an error occurs during data retrieval (e.g., corruption),
  /// it gracefully returns an empty list `[]` instead of crashing the app.
  Future<List<Log>> loadLogs() async {
    try {
      return _repository.loadLogs();
    } catch (e) {
      return [];
    }
  }

  /// Saves a list of [Log] entries if valid.
  ///
  /// Includes business logic to check if the [logs] list is empty.
  /// If [logs] is empty, the save operation is aborted to prevent
  /// unnecessary writes to disk.
  Future<void> saveLogs(List<Log> logs) async {
    if (logs.isEmpty) return;

    await _repository.saveLogs(logs);
  }

  /// Retrieves the current application settings.
  ///
  /// Delegates directly to the repository to fetch the settings map.
  Future<Map<String, dynamic>> loadSettings() async {
    return _repository.loadSettings();
  }

  /// Saves the updated application [settings].
  ///
  /// Persists the provided map to storage via the repository.
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    await _repository.saveSettings(settings);
  }
}
