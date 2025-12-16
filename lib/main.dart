import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'logic/bloc/log_bloc.dart';
import 'data/services/storage_service.dart';
import 'data/repositories/shared_preferences_repository.dart';
import 'presentation/main_screen.dart';

Future<void> main() async {
  // Ensure bindings are initialized for async code
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependencies
  final prefs = await SharedPreferences.getInstance();
  final repository = SharedPreferencesRepository(prefs);
  final service = StorageService(repository);

  // Pass the initialized service to the App
  runApp(FlowTrackApp(storageService: service));
}

class FlowTrackApp extends StatelessWidget {
  final StorageService storageService;

  const FlowTrackApp({
    super.key,
    required this.storageService,
  });

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: storageService,
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
