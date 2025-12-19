import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../helpers/stats_helper.dart';
import '../../logic/bloc/log_bloc.dart';
import '../widgets/chart_widget.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  String _statType = 'urine';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LogBloc, LogState>(
      builder: (context, state) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        // Filter logs for today
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        final todayUrineLogs = state.urineLogs.where((log) {
          final logDate = DateTime(
            log.createdAt.year,
            log.createdAt.month,
            log.createdAt.day,
          );
          return logDate.isAtSameMomentAs(today);
        }).toList();

        final todayDrinkLogs = state.drinkLogs.where((log) {
          final logDate = DateTime(
            log.createdAt.year,
            log.createdAt.month,
            log.createdAt.day,
          );
          return logDate.isAtSameMomentAs(today);
        }).toList();

        // Calculate Stats
        // --- URINE ---
        final dailyDrinkStats = StatsHelper.getDrinkingStats(
          todayDrinkLogs,
          now: now,
        );

        final dailyUrinationStats = StatsHelper.getUrinationStats(
          todayUrineLogs,
          now: now,
        );

        final urineTotal = todayUrineLogs.length;
        final currentHour = now.hour;
        final urineRate = (urineTotal > 0)
            ? (urineTotal / (currentHour + 1)).toStringAsFixed(1)
            : "0.0";

        // Calculate Avg Color (Mode) - NOW TRACKING ACTUAL COLOR OBJECT
        String urineAvgLabel = "-";
        Color? urineAvgColorObj;

        if (todayUrineLogs.isNotEmpty) {
          final counts = <String, int>{};
          // Map label to actual Color object so we can retrieve it later
          final colorMap = <String, Color>{};

          for (var log in todayUrineLogs) {
            counts[log.color.label] = (counts[log.color.label] ?? 0) + 1;
            // Assuming log.color has a .color property returning a Flutter Color
            // If log.color IS the Flutter color, just use log.color
            colorMap[log.color.label] = log.color.color;
          }

          var max = 0;
          counts.forEach((k, v) {
            if (v > max) {
              max = v;
              urineAvgLabel = k;
              urineAvgColorObj = colorMap[k];
            }
          });
        }

        // Calculate Avg Volume (Mode for string amounts)
        String urineAvgVol = "-";
        if (todayUrineLogs.isNotEmpty) {
          final counts = <String, int>{};
          for (var log in todayUrineLogs) {
            counts[log.amount] = (counts[log.amount] ?? 0) + 1;
          }
          var max = 0;
          counts.forEach((k, v) {
            if (v > max) {
              max = v;
              urineAvgVol = k;
            }
          });
        }

        // --- DRINK ---
        final drinkTotalMl = todayDrinkLogs.fold<int>(
          0,
          (sum, item) => sum + item.volume,
        );
        final drinkTotalL = (drinkTotalMl / 1000).toStringAsFixed(1);
        final drinkRate = (todayDrinkLogs.isNotEmpty)
            ? (todayDrinkLogs.length / (currentHour + 1)).toStringAsFixed(1)
            : "0.0";
        final drinkAvgVol = (todayDrinkLogs.isNotEmpty)
            ? (drinkTotalMl / todayDrinkLogs.length).round()
            : 0;

        String drinkMostConsumed = "-";
        if (todayDrinkLogs.isNotEmpty) {
          final typeCounts = <String, int>{};
          for (var log in todayDrinkLogs) {
            typeCounts[log.fluidType] = (typeCounts[log.fluidType] ?? 0) + 1;
          }
          var maxCount = 0;
          typeCounts.forEach((key, value) {
            if (value > maxCount) {
              maxCount = value;
              drinkMostConsumed = key;
            }
          });
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                "Analytics",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 24),

              // Type Toggle
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: ['urine', 'drink'].map((type) {
                    final isSelected = _statType == type;
                    final label = type == 'urine' ? 'Toilet' : 'Drinks';
                    final activeColor = type == 'urine'
                        ? Colors.amber
                        : Colors.blue;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _statType = type),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark
                                      ? const Color(0xFF1E293B)
                                      : Colors.white)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                type == 'urine'
                                    ? Icons.water_drop_outlined
                                    : Icons.local_drink_outlined,
                                size: 16,
                                color: isSelected
                                    ? activeColor
                                    : (isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600]),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                label,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? activeColor
                                      : (isDark
                                            ? Colors.grey[400]
                                            : const Color(0xFF64748B)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // Chart Area (Day View Only)
              Container(
                height: 250,
                padding: const EdgeInsets.only(
                  top: 24,
                  right: 16,
                  left: 8,
                  bottom: 8,
                ),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? Colors.transparent
                        : const Color(0xFFF1F5F9),
                  ),
                ),
                child: ChartWidget(
                  urineLogs: _statType == 'urine' ? todayUrineLogs : [],
                  drinkLogs: _statType == 'drink' ? todayDrinkLogs : [],
                  type: _statType,
                ),
              ),
              const SizedBox(height: 24),

              // Summary Grid
              if (_statType == 'urine') ...[
                _buildSummaryGrid(
                  context,
                  isDark,
                  item1: _buildSummaryItem(
                    context,
                    "Today Total",
                    dailyUrinationStats.total.toString(),
                    "visits",
                    Colors.amber,
                  ),
                  item2: _buildSummaryItem(
                    context,
                    "Frequency",
                    dailyUrinationStats.frequency,
                    "",
                    isDark ? Colors.white : Colors.black87,
                  ),
                  item3: _buildSummaryItem(
                    context,
                    "Avg Color",
                    urineAvgLabel,
                    "",
                    isDark ? Colors.white : Colors.black87,
                    displayColor: urineAvgColorObj,
                  ),
                  item4: _buildSummaryItem(
                    context,
                    "Avg Volume",
                    urineAvgVol,
                    "",
                    isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ] else ...[
                _buildSummaryGrid(
                  context,
                  isDark,
                  item1: _buildSummaryItem(
                    context,
                    "Today Total",
                    dailyDrinkStats.total.toString(),
                    "Liters",
                    Colors.blue,
                  ),
                  item2: _buildSummaryItem(
                    context,
                    "Frequency",
                    dailyDrinkStats.frequency,
                    "",
                    isDark ? Colors.white : Colors.black87,
                  ),
                  item3: _buildSummaryItem(
                    context,
                    "Most Consumed",
                    drinkMostConsumed,
                    "",
                    isDark ? Colors.white : Colors.black87,
                  ),
                  item4: _buildSummaryItem(
                    context,
                    "Avg Drinking Volume",
                    "$drinkAvgVol",
                    "ml",
                    isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryGrid(
    BuildContext context,
    bool isDark, {
    required Widget item1,
    required Widget item2,
    required Widget item3,
    required Widget item4,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: item1),
            const SizedBox(width: 12),
            Expanded(child: item2),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: item3),
            const SizedBox(width: 12),
            Expanded(child: item4),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String title,
    String value,
    String unit,
    Color valueColor, {
    Color? displayColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.transparent : const Color(0xFFF1F5F9),
        ),
      ),
      child: Column(
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey[400] : const Color(0xFF94A3B8),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),

          // IF displayColor is provided, show the Circle, otherwise show Text
          if (displayColor != null)
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: displayColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? Colors.white24 : Colors.black12,
                  width: 1,
                ),
              ),
            )
          else
            Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: valueColor,
              ),
            ),

          if (unit.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              unit,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.grey[400] : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
