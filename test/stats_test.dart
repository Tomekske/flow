import 'package:flow/data/models/log.dart';
import 'package:flow/helpers/stats_helper.dart';
import 'package:test/test.dart';
// TODO: Import your actual stats_helper.dart and log.dart files
// import 'package:your_app/utils/stats_helper.dart';
// import 'package:your_app/data/models/log.dart';

// ------------------------------------------------
// ----------------------------------------------------------------------

void main() {
  group('IntervalHelper Mapping Tests', () {

    // Helper to make the tests readable
    DateTime time(int h, int m) => DateTime(2023, 1, 1, h, m);

    // ----------------------------------------------------------------
    // BOUNDARY CHECKS
    // ----------------------------------------------------------------

    test('Midnight (00:00) maps to Interval 1', () {
      expect(StatsHelper.getInterval(time(0, 0)), 1);
    });

    test('End of first hour (00:59) still maps to Interval 1', () {
      expect(StatsHelper.getInterval(time(0, 59)), 1);
    });

    test('Start of next hour (01:00) maps to Interval 2', () {
      expect(StatsHelper.getInterval(time(1, 0)), 2);
    });

    test('Last minute of the day (23:59) maps to Interval 24', () {
      expect(StatsHelper.getInterval(time(23, 59)), 24);
    });

    // ----------------------------------------------------------------
    // RANDOM CHECKS (Based on your image rows)
    // ----------------------------------------------------------------

    test('Morning checks (06:00 - 06:59)', () {
      // Row 7 in your image
      expect(StatsHelper.getInterval(time(6, 0)), 7);
      expect(StatsHelper.getInterval(time(6, 30)), 7);
      expect(StatsHelper.getInterval(time(6, 59)), 7);
    });

    test('Noon checks (12:00 - 12:59)', () {
      // Row 13 in your image
      expect(StatsHelper.getInterval(time(12, 15)), 13);
    });

    test('Evening checks (18:00 - 18:59)', () {
      // Row 19 in your image
      expect(StatsHelper.getInterval(time(18, 45)), 19);
    });

    // ----------------------------------------------------------------
    // ROBUSTNESS
    // ----------------------------------------------------------------

    test('Handles date changes correctly (ignores the day/month)', () {
      // Even if the date is different, 08:00 is always Interval 9
      final nextYear = DateTime(2024, 5, 20, 8, 0);
      expect(StatsHelper.getInterval(nextYear), 9);
    });
  });

  // group('StatsHelper.calculateHourlyRate', () {
  //   // Helper to create dates easily (Year, Month, Day, Hour, Minute)
  //   DateTime time(int h, int m) => DateTime(2023, 1, 1, h, m);
  //
  //   // =================================================================
  //   // MODE A: DAILY (now != null)
  //   // Logic: Window starts at Midnight (00:00) and ends at 'now'
  //   // =================================================================
  //
  //   test('Daily Mode: Calculates rate based on hours elapsed since midnight', () {
  //     // Scenario: It is Noon (12:00). We have 6 logs.
  //     // Window: 12 hours.
  //     // Expected: 6 logs / 12 hours = 0.5 logs/hr.
  //
  //     final List<Log> logs = [
  //       Log(timestamp: time(9, 0), id: 1),
  //       Log(timestamp: time(10, 0), id: 2),
  //       Log(timestamp: time(11, 0), id: 3),
  //       Log(timestamp: time(11, 15), id: 4),
  //       Log(timestamp: time(11, 30), id: 5),
  //       Log(timestamp: time(11, 45), id: 6),
  //     ];
  //     final now = time(12, 0);
  //
  //     final rate = StatsHelper.calculateHourlyRate(logs, now);
  //
  //     expect(rate, closeTo(0.5, 0.01));
  //   });
  //
  //   test('Daily Mode: Handles "now" being very early in the day (Tiny Window)', () {
  //     // Scenario: It is 00:30 (30 mins into the day). 2 logs.
  //     // Window: 0.5 hours.
  //     // Expected: 2 logs / 0.5 hours = 4.0 logs/hr.
  //
  //     final logs = [
  //       Log(timestamp: time(0, 5), id: 1),
  //       Log(timestamp: time(0, 10), id: 1),
  //     ];
  //     final now = time(0, 30);
  //
  //     final rate = StatsHelper.calculateHourlyRate(logs, now);
  //
  //     expect(rate, closeTo(4.0, 0.01));
  //   });
  //
  //   // =================================================================
  //   // MODE B: GLOBAL (now == null)
  //   // Logic: Window starts at First Log and ends at Last Log
  //   // =================================================================
  //
  //   test('Global Mode: Calculates rate based on time between first and last log', () {
  //     // Scenario: First log at 10:00, Last at 14:00. Total 5 logs.
  //     // Window: 4 hours.
  //     // Expected: 5 logs / 4 hours = 1.25 logs/hr.
  //
  //     final logs = [
  //       Log(timestamp: time(10, 0), id: 1), // Start
  //       Log(timestamp: time(11, 0), id: 1),
  //       Log(timestamp: time(12, 0), id: 1),
  //       Log(timestamp: time(13, 0), id: 1),
  //       Log(timestamp: time(14, 0), id: 1), // End
  //     ];
  //
  //     final rate = StatsHelper.calculateHourlyRate(logs, null);
  //
  //     expect(rate, closeTo(1.25, 0.01));
  //   });
  //
  //   test('Global Mode: Returns 0.0 if fewer than 2 logs', () {
  //     final logs = [Log(timestamp: time(10, 0), id: 1)];
  //
  //     final rate = StatsHelper.calculateHourlyRate(logs, null);
  //
  //     expect(rate, 0.0);
  //   });
  //
  //   test('Global Mode: Enforces minimum 1-hour window (Guard Rail)', () {
  //     // Scenario: 4 logs occur within 30 minutes (10:00 to 10:30).
  //     // Actual Window: 0.5 hours.
  //     // Enforced Window: 1.0 hour (because it's Global mode).
  //     // Expected: 4 logs / 1.0 hour = 4.0 logs/hr.
  //
  //     final logs = [
  //       Log(timestamp: time(10, 0), id: 1),
  //       Log(timestamp: time(10, 10), id: 1),
  //       Log(timestamp: time(10, 20), id: 1),
  //       Log(timestamp: time(10, 30), id: 1),
  //     ];
  //
  //     final rate = StatsHelper.calculateHourlyRate(logs, null);
  //
  //     expect(rate, closeTo(4.0, 0.01));
  //   });
  // });

  group('StatsHelper.calculateHourlyRate', () {
    DateTime time(int h, int m) => DateTime(2023, 1, 1, h, m);

    // test('Returns zero if fewer than 2 logs', () {
    //   final logs = [Log(timestamp: time(10, 0), id: 1,type: 'toilet')];
    //   expect(StatsHelper.calculateHourlyRate(logs), Duration.zero);
    // });

    test('Calculates average time between logs correctly', () {
      final logs = [
        [
          Log(timestamp: time(0, 15), id: 1,type: 'toilet'),
          Log(timestamp: time(0, 30), id: 2,type: 'toilet'),
        ],
        [
          // Interval 1
          Log(timestamp: time(0, 15), id: 1,type: 'toilet'),
          Log(timestamp: time(0, 30), id: 2,type: 'toilet'),

          // Interval 2
          Log(timestamp: time(1, 15), id: 1,type: 'toilet'),
          Log(timestamp: time(1, 30), id: 2,type: 'toilet'),
        ],
        [
          // Interval 1
          Log(timestamp: time(0, 15), id: 1,type: 'toilet'),
          Log(timestamp: time(0, 30), id: 2,type: 'toilet'),

          // Interval 2
          Log(timestamp: time(1, 15), id: 1,type: 'toilet'),
          Log(timestamp: time(1, 30), id: 2,type: 'toilet'),
          Log(timestamp: time(2, 15), id: 3,type: 'toilet'),

          // Interval 3
          Log(timestamp: time(2, 15), id: 1,type: 'toilet'),
        ],
        [
          // Interval 1
          Log(timestamp: time(0, 15), id: 1,type: 'toilet'),
          Log(timestamp: time(0, 30), id: 2,type: 'toilet'),
          Log(timestamp: time(2, 15), id: 1,type: 'toilet'),

          // Interval 2
          Log(timestamp: time(1, 15), id: 1,type: 'toilet'),
          Log(timestamp: time(1, 30), id: 2,type: 'toilet'),
          Log(timestamp: time(2, 15), id: 3,type: 'toilet'),
        ]
      ];



      expect(StatsHelper.calculateAverageInterval(logs[0], time(0, 45)), 2.0);
      expect(StatsHelper.calculateAverageInterval(logs[1], time(1, 45)), 2.0);
      expect(StatsHelper.calculateAverageInterval(logs[2], time(2, 45)), 2.0);
      expect(StatsHelper.calculateAverageInterval(logs[3], time(2, 45)), 2.0);
    });



  });
}