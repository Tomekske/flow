part of 'log_bloc.dart';

enum LogStatus { initial, loading, success, failure }

class LogState extends Equatable {
  // Separate lists for urine and drink logs, each sorted by date
  final List<UrineLog> urineLogs;
  final List<DrinkLog> drinkLogs;
  final DateTime now;
  final LogStatus status;
  final String theme; // 'light' or 'dark'
  final double dailyGoal; // in Liters

  const LogState({
    this.urineLogs = const [],
    this.drinkLogs = const [],
    required this.now,
    this.status = LogStatus.initial,
    this.theme = 'light',
    this.dailyGoal = 2.0,
  });

  LogState copyWith({
    List<UrineLog>? urineLogs,
    List<DrinkLog>? drinkLogs,
    DateTime? now,
    LogStatus? status,
    String? theme,
    double? dailyGoal,
  }) {
    return LogState(
      urineLogs: urineLogs ?? this.urineLogs,
      drinkLogs: drinkLogs ?? this.drinkLogs,
      now: now ?? this.now,
      status: status ?? this.status,
      theme: theme ?? this.theme,
      dailyGoal: dailyGoal ?? this.dailyGoal,
    );
  }

  @override
  List<Object?> get props => [
    urineLogs,
    drinkLogs,
    now,
    status,
    theme,
    dailyGoal,
  ];
}
