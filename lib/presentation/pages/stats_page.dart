import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/enums/chart_type.dart';
import '../../helpers/stats_helper.dart';
import '../../logic/bloc/log_bloc.dart';
import '../widgets/chart_widget.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  ChartType _statType = ChartType.urine;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LogBloc, LogState>(
      builder: (context, state) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        // Filter logs for today
        final now = state.now;
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
        final dailyDrinkStats = StatsHelper.getDrinkingStats(
          todayDrinkLogs,
          now: now,
        );

        final dailyUrinationStats = StatsHelper.getUrinationStats(
          todayUrineLogs,
          now: now,
        );

        // Calculate Avg Color (Mode)
        String urineAvgLabel = "-";
        Color? urineAvgColorObj;

        if (todayUrineLogs.isNotEmpty) {
          final counts = <String, int>{};
          final colorMap = <String, Color>{};

          for (var log in todayUrineLogs) {
            counts[log.color.label] = (counts[log.color.label] ?? 0) + 1;
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

        // Calculate Avg Urgency (Mode)
        String urineAvgUrgency = "-";
        if (todayUrineLogs.isNotEmpty) {
          final counts = <String, int>{};
          for (var log in todayUrineLogs) {
            // FIX: Convert Enum to String using .name
            final urgencyKey = log.urgency.name;
            counts[urgencyKey] = (counts[urgencyKey] ?? 0) + 1;
          }
          var max = 0;
          counts.forEach((k, v) {
            if (v > max) {
              max = v;
              urineAvgUrgency = k;
            }
          });
        }

        // --- DRINK ---
        final drinkTotalMl = todayDrinkLogs.fold<int>(
          0,
          (sum, item) => sum + item.volume,
        );
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
                  children: ChartType.values.map((type) {
                    final isSelected = _statType == type;
                    final label = type == ChartType.urine ? 'Toilet' : 'Drinks';
                    final activeColor = type == ChartType.urine
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
                                type == ChartType.urine
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

              // Chart Area
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
                  urineLogs: _statType == ChartType.urine ? todayUrineLogs : [],
                  drinkLogs: _statType == ChartType.drink ? todayDrinkLogs : [],
                  type: _statType,
                ),
              ),
              const SizedBox(height: 24),

              // Summary Grid
              if (_statType == ChartType.urine) ...[
                _buildSummaryGrid(
                  context,
                  [
                    _buildSummaryItem(
                      context,
                      "Today Total",
                      dailyUrinationStats.total.toString(),
                      "visits",
                      Colors.amber,
                    ),
                    _buildSummaryItem(
                      context,
                      "Frequency",
                      dailyUrinationStats.frequency,
                      "",
                      isDark ? Colors.white : Colors.black87,
                    ),
                    _buildSummaryItem(
                      context,
                      "Avg Color",
                      urineAvgLabel,
                      "",
                      isDark ? Colors.white : Colors.black87,
                      displayColor: urineAvgColorObj,
                    ),
                    _buildSummaryItem(
                      context,
                      "Avg Volume",
                      urineAvgVol,
                      "",
                      isDark ? Colors.white : Colors.black87,
                    ),
                    _buildSummaryItem(
                      context,
                      "Avg Urgency",
                      urineAvgUrgency,
                      "",
                      isDark ? Colors.white : Colors.black87,
                    ),
                  ],
                ),
              ] else ...[
                _buildSummaryGrid(
                  context,
                  [
                    _buildSummaryItem(
                      context,
                      "Today Total",
                      dailyDrinkStats.total.toString(),
                      "Liters",
                      Colors.blue,
                    ),
                    _buildSummaryItem(
                      context,
                      "Frequency",
                      dailyDrinkStats.frequency,
                      "",
                      isDark ? Colors.white : Colors.black87,
                    ),
                    _buildSummaryItem(
                      context,
                      "Most Consumed",
                      drinkMostConsumed,
                      "",
                      isDark ? Colors.white : Colors.black87,
                    ),
                    _buildSummaryItem(
                      context,
                      "Avg Drinking Volume",
                      "$drinkAvgVol",
                      "ml",
                      isDark ? Colors.white : Colors.black87,
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // Uses GridView with AspectRatio
  Widget _buildSummaryGrid(BuildContext context, List<Widget> items) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      // UPDATED: Increased ratio to 1.6 to make cards shorter (less vertical padding)
      childAspectRatio: 1.6,
      children: items,
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
      // UPDATED: Reduced vertical padding to 8
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.transparent : const Color(0xFFF1F5F9),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey[400] : const Color(0xFF94A3B8),
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
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
