import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/core.dart';
import 'data/repositories/supabase_repository.dart';
import 'logic/bloc/log_bloc.dart';
import 'data/services/storage_service.dart';
import 'presentation/main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Config.load();

    // Initialize dependencies
    final remoteRepo = SupabaseRepository();
    final service = StorageService(remoteRepo);
    await service.initialize();

    // Pass the initialized service to the App
    runApp(FlowTrackApp(storageService: service));
  } catch (e) {
    // Show error UI or fallback
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Failed to initialize app: $e'),
          ),
        ),
      ),
    );
  }
}

class FlowTrackApp extends StatelessWidget {
  final StorageService _storageService;

  const FlowTrackApp({
    super.key,
    required StorageService storageService,
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
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF3B82F6),
              surface: const Color(0xFFF0F4F8),
            ),
            fontFamily: 'Roboto',
          ),
          home: const MainScreen(),
        ),
      ),
    );
  }
}
