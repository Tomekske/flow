import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../logic/bloc/log_bloc.dart';
import '../../helpers/stats_helper.dart';
import '../widgets/chart_widget.dart';
import '../widgets/frequency_card.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  String _chartPeriod = 'hourly';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LogBloc, LogState>(
      builder: (context, state) {
        final logs = state.logs;
        final now = state.now;

        final todayStr = DateFormat('yyyy-MM-dd').format(now);
        final todayLogs = logs.where((l) => DateFormat('yyyy-MM-dd').format(l.timestamp) == todayStr).toList();
        
        final dailyStats = StatsHelper.calculateStats(todayLogs, now: now);
        final globalStats = StatsHelper.calculateStats(logs, now: null);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text("Analytics", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              const SizedBox(height: 24),
              
              // Segmented Control
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: ['hourly', 'weekly', 'monthly'].map((period) {
                    final bool isSelected = _chartPeriod == period;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _chartPeriod = period),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(color: isSelected ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(8), boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2)] : []),
                          alignment: Alignment.center,
                          child: Text(period.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? const Color(0xFF1E293B) : const Color(0xFF64748B))),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                height: 250,
                padding: const EdgeInsets.only(top: 24, right: 16, left: 8, bottom: 8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFF1F5F9))),
                child: ChartWidget(logs: logs, period: _chartPeriod),
              ),
              const SizedBox(height: 24),
              FrequencyCard(
                dailyRate: dailyStats['rate']!,
                globalRate: globalStats['rate']!,
                dailyInterval: dailyStats['interval']!,
                globalInterval: globalStats['interval']!,
              ),
            ],
          ),
        );
      },
    );
  }
}
