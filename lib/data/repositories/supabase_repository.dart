import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> initializeUser() async {
    if (_client.auth.currentUser == null) {
      await _client.auth.signInAnonymously();
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

  /// Persists a list of [Log] entries to local storage.
  ///
  /// The [logs] list is converted to a JSON string before being saved.
  /// This overwrites any previously stored logs.
  Future<void> saveSettings(String theme, double drinkingGoal) async {
    await _client.from('settings').upsert({
      'id': 1,
      'theme': theme,
      'drinking_goal': drinkingGoal,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
