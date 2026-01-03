import 'package:fl_chart/fl_chart.dart';
import 'package:flow/data/models/drink_log_entry.dart';
import 'package:flow/data/models/urine_log_entry.dart';
import 'package:flutter/material.dart';

import '../../../data/enums/chart_type.dart';

class ChartWidget extends StatelessWidget {
  final List<UrineLogEntry> urineLogs;
  final List<DrinkLogEntry> drinkLogs;
  final ChartType type;

  const ChartWidget({
    super.key,
    required this.urineLogs,
    required this.drinkLogs,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    // Generate data for 24 hours
    final hours = List.generate(24, (i) => 0.0);
    double maxY = 0;

    if (type == ChartType.urine) {
      for (var log in urineLogs) {
        hours[log.createdAt.hour] += 1.0;
      }
    } else {
      for (var log in drinkLogs) {
        hours[log.createdAt.hour] += log.volume.toDouble();
      }
    }

    // Determine max Y for scaling
    for (var val in hours) {
      if (val > maxY) maxY = val;
    }
    if (maxY == 0) maxY = 5;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final barColor = type == ChartType.urine ? Colors.amber : Colors.blue;
    final bgColor = barColor.withValues(alpha: 0.05);

    // Create Bar Groups
    final barGroups = List.generate(24, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: hours[i],
            color: barColor,
            width: 8,
            borderRadius: BorderRadius.circular(4),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: maxY * 1.1,
              color: bgColor,
            ),
          ),
        ],
      );
    });

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY * 1.1,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => Colors.blueGrey,
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                type == ChartType.urine
                    ? '${rod.toY.toInt()} visits'
                    : '${rod.toY.toInt()} ml',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              // Force checking every single index
              interval: 1,
              getTitlesWidget: (value, meta) {
                final hour = value.toInt();

                // Show label every 2 hours (0, 2, 4...) to prevent overlap
                // If you strictly want EVERY hour, change this to: if (true)
                if (hour % 2 == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '$hour', // Removed 'h' to save space
                      style: TextStyle(
                        color: isDark
                            ? Colors.grey[400]
                            : const Color(0xFF94A3B8),
                        fontSize: 10, // Small font to fit
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
      ),
    );
  }
}
