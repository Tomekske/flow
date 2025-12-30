import 'package:flow/presentation/mobile/mobile_entrypoint.dart';
import 'package:flow/presentation/watch/watch_entrypoint.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/core.dart';
import 'core/device_type_helper.dart';
import 'data/repositories/supabase_repository.dart';
import 'data/services/storage_service.dart';
import 'logic/bloc/log_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check device type first
  final isWatch = await DeviceTypeHelper.isWearOS();
  print("IS WATCH: $isWatch");

  try {
    await Config.load();

    // Initialize dependencies
    final remoteRepo = SupabaseRepository();
    final service = StorageService(remoteRepo);

    // Run the app with dependencies and device type injected
    runApp(
      FlowTrackApp(
        storageService: service,
        isWatch: isWatch,
      ),
    );
  } catch (e) {
    debugPrint('Failed to initialize app: $e');
    runApp(const InitializationErrorApp());
  }
}

class FlowTrackApp extends StatelessWidget {
  final StorageService _storageService;
  final bool isWatch;

  const FlowTrackApp({
    super.key,
    required StorageService storageService,
    required this.isWatch,
  }) : _storageService = storageService;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: _storageService,
      child: BlocProvider(
        create: (context) => LogBloc(
          storageService: context.read<StorageService>(),
        ),
        child: MaterialApp(
          title: 'FlowTrack',
          debugShowCheckedModeBanner: false,

          // Adapt Theme based on Device Type
          theme: ThemeData(
            useMaterial3: true,
            brightness: isWatch ? Brightness.dark : Brightness.light,
            visualDensity: isWatch
                ? VisualDensity.compact
                : VisualDensity.standard,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF3B82F6),
              surface: isWatch ? Colors.black : const Color(0xFFF0F4F8),
              brightness: isWatch ? Brightness.dark : Brightness.light,
            ),
            fontFamily: 'Roboto',
          ),

          home: isWatch ? const WatchEntrypoint() : const MobileEntrypoint(),
        ),
      ),
    );
  }
}

/// Simple Widget to display errors if Supabase/Config fails
class InitializationErrorApp extends StatelessWidget {
  const InitializationErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Failed to initialize app. Please restart.'),
        ),
      ),
    );
  }
}
