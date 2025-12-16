import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Handles the initialization of global application configuration.
///
/// This class is responsible for loading environment-specific variables
/// (from `.env` files) and initializing core services like Supabase
/// before the UI starts.
class Config {
  /// Loads the environment configuration and initializes external services.
  ///
  /// This method determines which environment to use based on the `ENV`
  /// compile-time flag.
  ///
  /// Usage:
  /// * **Dev (Default):** `flutter run`
  /// * **Prod:** `flutter run --dart-define=ENV=prd`
  ///
  /// Throws an [Exception] if the configuration file is missing or if
  /// Supabase initialization fails.
  static Future<void> load() async {
    // Determine Environment
    const envType = String.fromEnvironment('ENV', defaultValue: 'dev');
    final envFile = envType == 'prd' ? '.env.prd' : '.env.dev';

    if (kDebugMode) {
      debugPrint('Loading Config: [$envType] from $envFile');
    }

    // Load ENV File
    try {
      await dotenv.load(fileName: envFile);
    } catch (e) {
      throw Exception('Missing config file: $envFile');
    }

    // Init Supabase
    try {
      final supabaseUrl = dotenv.env['SUPABASE_URL'];
      final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'];

      if (supabaseUrl == null || supabaseKey == null) {
        throw Exception(
          'Missing required env variables: SUPABASE_URL or SUPABASE_ANON_KEY',
        );
      }

      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseKey,
      );
    } catch (e) {
      throw Exception('Supabase connection failed: $e');
    }
  }
}
