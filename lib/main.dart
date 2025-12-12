import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'logic/bloc/log_bloc.dart';
import 'data/services/storage_service.dart';
import 'presentation/main_screen.dart';

void main() {
  runApp(const FlowTrackApp());
}

class FlowTrackApp extends StatelessWidget {
  const FlowTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => StorageService(),
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
              background: const Color(0xFFF0F4F8),
            ),
            fontFamily: 'Roboto',
          ),
          home: const MainScreen(),
        ),
      ),
    );
  }
}
