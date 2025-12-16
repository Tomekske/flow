import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/bloc/log_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LogBloc, LogState>(
      builder: (context, state) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                "Settings",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Theme
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Appearance",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[700] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: ['light', 'dark'].map((mode) {
                          final isSelected = state.theme == mode;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => context.read<LogBloc>().add(
                                UpdateSettings(theme: mode),
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? (isDark
                                            ? Colors.grey[600]
                                            : Colors.white)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.05,
                                            ),
                                            blurRadius: 2,
                                          ),
                                        ]
                                      : [],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  mode.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? (isDark ? Colors.white : Colors.black)
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Goal
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Daily Fluid Goal",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${state.dailyGoal.toStringAsFixed(1)} L",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => context.read<LogBloc>().add(
                                UpdateSettings(
                                  drinkingGoal: (state.dailyGoal - 0.1).clamp(
                                    0.5,
                                    5.0,
                                  ),
                                ),
                              ),
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            IconButton(
                              onPressed: () => context.read<LogBloc>().add(
                                UpdateSettings(
                                  drinkingGoal: (state.dailyGoal + 0.1).clamp(
                                    0.5,
                                    5.0,
                                  ),
                                ),
                              ),
                              icon: const Icon(
                                Icons.add_circle_outline,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Slider(
                      value: state.dailyGoal,
                      min: 0.5,
                      max: 5.0,
                      divisions: 45,
                      activeColor: Colors.blue,
                      onChanged: (val) => context.read<LogBloc>().add(
                        UpdateSettings(drinkingGoal: val),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
