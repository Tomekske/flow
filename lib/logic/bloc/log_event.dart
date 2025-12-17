part of 'log_bloc.dart';

abstract class LogEvent extends Equatable {
  const LogEvent();
  @override
  List<Object?> get props => [];
}

class LoadData extends LogEvent {}

class AddUrineLogEvent extends LogEvent {
  final UrineColor? color;
  final String? amount;
  const AddUrineLogEvent({this.color, this.amount});
  @override
  List<Object?> get props => [color, amount];
}

class AddDrinkLogEvent extends LogEvent {
  final String fluidType;
  final int volume;
  const AddDrinkLogEvent({required this.fluidType, required this.volume});
  @override
  List<Object> get props => [fluidType, volume];
}

class UpdateUrineLogEvent extends LogEvent {
  final UrineLog log;
  const UpdateUrineLogEvent(this.log);
  @override
  List<Object> get props => [log];
}

class UpdateDrinkLogEvent extends LogEvent {
  final DrinkLog log;
  const UpdateDrinkLogEvent(this.log);
  @override
  List<Object> get props => [log];
}

class DeleteUrineLog extends LogEvent {
  final int id;
  const DeleteUrineLog(this.id);
  @override
  List<Object> get props => [id];
}

class DeleteDrinkLog extends LogEvent {
  final int id;
  const DeleteDrinkLog(this.id);
  @override
  List<Object> get props => [id];
}

class UpdateSettings extends LogEvent {
  final String? theme;
  final double? drinkingGoal;
  const UpdateSettings({this.theme, this.drinkingGoal});
  @override
  List<Object?> get props => [theme, drinkingGoal];
}

class UpdateTime extends LogEvent {}
