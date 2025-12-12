import 'package:intl/intl.dart';
import '../data/models/log.dart';

class StatsHelper {
  /// Calculates Rate (visits/hr) and Avg Interval string
  static Map<String, String> calculateStats(List<Log> logs, {DateTime? now}) {
    // If specific logs provided (e.g. today's logs)
    if (logs.isEmpty) return {'rate': '0.00', 'interval': 'No logs'};

    // Sort logs
    final sortedLogs = List<Log>.from(logs)..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    // Determine Time Window
    DateTime startTime;
    DateTime endTime;

    if (now != null) {
      // Daily Mode
      startTime = DateTime(now.year, now.month, now.day); // Midnight today
      endTime = now;
    } else {
      // Global Mode
      if (logs.length < 2) return {'rate': '0.00', 'interval': 'N/A'};
      final firstLog = sortedLogs.first;
      startTime = DateTime(firstLog.timestamp.year, firstLog.timestamp.month, firstLog.timestamp.day);
      endTime = sortedLogs.last.timestamp;
    }

    double hoursDiff = endTime.difference(startTime).inMinutes / 60.0;
    
    // Prevent division by zero or tiny intervals
    if (hoursDiff < 0.01) hoursDiff = 0.01;
    if (now == null && hoursDiff < 1) hoursDiff = 1; // Global min 1 hour

    final rate = (logs.length / hoursDiff).toStringAsFixed(2);

    // Interval Calculation
    final avgHours = hoursDiff / logs.length;
    final h = avgHours.floor();
    final m = ((avgHours - h) * 60).round();

    return {'rate': rate, 'interval': '${h}h ${m}m'};
  }

  static String formatInterval(Duration diff) {
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    return "${h}h ${m}m";
  }
}
