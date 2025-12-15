part of 'log_bloc.dart';

enum LogStatus { initial, loading, success, failure }

class LogState extends Equatable {
  final List<Log> logs;
  final DateTime now;
  final LogStatus status;
  final String theme; // 'light' or 'dark'
  final double dailyGoal; // in Liters

  const LogState({
    this.logs = const [],
    required this.now,
    this.status = LogStatus.initial,
    this.theme = 'light',
    this.dailyGoal = 2.0,
  });

  LogState copyWith({
    List<Log>? logs,
    DateTime? now,
    LogStatus? status,
    String? theme,
    double? dailyGoal,
  }) {
    return LogState(
      logs: logs ?? this.logs,
      now: now ?? this.now,
      status: status ?? this.status,
      theme: theme ?? this.theme,
      dailyGoal: dailyGoal ?? this.dailyGoal,
    );
  }

  @override
  List<Object> get props => [logs, now, status, theme, dailyGoal];
}
