import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/log.dart';
import '../../data/services/storage_service.dart';

part 'log_event.dart';
part 'log_state.dart';

class LogBloc extends Bloc<LogEvent, LogState> {
  final StorageService _storageService;
  Timer? _timer;

  LogBloc({required StorageService storageService})
      : _storageService = storageService,
        super(LogState(now: DateTime.now())) {
    on<LoadLogs>(_onLoadLogs);
    on<AddLog>(_onAddLog);
    on<UpdateLog>(_onUpdateLog);
    on<DeleteLog>(_onDeleteLog);
    on<ClearAllLogs>(_onClearAllLogs);
    on<UpdateTime>(_onUpdateTime);

    add(LoadLogs());
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      add(UpdateTime());
    });
  }

  Future<void> _onLoadLogs(LoadLogs event, Emitter<LogState> emit) async {
    emit(state.copyWith(status: LogStatus.loading));
    try {
      final logs = await _storageService.loadLogs();
      emit(state.copyWith(status: LogStatus.success, logs: logs));
    } catch (_) {
      emit(state.copyWith(status: LogStatus.failure));
    }
  }

  Future<void> _onAddLog(AddLog event, Emitter<LogState> emit) async {
    final newLog = Log(
      id: DateTime.now().millisecondsSinceEpoch,
      timestamp: DateTime.now(),
      urineColor: event.color,
      urineAmount: event.amount,
    );
    final updatedLogs = List<Log>.from(state.logs)..insert(0, newLog);
    emit(state.copyWith(logs: updatedLogs));
    await _storageService.saveLogs(updatedLogs);
  }

  Future<void> _onUpdateLog(UpdateLog event, Emitter<LogState> emit) async {
    final updatedLogs = state.logs.map((log) => log.id == event.log.id ? event.log : log).toList();
    emit(state.copyWith(logs: updatedLogs));
    await _storageService.saveLogs(updatedLogs);
  }

  Future<void> _onDeleteLog(DeleteLog event, Emitter<LogState> emit) async {
    final updatedLogs = state.logs.where((log) => log.id != event.id).toList();
    emit(state.copyWith(logs: updatedLogs));
    await _storageService.saveLogs(updatedLogs);
  }

  Future<void> _onClearAllLogs(ClearAllLogs event, Emitter<LogState> emit) async {
    emit(state.copyWith(logs: []));
    await _storageService.saveLogs([]);
  }

  void _onUpdateTime(UpdateTime event, Emitter<LogState> emit) {
    emit(state.copyWith(now: DateTime.now()));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
