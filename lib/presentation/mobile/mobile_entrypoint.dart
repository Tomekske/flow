import 'package:flow/presentation/mobile/pages/history_page.dart';
import 'package:flow/presentation/mobile/pages/home_page.dart';
import 'package:flow/presentation/mobile/pages/settings_page.dart';
import 'package:flow/presentation/mobile/pages/stats_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/bloc/log_bloc.dart';

class MobileEntrypoint extends StatefulWidget {
  const MobileEntrypoint({super.key});

  @override
  State<MobileEntrypoint> createState() => _MobileEntrypointState();
}

class _MobileEntrypointState extends State<MobileEntrypoint> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    StatsScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LogBloc, LogState>(
      builder: (context, state) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFF0F4F8),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: const Color(0xFF0F172A),
          ),
          themeMode: state.theme == 'dark' ? ThemeMode.dark : ThemeMode.light,
          home: Scaffold(
            body: SafeArea(
              child: IndexedStack(index: _selectedIndex, children: _pages),
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (idx) =>
                  setState(() => _selectedIndex = idx),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.bar_chart_outlined),
                  selectedIcon: Icon(Icons.bar_chart),
                  label: 'Stats',
                ),
                NavigationDestination(
                  icon: Icon(Icons.history_outlined),
                  selectedIcon: Icon(Icons.history),
                  label: 'History',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
