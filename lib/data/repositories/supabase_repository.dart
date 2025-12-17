import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/drink_log.dart';
import '../models/urine_log.dart';

class SupabaseRepository {
  final SupabaseClient _client = Supabase.instance.client;
  static const String _urineLogsTable = 'urine_logs';
  static const String _drinkLogsTable = 'drink_logs';

  Future<void> initializeUser() async {
    if (_client.auth.currentUser == null) {
      await _client.auth.signInAnonymously();
    }
  }

  /// Fetches the list of UrineLogs, ordered by newest first.
  Future<List<UrineLog>> getUrineLogs() async {
    try {
      final List<dynamic> data = await _client
          .from(_urineLogsTable)
          .select()
          .order('created_at', ascending: false);

      return data.map((json) => UrineLog.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading urine logs: $e');
      rethrow;
    }
  }

  /// Saves a new UrineLog to Supabase.
  ///
  /// Note: This ignores the `id` inside the [log] object, as Supabase
  /// should generate a unique ID (auto-increment) upon insertion.
  Future<void> addUrineLog(UrineLog log) async {
    try {
      // We convert the model to JSON
      final data = log.toJson();

      // Remove 'id' so Supabase can auto-generate it.
      // If we send an arbitrary ID (like 0), it might conflict with existing records.
      data.remove('id');

      await _client.from(_urineLogsTable).insert(data);
    } catch (e) {
      debugPrint('Error saving urine log: $e');
      rethrow;
    }
  }

  Future<void> updateUrineLog(UrineLog log) async {
    try {
      await _client.from(_urineLogsTable).update(log.toJson()).eq('id', log.id);
    } catch (e) {
      debugPrint('Error updating urine log: $e');
      rethrow;
    }
  }

  Future<void> deleteUrineLog(int id) async {
    try {
      await _client.from(_urineLogsTable).delete().eq('id', id);
    } catch (e) {
      debugPrint('Error deleting urine log: $e');
      rethrow;
    }
  }

  Future<List<DrinkLog>> getDrinkLogs() async {
    try {
      final List<dynamic> data = await _client
          .from(_drinkLogsTable)
          .select()
          .order('created_at', ascending: false);

      return data.map((json) => DrinkLog.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading drink logs: $e');
      rethrow;
    }
  }

  /// Saves a new DrinkLog to Supabase.
  ///
  /// Note: The 'id' is removed from the JSON payload so Supabase can
  /// auto-increment the primary key.
  Future<void> addDrinkLog(DrinkLog log) async {
    try {
      final data = log.toJson();
      data.remove('id'); // Let database handle ID generation

      await _client.from(_drinkLogsTable).insert(data);
    } catch (e) {
      debugPrint('Error saving drink log: $e');
      rethrow;
    }
  }

  /// Deletes a drink log by ID.
  Future<void> deleteDrinkLog(int id) async {
    try {
      await _client.from(_drinkLogsTable).delete().eq('id', id);
    } catch (e) {
      debugPrint('Error deleting drink log: $e');
      rethrow;
    }
  }

  Future<void> updateDrinkLog(DrinkLog log) async {
    try {
      await _client.from(_drinkLogsTable).update(log.toJson()).eq('id', log.id);
    } catch (e) {
      debugPrint('Error updating urine log: $e');
      rethrow;
    }
  }

  /// Retrieves application settings (e.g., theme, daily drinking goals).
  ///
  /// Returns a Map of key-value pairs.
  /// If no settings are found on disk, it returns a default map:
  /// `{'theme': 'light', 'drinking_goal': 2.0}`.
  Future<Map<String, dynamic>> loadSettings() async {
    try {
      final data = await _client
          .from('settings')
          .select()
          .eq('id', 1)
          .maybeSingle();

      if (data == null) {
        final defaults = {
          'id': 1,
          'theme': 'light',
          'drinking_goal': 2.0,
        };
        await _client.from('settings').insert(defaults);
        return {'theme': 'light', 'drinking_goal': 2.0};
      }

      return {
        'theme': data['theme'],
        'drinking_goal': (data['drinking_goal'] as num).toDouble(),
      };
    } catch (e) {
      debugPrint('Error loading settings from Supabase: $e');
      rethrow;
    }
  }

  /// /// Persists application settings to Supabase.
  ///
  /// Upserts the settings record (id=1) with the provided [theme] and [drinkingGoal].
  /// The updated_at timestamp is automatically set to the current time.
  Future<void> saveSettings(String theme, double drinkingGoal) async {
    await _client.from('settings').upsert({
      'id': 1,
      'theme': theme,
      'drinking_goal': drinkingGoal,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
