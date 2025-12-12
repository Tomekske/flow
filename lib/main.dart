import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const FlowTrackApp());
}

class FlowTrackApp extends StatelessWidget {
  const FlowTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
    );
  }
}

class Log {
  final int id;
  final DateTime timestamp;

  Log({required this.id, required this.timestamp});

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
  };

  factory Log.fromJson(Map<String, dynamic> json) => Log(
    id: json['id'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  List<Log> _logs = [];
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadLogs();
    // Update time every minute for realtime stats
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? logsJson = prefs.getString('flowtrack_logs');
    if (logsJson != null) {
      final List<dynamic> decoded = jsonDecode(logsJson);
      setState(() {
        _logs = decoded.map((item) => Log.fromJson(item)).toList();
      });
    }
  }

  Future<void> _saveLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_logs.map((e) => e.toJson()).toList());
    await prefs.setString('flowtrack_logs', encoded);
  }

  void _addLog() {
    setState(() {
      _logs.insert(0, Log(id: DateTime.now().millisecondsSinceEpoch, timestamp: DateTime.now()));
    });
    _saveLogs();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Log added successfully!'),
        duration: Duration(seconds: 1),
        backgroundColor: Color(0xFF1E293B),
      ),
    );
  }

  void _deleteLog(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Log?'),
        content: const Text('Are you sure you want to remove this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _logs.removeWhere((log) => log.id == id);
              });
              _saveLogs();
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _clearAllLogs() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All History?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _logs.clear();
              });
              _saveLogs();
              Navigator.pop(ctx);
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget currentScreen;
    switch (_selectedIndex) {
      case 0:
        currentScreen = HomeScreen(logs: _logs, onAddLog: _addLog, now: _now);
        break;
      case 1:
        currentScreen = StatsScreen(logs: _logs, now: _now);
        break;
      case 2:
        currentScreen = HistoryScreen(logs: _logs, onDelete: _deleteLog, onClear: _clearAllLogs);
        break;
      default:
        currentScreen = Container();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: currentScreen),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
        backgroundColor: Colors.white,
        elevation: 1,
        indicatorColor: Colors.blue.shade50,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Colors.blue),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart, color: Colors.blue),
            label: 'Stats',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history, color: Colors.blue),
            label: 'History',
          ),
        ],
      ),
    );
  }
}

// --- HOME SCREEN ---

class HomeScreen extends StatelessWidget {
  final List<Log> logs;
  final VoidCallback onAddLog;
  final DateTime now;

  const HomeScreen({
    super.key,
    required this.logs,
    required this.onAddLog,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    // Calculations
    final today = DateFormat('yyyy-MM-dd').format(now);
    final todayLogs = logs.where((l) => DateFormat('yyyy-MM-dd').format(l.timestamp) == today).toList();
    final int todayCount = todayLogs.length;

    final Log? lastLog = logs.isNotEmpty ? logs.first : null;
    final String lastTime = lastLog != null ? DateFormat('HH:mm').format(lastLog.timestamp) : 'None';

    // Frequency Calculations (Interval Based)
    // 1. Daily
    final DateTime startOfDay = DateTime(now.year, now.month, now.day);
    double hoursElapsedToday = now.difference(startOfDay).inMinutes / 60.0;
    if (hoursElapsedToday < 0.01) hoursElapsedToday = 0.01;
    final String dailyRate = (todayCount / hoursElapsedToday).toStringAsFixed(2);

    // 2. Global
    String globalRate = "0.00";
    if (logs.length >= 2) {
      final sortedLogs = List<Log>.from(logs)..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      final firstLogDate = sortedLogs.first.timestamp;
      final startOfFirstDay = DateTime(firstLogDate.year, firstLogDate.month, firstLogDate.day);
      final lastLogDate = sortedLogs.last.timestamp;

      double totalHours = lastLogDate.difference(startOfFirstDay).inMinutes / 60.0;
      if (totalHours < 1) totalHours = 1;

      globalRate = (logs.length / totalHours).toStringAsFixed(2);
    }

    final bool hasTodayData = todayLogs.length >= 1; // Show daily rate even if just 1 log exists (since we use interval from midnight)
    final String displayRate = hasTodayData ? dailyRate : globalRate;
    final String rateLabel = hasTodayData ? "Today Rate" : "Avg Rate";

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            "Hello, User",
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const Text(
            "Track your daily habits.",
            style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 32),

          // Dashboard Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF22D3EE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Background icon placeholder could go here
                  ],
                ),
                const Text("Today's Visits", style: TextStyle(color: Color(0xFFDBEAFE), fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Text(
                  "$todayCount",
                  style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Colors.white, height: 1.0),
                ),
                const SizedBox(height: 24),
                const Divider(color: Colors.white24),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("LAST VISIT", style: TextStyle(color: Color(0xFFDBEAFE), fontSize: 10, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.access_time, color: Colors.white, size: 16),
                            const SizedBox(width: 6),
                            Text(lastTime, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                          ],
                        )
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(rateLabel.toUpperCase(), style: const TextStyle(color: Color(0xFFDBEAFE), fontSize: 10, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(displayRate, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                            const SizedBox(width: 4),
                            const Text("/ hr", style: TextStyle(color: Color(0xFFDBEAFE), fontSize: 12)),
                          ],
                        )
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),

          const Spacer(),

          // Big Button
          Center(
            child: GestureDetector(
              onTap: onAddLog,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFF1F5F9), width: 8),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Color(0xFF2563EB),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 40),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          const Center(child: Text("Tap to record", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12))),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// --- STATS SCREEN ---

