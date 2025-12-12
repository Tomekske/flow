import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/log.dart';

class ChartWidget extends StatelessWidget {
  final List<Log> logs;
  final String period; // hourly, weekly, monthly

  const ChartWidget({super.key, required this.logs, required this.period});

  @override
  Widget build(BuildContext context) {
    List<BarChartGroupData> barGroups = [];
    double maxY = 0;

    if (period == 'hourly') {
      final hours = List.generate(24, (i) => 0);
      for (var log in logs) {
        hours[log.timestamp.hour]++;
      }
      barGroups = List.generate(24, (i) {
        if (hours[i] > maxY) maxY = hours[i].toDouble();
        return BarChartGroupData(x: i, barRods: [BarChartRodData(toY: hours[i].toDouble(), color: const Color(0xFF8B5CF6), width: 6, borderRadius: BorderRadius.circular(2))]);
      });
    } else if (period == 'weekly') {
      final now = DateTime.now();
      for (int i = 6; i >= 0; i--) {
        final d = now.subtract(Duration(days: i));
        final dayStr = DateFormat('yyyy-MM-dd').format(d);
        final count = logs.where((l) => DateFormat('yyyy-MM-dd').format(l.timestamp) == dayStr).length;
        if (count > maxY) maxY = count.toDouble();
        barGroups.add(BarChartGroupData(
          x: 6 - i, 
          barRods: [BarChartRodData(toY: count.toDouble(), color: const Color(0xFF3B82F6), width: 16, borderRadius: BorderRadius.circular(4))]
        ));
      }
    } else {
      // Monthly
       final now = DateTime.now();
       for (int i = 29; i >= 0; i--) {
         final d = now.subtract(Duration(days: i));
         final dayStr = DateFormat('yyyy-MM-dd').format(d);
         final count = logs.where((l) => DateFormat('yyyy-MM-dd').format(l.timestamp) == dayStr).length;
         if (count > maxY) maxY = count.toDouble();
         barGroups.add(BarChartGroupData(
           x: 29 - i, 
           barRods: [BarChartRodData(toY: count.toDouble(), color: const Color(0xFF0EA5E9), width: 6, borderRadius: BorderRadius.circular(2))]
         ));
       }
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY == 0 ? 1 : maxY + 1,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
             tooltipBgColor: Colors.blueGrey,
             getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(rod.toY.round().toString(), const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (period == 'hourly') {
                   return value % 4 == 0 ? Text('${value.toInt()}h', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)) : const SizedBox();
                } else if (period == 'weekly') {
                   final date = DateTime.now().subtract(Duration(days: 6 - value.toInt()));
                   return Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(DateFormat('E').format(date), style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)));
                }
                return const SizedBox();
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}
