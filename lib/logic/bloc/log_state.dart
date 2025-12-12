part of 'log_bloc.dart';

enum LogStatus { initial, loading, success, failure }

class LogState extends Equatable {
  final List<Log> logs;
  final DateTime now;
  final LogStatus status;

  const LogState({
    this.logs = const [],
    required this.now,
    this.status = LogStatus.initial,
  });

  LogState copyWith({
    List<Log>? logs,
    DateTime? now,
    LogStatus? status,
  }) {
    return LogState(
      logs: logs ?? this.logs,
      now: now ?? this.now,
      status: status ?? this.status,
    );
  }

  @override
  List<Object> get props => [logs, now, status];
}
