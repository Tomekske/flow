import 'package:flow/data/models/drink_log_entry.dart';
import 'package:flow/data/models/log_entry.dart';
import 'package:flow/data/models/urination_stats.dart';
import 'package:flow/data/models/urine_log_entry.dart';

import '../data/models/drinking_stats.dart';

class StatsHelper {
  static UrinationStats getUrinationStats(
    List<UrineLogEntry> logs, {
    DateTime? now,
  }) {
    if (logs.isEmpty) {
      return UrinationStats(total: 0, frequency: "N/A", lastVisit: null);
    }

    // Sort logs (Generic helper)
    final sortedLogs = sortLogs(logs);

    // Calculate Frequency (Events per Hour)
    final double frequencyPerHour = calculateFrequencyPerHour(
      sortedLogs,
      now ?? DateTime.now(),
    );

    // Convert Frequency (f) to Time Interval (T = 1/f)
    final frequencyString = calculateTimeFromFrequency(frequencyPerHour);

    // Get last visit
    final lastVisit =
        sortedLogs.last.createdAt; // .last because we sort ascending

    return UrinationStats(
      total: sortedLogs.length,
      frequency: frequencyString,
      lastVisit: lastVisit,
    );
  }

  // ---------------------------------------------------------------------------
  // DRINKING STATS
  // ---------------------------------------------------------------------------
  static DrinkingStats getDrinkingStats(
    List<DrinkLogEntry> logs, {
    DateTime? now,
  }) {
    if (logs.isEmpty) {
      return DrinkingStats(total: 0, frequency: "N/A", lastConsumption: null);
    }

    final sortedLogs = sortLogs(logs);

    final double frequencyPerHour = calculateFrequencyPerHour(
      sortedLogs,
      now ?? DateTime.now(),
    );

    final frequencyString = calculateTimeFromFrequency(frequencyPerHour);
    final lastConsumption = sortedLogs.last.createdAt;

    // Calculate total volume
    final totalVolume = sortedLogs.fold(
      0,
      (sum, log) => sum + log.volume.toInt(),
    );
    final totalVolumeInLiters = totalVolume.toDouble() / 1000.0;

    return DrinkingStats(
      total: totalVolumeInLiters,
      frequency: frequencyString,
      lastConsumption: lastConsumption,
    );
  }

  /// Sorts any list of LogEntries by createdAt (Oldest -> Newest)
  static List<T> sortLogs<T extends LogEntry>(List<T> logs) {
    return List<T>.from(logs)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  /// Calculates "Visits per Hour" based on the bucket logic provided.
  /// (Renamed from calculateAverageInterval to reflect what it actually calculates)
  static double calculateFrequencyPerHour(
    List<LogEntry> sortedLogs,
    DateTime now,
  ) {
    if (sortedLogs.isEmpty) return 0.0;

    // Initialize map of 24 hours
    final intervalMap = {
      for (int i = 1; i <= 24; i++) i: <DateTime>[],
    };

    // Distribute logs into hourly buckets
    for (var log in sortedLogs) {
      var interval = getInterval(log.createdAt);
      intervalMap[interval]?.add(log.createdAt);
    }

    int currentHourIndex = getInterval(now);

    // Filter buckets up to the current hour
    var validBuckets = Map.fromEntries(
      intervalMap.entries
          .where((entry) => entry.key <= currentHourIndex)
          .map((entry) => MapEntry(entry.key, entry.value.length)),
    );

    // Sum total events so far today
    double totalEvents = validBuckets.values
        .fold(0, (prev, count) => prev + count)
        .toDouble();

    // Result = Total Events / Hours Elapsed
    // Example: 4 visits in 2 hours = 2 visits/hour
    if (currentHourIndex == 0) return 0.0;

    return totalEvents / currentHourIndex;
  }

  /// Converts Frequency (1/h) into a readable Time String (e.g., "2h 30m")
  /// Logic: T = 1 / f
  static String calculateTimeFromFrequency(double frequencyPerHour) {
    if (frequencyPerHour <= 0.0001) {
      return "N/A";
    }

    // T = 1 / f
    // Example: 0.5 visits/hour -> 1 / 0.5 = 2.0 hours per visit
    double totalHours = 1 / frequencyPerHour;

    if (totalHours.isInfinite || totalHours.isNaN) {
      return "N/A";
    }

    // Cap ridiculous values (e.g. if you just woke up and logged 1 entry)
    if (totalHours > 24) return "24h+";

    int hours = totalHours.truncate();
    double minutesDecimal = (totalHours - hours) * 60;
    int minutes = minutesDecimal.round();

    if (minutes == 60) {
      hours += 1;
      minutes = 0;
    }

    if (hours == 0) {
      return "${minutes}m";
    }

    if (minutes == 0) {
      return "${hours}h";
    }

    return "${hours}h ${minutes}m";
  }

  static final Map<int, int> _hourToIntervalMap = {
    for (int i = 0; i < 24; i++) i: i + 1,
  };

  /// Returns 1-24 based on the hour 0-23
  static int getInterval(DateTime time) {
    final int hourKey = time.hour;
    return _hourToIntervalMap[hourKey] ?? 1;
  }
}
