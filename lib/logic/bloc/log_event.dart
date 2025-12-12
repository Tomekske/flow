part of 'log_bloc.dart';

abstract class LogEvent extends Equatable {
  const LogEvent();

  @override
  List<Object> get props => [];
}

class LoadLogs extends LogEvent {}

class AddLog extends LogEvent {}

class DeleteLog extends LogEvent {
  final int id;
  const DeleteLog(this.id);

  @override
  List<Object> get props => [id];
}

class ClearAllLogs extends LogEvent {}

class UpdateTime extends LogEvent {}
