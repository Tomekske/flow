import 'package:flow/data/models/urine_log.dart';

class StatsHelper {
  /// Main entry point: Calculates Rate (visits/hr) and Avg Interval string
  static Map<String, String> calculateStats(
    List<UrineLog> logs, {
    DateTime? now,
  }) {
    if (logs.isEmpty) {
      return {'rate': '0.00', 'interval': 'No logs'};
    }

    // 1. Prepare Data
    final sortedLogs = sortLogs(logs);

    // 2. Calculate Rate (Visits per Hour)
    final double rate = calculateHourlyRate(sortedLogs, now);

    // 3. Calculate Interval (Moving Average of time between visits)
    final double avgInterval = calculateAverageInterval(
      sortedLogs,
      now ?? DateTime.now(),
    );

    // 4. Format Output
    return {
      'rate': rate.toStringAsFixed(2),
      'interval': avgInterval.toStringAsFixed(2),
    };
  }

  static List<UrineLog> sortLogs(List<UrineLog> logs) {
    return List<UrineLog>.from(logs)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  /// Calculates visits per hour based on the specific time window
  static double calculateHourlyRate(List<UrineLog> sortedLogs, DateTime? now) {
    DateTime startTime;
    DateTime endTime;

    if (now != null) {
      // Daily Mode: Rate is based on time elapsed since midnight today
      startTime = DateTime(now.year, now.month, now.day);
      endTime = now;
    } else {
      // Global Mode: Rate is based on time between first and last log
      if (sortedLogs.length < 2) return 0.0;

      final firstLog = sortedLogs.first;
      // Option: Start from the very first log timestamp
      startTime = firstLog.createdAt;
      endTime = sortedLogs.last.createdAt;
    }

    double hoursDiff = endTime.difference(startTime).inMinutes / 60.0;

    // Guard rails for division
    if (hoursDiff < 0.01) hoursDiff = 0.01;
    if (now == null && hoursDiff < 1) {
      // Minimum 1 hour window for global stats
      hoursDiff = 1;
    }

    return sortedLogs.length / hoursDiff;
  }

  /// Calculates the "Moving Average" (Mean Inter-arrival Time).
  /// This measures the average duration between consecutive logs.
  static double calculateAverageInterval(
    List<UrineLog> sortedLogs,
    DateTime now,
  ) {
    if (sortedLogs.isEmpty) {
      return 0.0;
    }

    final intervalMap = {
      for (int i = 1; i <= 24; i++) i: <DateTime>[],
    };

    for (var log in sortedLogs) {
      var interval = getInterval(log.createdAt);

      intervalMap[interval]?.add(log.createdAt);
    }

    int currentInterval = getInterval(now);

    var x = Map.fromEntries(
      intervalMap.entries
          // 1. Filter: Keep only keys less than or equal to currentInterval
          .where((entry) => entry.key <= currentInterval)
          // 2. Map: Convert the list to its length
          .map((entry) => MapEntry(entry.key, entry.value.length)),
    );

    // Start at 0, add each 'element' to the 'previousValue'
    double sum = x.values
        .fold(0, (previousValue, element) => previousValue + element)
        .toDouble();

    return sum / currentInterval;
  }

  static String formatInterval(Duration diff) {
    if (diff == Duration.zero) return "N/A";

    final h = diff.inHours;
    final m = diff.inMinutes % 60;

    // Optional: Return minutes only if less than an hour for cleaner UI
    if (h == 0) return "${m}m";

    return "${h}h ${m}m";
  }

  // 1. Create the HashMap
  // We generate it dynamically to avoid typing 24 lines manually.
  // Key (int): The hour (0 to 23)
  // Value (int): The interval ID (1 to 24)
  static final Map<int, int> _hourToIntervalMap = {
    for (int i = 0; i < 24; i++) i: i + 1,
  };

  /// Looks up the interval for a given DateTime
  static int getInterval(DateTime time) {
    // Extract the hour (0-23) to use as the lookup key
    final int hourKey = time.hour;

    // Return the mapped interval (or 0 if something goes wrong)
    return _hourToIntervalMap[hourKey] ?? 0;
  }
}
