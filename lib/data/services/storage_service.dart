import 'package:flutter/foundation.dart';
import 'package:flow/data/repositories/supabase_repository.dart';

import '../models/drink_log.dart';
import '../models/urine_log.dart';

class StorageService {
  final SupabaseRepository _remoteRepo;

  StorageService(this._remoteRepo);

  /// Ensures the user is authenticated (anonymously) before making requests.
  Future<void> initialize() async {
    try {
      await _remoteRepo.initializeUser();
    } catch (e) {
      debugPrint('Failed to initialize Supabase user: $e');
      rethrow;
    }
  }

  /// Retrieves the list of UrineLogs from Supabase.
  Future<List<UrineLog>> loadUrineLogs() async {
    try {
      return await _remoteRepo.getUrineLogs();
    } catch (e) {
      debugPrint('Failed to load urine logs: $e');
      // Return empty list on error so UI doesn't break
      return [];
    }
  }

  /// Adds a single UrineLog to the database.
  Future<void> addUrineLog(UrineLog log) async {
    try {
      await _remoteRepo.addUrineLog(log);
    } catch (e) {
      debugPrint('Failed to add urine log: $e');
      rethrow;
    }
  }

  /// Deletes a specific UrineLog by ID.
  Future<void> deleteUrineLog(int id) async {
    try {
      await _remoteRepo.deleteUrineLog(id);
    } catch (e) {
      debugPrint('Failed to delete urine log: $e');
      rethrow;
    }
  }

  Future<void> updateUrineLog(UrineLog log) async {
    try {
      await _remoteRepo.updateUrineLog(log);
    } catch (e) {
      debugPrint('Failed to update urine log: $e');
      rethrow;
    }
  }

  /// Retrieves the list of DrinkLogs from Supabase.
  Future<List<DrinkLog>> loadDrinkLogs() async {
    try {
      return await _remoteRepo.getDrinkLogs();
    } catch (e) {
      debugPrint('Failed to load drink logs: $e');
      return [];
    }
  }

  /// Adds a single DrinkLog to the database.
  Future<void> addDrinkLog(DrinkLog log) async {
    try {
      await _remoteRepo.addDrinkLog(log);
    } catch (e) {
      debugPrint('Failed to add drink log: $e');
      rethrow;
    }
  }

  /// Deletes a specific DrinkLog by ID.
  Future<void> deleteDrinkLog(int id) async {
    try {
      await _remoteRepo.deleteDrinkLog(id);
    } catch (e) {
      debugPrint('Failed to delete drink log: $e');
      rethrow;
    }
  }

  /// Updates an existing DrinkLog in the database.
  Future<void> updateDrinkLog(DrinkLog log) async {
    try {
      await _remoteRepo.updateDrinkLog(log);
    } catch (e) {
      debugPrint('Failed to update drink log: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> loadSettings() async {
    try {
      return await _remoteRepo.loadSettings();
    } catch (e) {
      debugPrint('Failed to load settings: $e');
      return {'theme': 'light', 'drinking_goal': 2.0};
    }
  }

  Future<void> saveSettings(Map<String, dynamic> settings) async {
    try {
      final theme = settings['theme'] as String?;
      final drinkingGoal = settings['drinking_goal'] as num?;

      if (theme == null || theme.isEmpty) {
        throw ArgumentError('Theme is required and cannot be empty');
      }

      if (drinkingGoal == null || drinkingGoal <= 0) {
        throw ArgumentError('Drinking goal must be a positive number');
      }

      await _remoteRepo.saveSettings(theme, drinkingGoal.toDouble());
    } catch (e) {
      debugPrint('Failed to save settings: $e');
      rethrow;
    }
  }
}
