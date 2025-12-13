import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../logic/bloc/log_bloc.dart';
import '../../helpers/stats_helper.dart';
import '../dialogs/log_dialog.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _showLogDialog(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(context: context, builder: (context) => const LogDialog());
    if (result != null && context.mounted) {
      context.read<LogBloc>().add(AddLog(color: result['color'], amount: result['amount']));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Log added successfully!'), duration: Duration(seconds: 1)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LogBloc, LogState>(
      builder: (context, state) {
        final logs = state.logs;
        final now = state.now;

        final todayStr = DateFormat('yyyy-MM-dd').format(now);
        final todayLogs = logs.where((l) => DateFormat('yyyy-MM-dd').format(l.timestamp) == todayStr).toList();
        final int todayCount = todayLogs.length;

        final lastLog = logs.isNotEmpty ? logs.first : null;
        final lastTime = lastLog != null ? DateFormat('HH:mm').format(lastLog.timestamp) : 'None';

        final dailyStats = StatsHelper.calculateStats(todayLogs, now: now);
        final globalStats = StatsHelper.calculateStats(logs, now: null);

        final hasTodayData = todayLogs.isNotEmpty;
        final displayRate = hasTodayData ? dailyStats['rate']! : globalStats['rate']!;
        final rateLabel = hasTodayData ? "Today Rate" : "Avg Rate";

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text("Hello, User", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              const Text("Track your daily habits.", style: TextStyle(fontSize: 16, color: Color(0xFF64748B))),
              const SizedBox(height: 32),

              GestureDetector(
                onTap: () => _showLogDialog(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFFCD34D)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: const Color(0xFFF59E0B).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Today's Visits", style: TextStyle(color: Color(0xFFFFFBEB), fontWeight: FontWeight.w500)), Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle), child: const Icon(Icons.touch_app, color: Colors.white, size: 16))]),
                      const SizedBox(height: 8),
                      Text("$todayCount", style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Colors.white, height: 1.0)),
                      const SizedBox(height: 24),
                      const Divider(color: Colors.white24),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("LAST VISIT", style: TextStyle(color: Color(0xFFFFFBEB), fontSize: 10, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Row(children: [const Icon(Icons.access_time, color: Colors.white, size: 16), const SizedBox(width: 6), Text(lastTime, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))])]),
                          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(rateLabel.toUpperCase(), style: const TextStyle(color: Color(0xFFFFFBEB), fontSize: 10, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Row(children: [Text(displayRate, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)), const SizedBox(width: 4), const Text("/ hr", style: TextStyle(color: Color(0xFFFFFBEB), fontSize: 12))])]),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const Spacer(),
              const Center(child: Text("Tap card to log", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12))),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}
