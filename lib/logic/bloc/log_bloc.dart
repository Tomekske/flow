import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/enums/urine_color.dart';
import '../../data/models/urine_log.dart';
import '../../data/models/drink_log.dart';
import '../../data/services/storage_service.dart';

part 'log_event.dart';
part 'log_state.dart';

class LogBloc extends Bloc<LogEvent, LogState> {
  final StorageService _storageService;
  Timer? _timer;

  LogBloc({required StorageService storageService})
    : _storageService = storageService,
      super(LogState(now: DateTime.now())) {
    on<LoadData>(_onLoadData);
    on<AddUrineLogEvent>(_onAddUrineLog);
    on<AddDrinkLogEvent>(_onAddDrinkLog);
    on<UpdateUrineLogEvent>(_onUpdateUrineLog);
    on<UpdateDrinkLogEvent>(_onUpdateDrinkLog);
    on<DeleteUrineLog>(_onDeleteUrineLog);
    on<DeleteDrinkLog>(_onDeleteDrinkLog);
    on<UpdateSettings>(_onUpdateSettings);
    on<UpdateTime>(_onUpdateTime);

    // Initialize the service (auth) then load data
    _initialize();

    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      add(UpdateTime());
    });
  }

  Future<void> _initialize() async {
    try {
      await _storageService.initialize();
      add(LoadData());
    } catch (e) {
      emit(state.copyWith(status: LogStatus.failure));
      debugPrint("Startup error: $e");
    }
  }

  Future<void> _onUpdateUrineLog(
    UpdateUrineLogEvent event,
    Emitter<LogState> emit,
  ) async {
    try {
      await _storageService.updateUrineLog(event.log);
      add(LoadData());
    } catch (e) {
      debugPrint('Failed to update urine log: $e');
      emit(state.copyWith(status: LogStatus.failure));
    }
  }

  Future<void> _onUpdateDrinkLog(
    UpdateDrinkLogEvent event,
    Emitter<LogState> emit,
  ) async {
    try {
      await _storageService.updateDrinkLog(event.log);
      add(LoadData());
    } catch (e) {
      debugPrint('Failed to update drink log: $e');
      emit(state.copyWith(status: LogStatus.failure));
    }
  }

  Future<void> _onLoadData(LoadData event, Emitter<LogState> emit) async {
    emit(state.copyWith(status: LogStatus.loading));
    try {
      // Fetch both lists
      final urineLogs = await _storageService.loadUrineLogs();
      final drinkLogs = await _storageService.loadDrinkLogs();
      final settings = await _storageService.loadSettings();

      emit(
        state.copyWith(
          status: LogStatus.success,
          urineLogs: urineLogs,
          drinkLogs: drinkLogs,
          theme: settings['theme'],
          dailyGoal: settings['drinking_goal'],
        ),
      );
    } catch (e) {
      debugPrint('Failed to load data: $e');
      emit(state.copyWith(status: LogStatus.failure));
    }
  }

  Future<void> _onAddUrineLog(
    AddUrineLogEvent event,
    Emitter<LogState> emit,
  ) async {
    try {
      if (event.color == null || event.amount == null) {
        emit(state.copyWith(status: LogStatus.failure));
        return;
      }
      final newLog = UrineLog(
        id: 0,
        createdAt: DateTime.now(),
        color: event.color!,
        amount: event.amount!,
      );

      await _storageService.addUrineLog(newLog);

      // Reload to get the correct ID and sorted list from DB
      add(LoadData());
    } catch (e) {
      debugPrint('Failed to add an urine log: $e');
      emit(state.copyWith(status: LogStatus.failure));
    }
  }

  Future<void> _onAddDrinkLog(
    AddDrinkLogEvent event,
    Emitter<LogState> emit,
  ) async {
    try {
      final newLog = DrinkLog(
        id: 0,
        createdAt: DateTime.now(),
        fluidType: event.fluidType,
        volume: event.volume,
      );

      await _storageService.addDrinkLog(newLog);
      add(LoadData());
    } catch (e) {
      debugPrint('Failed to add a drink log: $e');
      emit(state.copyWith(status: LogStatus.failure));
    }
  }

  Future<void> _onDeleteUrineLog(
    DeleteUrineLog event,
    Emitter<LogState> emit,
  ) async {
    try {
      await _storageService.deleteUrineLog(event.id);
      add(LoadData());
    } catch (e) {
      debugPrint('Failed to delete an urine log: $e');
      emit(state.copyWith(status: LogStatus.failure));
    }
  }

  Future<void> _onDeleteDrinkLog(
    DeleteDrinkLog event,
    Emitter<LogState> emit,
  ) async {
    try {
      await _storageService.deleteDrinkLog(event.id);
      add(LoadData());
    } catch (e) {
      debugPrint('Failed to delete a drink log: $e');
      emit(state.copyWith(status: LogStatus.failure));
    }
  }

  Future<void> _onUpdateSettings(
    UpdateSettings event,
    Emitter<LogState> emit,
  ) async {
    final previousTheme = state.theme;
    final previousGoal = state.dailyGoal;
    final newTheme = event.theme ?? state.theme;
    final newGoal = event.drinkingGoal ?? state.dailyGoal;

    emit(state.copyWith(theme: newTheme, dailyGoal: newGoal));

    try {
      await _storageService.saveSettings({
        'theme': newTheme,
        'drinking_goal': newGoal,
      });
    } catch (e) {
      debugPrint('Failed to update settings: $e');
      emit(
        state.copyWith(
          status: LogStatus.failure,
          theme: previousTheme,
          dailyGoal: previousGoal,
        ),
      );
    }
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
