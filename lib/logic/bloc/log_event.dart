part of 'log_bloc.dart';

abstract class LogEvent extends Equatable {
  const LogEvent();
  @override
  List<Object> get props => [];
}

class LoadLogs extends LogEvent {}

// Add Toilet Log
class AddToiletLog extends LogEvent {
  final int? color;
  final String? amount;
  const AddToiletLog({this.color, this.amount});
  @override
  List<Object> get props => [color ?? 0, amount ?? ''];
}

// Add Fluid Log
class AddFluidLog extends LogEvent {
  final String fluidType;
  final int volume;
  const AddFluidLog({required this.fluidType, required this.volume});
  @override
  List<Object> get props => [fluidType, volume];
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
