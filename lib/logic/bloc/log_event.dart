part of 'log_bloc.dart';

abstract class LogEvent extends Equatable {
  const LogEvent();
  @override
  List<Object> get props => [];
}

class LoadLogs extends LogEvent {}

class AddLog extends LogEvent {
  final int? color;
  final String? amount;
  const AddLog({this.color, this.amount});
  @override
  List<Object> get props => [color ?? 0, amount ?? ''];
}

class UpdateLog extends LogEvent {
  final Log log;
  const UpdateLog(this.log);
  @override
  List<Object> get props => [log];
}

class DeleteLog extends LogEvent {
  final int id;
  const DeleteLog(this.id);
  @override
  List<Object> get props => [id];
}

class ClearAllLogs extends LogEvent {}
class UpdateTime extends LogEvent {}