class StatsScreen extends StatefulWidget {
  final List<Log> logs;
  final DateTime now;

  const StatsScreen({super.key, required this.logs, required this.now});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  String _chartPeriod = 'hourly'; // hourly, weekly, monthly

  @override
  Widget build(BuildContext context) {
    final freqStats = _calculateFrequencyStats();
    final dailyStats = _calculateDailyStats();

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
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: ['hourly', 'weekly', 'monthly'].map((period) {
                final bool isSelected = _chartPeriod == period;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _chartPeriod = period),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2)] : [],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        period.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? const Color(0xFF1E293B) : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),

          // Chart
          Container(
            height: 250,
            padding: const EdgeInsets.only(top: 24, right: 16, left: 8, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: _buildChart(),
          ),

          const SizedBox(height: 24),

          // Frequency Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE0E7FF)),
            ),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Frequency Analysis", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF312E81))),
                        Text("Compare Daily vs All-Time", style: TextStyle(fontSize: 12, color: Color(0xFF4F46E5))),
                      ],
                    ),
                    Icon(Icons.access_time_filled, color: Color(0xFF6366F1)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Expanded(child: Text("METRIC", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFA5B4FC)))),
                    Expanded(child: Container(alignment: Alignment.center, padding: const EdgeInsets.symmetric(vertical: 4), decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(4)), child: const Text("TODAY", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))))),
                    const Expanded(child: Center(child: Text("ALL TIME", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFA5B4FC))))),
                  ],
                ),
                const SizedBox(height: 12),
                _buildStatRow("Visits / Hr", dailyStats['rate'] ?? "0.00", freqStats['rate'] ?? "0.00", true),
                const SizedBox(height: 8),
                _buildStatRow("Avg Gap", dailyStats['interval'] ?? "--", freqStats['interval'] ?? "--", false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String val1, String val2, bool highlight) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF312E81)))),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE0E7FF)),
            ),
            child: Center(child: Text(val1, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)))),
          ),
        ),
        Expanded(child: Center(child: Text(val2, style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF818CF8))))),
      ],
    );
  }

  Widget _buildChart() {
    // Generate data based on _chartPeriod
    List<BarChartGroupData> barGroups = [];
    double maxY = 0;

    if (_chartPeriod == 'hourly') {
      final hours = List.generate(24, (i) => 0);
      for (var log in widget.logs) {
        hours[log.timestamp.hour]++;
      }
      for (int i = 0; i < 24; i += 3) {
        // Aggregating for cleaner mobile view or showing all. Let's show every 3rd hour label but all bars.
        barGroups.add(BarChartGroupData(x: i, barRods: [BarChartRodData(toY: hours[i].toDouble(), color: const Color(0xFF8B5CF6), width: 8, borderRadius: BorderRadius.circular(4))]));
        if (hours[i] > maxY) maxY = hours[i].toDouble();
      }
      // Note: This simple loop misses bars between intervals 3,6,9 if we just loop +=3.
      // Correct approach for FL Chart:
      barGroups = List.generate(24, (i) {
        if (hours[i] > maxY) maxY = hours[i].toDouble();
        return BarChartGroupData(x: i, barRods: [BarChartRodData(toY: hours[i].toDouble(), color: const Color(0xFF8B5CF6), width: 6, borderRadius: BorderRadius.circular(2))]);
      });

    } else if (_chartPeriod == 'weekly') {
      final now = DateTime.now();
      for (int i = 6; i >= 0; i--) {
        final d = now.subtract(Duration(days: i));
        final dayStr = DateFormat('yyyy-MM-dd').format(d);
        final count = widget.logs.where((l) => DateFormat('yyyy-MM-dd').format(l.timestamp) == dayStr).length;
        if (count > maxY) maxY = count.toDouble();

        barGroups.add(BarChartGroupData(
            x: 6 - i,
            barRods: [BarChartRodData(toY: count.toDouble(), color: const Color(0xFF3B82F6), width: 16, borderRadius: BorderRadius.circular(4))]
        ));
      }
    } else {
      // Monthly - Last 30 days
      final now = DateTime.now();
      for (int i = 29; i >= 0; i--) {
        final d = now.subtract(Duration(days: i));
        final dayStr = DateFormat('yyyy-MM-dd').format(d);
        final count = widget.logs.where((l) => DateFormat('yyyy-MM-dd').format(l.timestamp) == dayStr).length;
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
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                rod.toY.round().toString(),
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (_chartPeriod == 'hourly') {
                  if (value % 4 == 0) { // Show 0, 4, 8, 12...
                    return Text('${value.toInt()}h', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10));
                  }
                  return const Text('');
                } else if (_chartPeriod == 'weekly') {
                  // Map index 0..6 to Day Names
                  final date = DateTime.now().subtract(Duration(days: 6 - value.toInt()));
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(DateFormat('E').format(date), style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
                  );
                }
                return const Text(''); // Hide monthly labels mostly to avoid clutter
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

  // Helper for Global Stats
  Map<String, String> _calculateFrequencyStats() {
    if (widget.logs.length < 2) return {'rate': '0.00', 'interval': 'N/A'};

    final sortedLogs = List<Log>.from(widget.logs)..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final firstLogDate = sortedLogs.first.timestamp;
    // Align to midnight of first day
    final startOfFirstDay = DateTime(firstLogDate.year, firstLogDate.month, firstLogDate.day);
    final lastLogDate = sortedLogs.last.timestamp;

    double hoursDiff = lastLogDate.difference(startOfFirstDay).inMinutes / 60.0;
    if (hoursDiff < 1) hoursDiff = 1;

    final rate = (widget.logs.length / hoursDiff).toStringAsFixed(2);

    final avgHours = hoursDiff / widget.logs.length;
    final h = avgHours.floor();
    final m = ((avgHours - h) * 60).round();

    return {'rate': rate, 'interval': '${h}h ${m}m'};
  }

  // Helper for Daily Stats
  Map<String, String> _calculateDailyStats() {
    final today = DateFormat('yyyy-MM-dd').format(widget.now);
    final todayLogs = widget.logs.where((l) => DateFormat('yyyy-MM-dd').format(l.timestamp) == today).toList();

    final startOfDay = DateTime(widget.now.year, widget.now.month, widget.now.day);
    double hoursElapsed = widget.now.difference(startOfDay).inMinutes / 60.0;
    if (hoursElapsed < 0.01) hoursElapsed = 0.01;

    if (todayLogs.isEmpty) return {'rate': '0.00', 'interval': 'No logs'};

    final rate = (todayLogs.length / hoursElapsed).toStringAsFixed(2);

    final avgHours = hoursElapsed / todayLogs.length;
    final h = avgHours.floor();
    final m = ((avgHours - h) * 60).round();

    return {'rate': rate, 'interval': '${h}h ${m}m'};
  }
}

// --- HISTORY SCREEN ---

class HistoryScreen extends StatelessWidget {
  final List<Log> logs;
  final Function(int) onDelete;
  final VoidCallback onClear;

  const HistoryScreen({super.key, required this.logs, required this.onDelete, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("History Log", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              if (logs.isNotEmpty)
                TextButton(
                  onPressed: onClear,
                  style: TextButton.styleFrom(backgroundColor: const Color(0xFFFEF2F2), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
                  child: const Text("Clear All", style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                )
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: logs.isEmpty
                ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.assignment_outlined, size: 48, color: Colors.black12), SizedBox(height: 16), Text("No logs found yet.", style: TextStyle(color: Colors.black26))]))
                : ListView.builder(
              itemCount: logs.length,
              itemBuilder: (ctx, index) {
                final log = logs[index];
                // Calculate interval since previous log (which is next in list since sorted desc)
                String? intervalBadge;
                if (index < logs.length - 1) {
                  final nextLog = logs[index + 1]; // Actually older log
                  final diff = log.timestamp.difference(nextLog.timestamp);
                  if (diff.inMinutes > 0) {
                    final h = diff.inHours;
                    final m = diff.inMinutes % 60;
                    intervalBadge = "${h}h ${m}m";
                  }
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: const Color(0xFFDBEAFE), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.check, color: Color(0xFF2563EB), size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(DateFormat('hh:mm a').format(log.timestamp), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF334155))),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(DateFormat('MMM dd, yyyy').format(log.timestamp), style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                                if (intervalBadge != null) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.timer_outlined, size: 10, color: Color(0xFF94A3B8)),
                                        const SizedBox(width: 2),
                                        Text(intervalBadge, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  )
                                ]
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => onDelete(log.id),
                        icon: const Icon(Icons.delete_outline, color: Color(0xFFCBD5E1)),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}