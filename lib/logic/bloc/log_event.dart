part of 'log_bloc.dart';

abstract class LogEvent extends Equatable {
  const LogEvent();
  @override
  List<Object> get props => [];
}

class LoadData extends LogEvent {}

class AddToiletLog extends LogEvent {
  final int? color;
  final String? amount;
  const AddToiletLog({this.color, this.amount});
  @override
  List<Object> get props => [color ?? 0, amount ?? ''];
}

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

class UpdateSettings extends LogEvent {
  final String? theme;
  final double? drinkingGoal;
  const UpdateSettings({this.theme, this.drinkingGoal});
  @override
  List<Object> get props => [theme ?? '', drinkingGoal ?? 0];
}

class UpdateTime extends LogEvent {}
