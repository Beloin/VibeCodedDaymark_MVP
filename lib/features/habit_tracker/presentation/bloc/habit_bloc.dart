import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daymark/features/habit_tracker/domain/entities/habit.dart';
import 'package:daymark/features/habit_tracker/domain/entities/habit_entry.dart';
import 'package:daymark/features/habit_tracker/domain/usecases/get_habits.dart';
import 'package:daymark/features/habit_tracker/domain/usecases/get_today_entries.dart';
import 'package:daymark/features/habit_tracker/domain/usecases/get_date_entries.dart';
import 'package:daymark/features/habit_tracker/domain/usecases/mark_habit_for_date.dart';
import 'package:daymark/features/habit_tracker/domain/usecases/create_habit.dart';
import 'package:daymark/features/habit_tracker/domain/usecases/delete_habit.dart';
import 'package:daymark/app/shared/utils/logger.dart';

part 'habit_event.dart';
part 'habit_state.dart';

/// BLoC for managing habit tracking state
class HabitBloc extends Bloc<HabitEvent, HabitState> {
  final GetHabits getHabits;
  final GetTodayEntries getTodayEntries;
  final GetDateEntries getDateEntries;
  final MarkHabitForDate markHabitForDate;
  final CreateHabitUseCase createHabit;
  final DeleteHabitUseCase deleteHabit;

  // Debouncing mechanism to prevent concurrent operations
  final Map<String, DateTime> _lastOperationTime = {};
  final Duration _debounceDuration = const Duration(milliseconds: 500);
  final Set<String> _ongoingOperations = {};
  
  // Timeout protection
  final Duration _operationTimeout = const Duration(seconds: 10);

  HabitBloc({
    required this.getHabits,
    required this.getTodayEntries,
    required this.getDateEntries,
    required this.markHabitForDate,
    required this.createHabit,
    required this.deleteHabit,
  }) : super(HabitInitial()) {
    on<LoadHabits>(_onLoadHabits);
    on<LoadTodayEntries>(_onLoadTodayEntries);
    on<LoadDateEntries>(_onLoadDateEntries);
    on<MarkHabitCompleted>(_onMarkHabitCompleted);
    on<CreateHabit>(_onCreateHabit);
    on<DeleteHabit>(_onDeleteHabit);
  }

  /// Check if an operation should be debounced
  bool _shouldDebounceOperation(String operationKey) {
    final now = DateTime.now();
    final lastTime = _lastOperationTime[operationKey];
    
    if (lastTime != null) {
      final timeSinceLast = now.difference(lastTime);
      if (timeSinceLast < _debounceDuration) {
        AppLogger.i('Debouncing operation: $operationKey (last: $lastTime, now: $now)', tag: 'HabitBloc');
        return true;
      }
    }
    
    _lastOperationTime[operationKey] = now;
    return false;
  }

  /// Check if an operation is already in progress
  bool _isOperationInProgress(String operationKey) {
    return _ongoingOperations.contains(operationKey);
  }

  /// Start tracking an operation
  void _startOperation(String operationKey) {
    _ongoingOperations.add(operationKey);
  }

  /// Stop tracking an operation
  void _stopOperation(String operationKey) {
    _ongoingOperations.remove(operationKey);
  }

  /// Execute an operation with timeout protection
  Future<T> _executeWithTimeout<T>(
    Future<T> Function() operation,
    String operationName,
    String operationKey,
  ) async {
    try {
      final result = await operation().timeout(_operationTimeout);
      AppLogger.i('$operationName completed successfully', tag: 'HabitBloc');
      return result;
    } on TimeoutException {
      AppLogger.e(
        '$operationName timed out after ${_operationTimeout.inSeconds} seconds', 
        tag: 'HabitBloc',
        error: 'Operation timeout',
        stackTrace: StackTrace.current,
      );
      throw TimeoutException('$operationName timed out');
    } catch (e) {
      AppLogger.e(
        '$operationName failed', 
        tag: 'HabitBloc',
        error: e.toString(),
        stackTrace: StackTrace.current,
      );
      rethrow;
    } finally {
      _stopOperation(operationKey);
    }
  }

  Future<void> _onLoadHabits(LoadHabits event, Emitter<HabitState> emit) async {
    AppLogger.i('Loading habits', tag: 'HabitBloc');
    
    // Update loading state based on current state
    if (state is HabitLoaded) {
      final currentState = state as HabitLoaded;
      emit(currentState.copyWith(isRefreshing: true));
    } else {
      emit(HabitLoading(isRefreshing: true));
    }
    
    try {
      final result = await _executeWithTimeout(
        () => getHabits(),
        'Load habits',
        'load_habits',
      );
      
      await result.when(
        success: (habits) async {
          AppLogger.i('Successfully loaded ${habits.length} habits', tag: 'HabitBloc');
          
          // Load today's entries with timeout protection
          try {
            final todayEntriesResult = await getTodayEntries().timeout(const Duration(seconds: 5));
            todayEntriesResult.when(
              success: (entries) {
                AppLogger.i('Successfully loaded ${entries.length} today\'s entries', tag: 'HabitBloc');
                emit(HabitLoaded(
                  habits: habits, 
                  selectedDateEntries: entries,
                  selectedDate: DateTime.now(),
                ));
              },
              failure: (error) {
                AppLogger.e(
                  'Failed to load today\'s entries, using empty entries', 
                  tag: 'HabitBloc', 
                  error: error.toString(),
                  stackTrace: StackTrace.current,
                );
                // Emit state with empty entries but don't fail completely
                emit(HabitLoaded(
                  habits: habits, 
                  selectedDateEntries: const [],
                  selectedDate: DateTime.now(),
                  isRefreshing: false,
                ));
              },
            );
          } on TimeoutException {
            AppLogger.e(
              'Timeout loading today\'s entries, using empty entries', 
              tag: 'HabitBloc', 
              error: 'Timeout',
              stackTrace: StackTrace.current,
            );
            // Emit state with empty entries but don't fail completely
            emit(HabitLoaded(
              habits: habits, 
              selectedDateEntries: const [],
              selectedDate: DateTime.now(),
              isRefreshing: false,
            ));
          }
        },
        failure: (error) {
          AppLogger.e(
            'Failed to load habits', 
            tag: 'HabitBloc', 
            error: error.toString(),
            stackTrace: StackTrace.current,
          );
          emit(HabitError(message: error.toString()));
        },
      );
    } on TimeoutException {
      emit(HabitError(message: 'Failed to load habits: Operation timed out'));
    }
  }

  Future<void> _onLoadTodayEntries(LoadTodayEntries event, Emitter<HabitState> emit) async {
    if (state is HabitLoaded) {
      AppLogger.i('Loading today\'s entries', tag: 'HabitBloc');
      final currentState = state as HabitLoaded;
      
      final result = await getTodayEntries();
      result.when(
        success: (entries) {
          AppLogger.i('Successfully loaded ${entries.length} today\'s entries', tag: 'HabitBloc');
          emit(currentState.copyWith(
            selectedDateEntries: entries,
            isRefreshing: false,
          ));
        },
        failure: (error) {
          AppLogger.e(
            'Failed to load today\'s entries', 
            tag: 'HabitBloc', 
            error: error.toString(),
            stackTrace: StackTrace.current,
          );
          // Don't emit error state, just keep the current state with empty entries
          emit(currentState.copyWith(
            selectedDateEntries: const [],
            isRefreshing: false,
          ));
        },
      );
    }
  }

  Future<void> _onLoadDateEntries(LoadDateEntries event, Emitter<HabitState> emit) async {
    if (state is HabitLoaded) {
      AppLogger.i('Loading entries for date: ${event.date}', tag: 'HabitBloc');
      final currentState = state as HabitLoaded;
      
      final result = await getDateEntries(event.date);
      result.when(
        success: (entries) {
          AppLogger.i('Successfully loaded ${entries.length} entries for date', tag: 'HabitBloc');
          emit(currentState.copyWith(
            selectedDateEntries: entries,
            selectedDate: event.date,
            isMarkingCompletion: false,
          ));
        },
        failure: (error) {
          AppLogger.e(
            'Failed to load date entries', 
            tag: 'HabitBloc', 
            error: error.toString(),
            stackTrace: StackTrace.current,
          );
          // Don't emit error state, just keep the current state with empty entries
          emit(currentState.copyWith(
            selectedDateEntries: const [],
            selectedDate: event.date,
            isMarkingCompletion: false,
          ));
        },
      );
    }
  }

  Future<void> _onMarkHabitCompleted(MarkHabitCompleted event, Emitter<HabitState> emit) async {
    if (state is HabitLoaded) {
      final operationKey = 'mark_${event.habitId}_${event.date.toIso8601String()}';
      
      // Check for debouncing and concurrent operations
      if (_shouldDebounceOperation(operationKey) || _isOperationInProgress(operationKey)) {
        AppLogger.i('Skipping duplicate/concurrent habit completion operation: $operationKey', tag: 'HabitBloc');
        return;
      }

      AppLogger.i(
        'Marking habit completion: habitId=${event.habitId}, isCompleted=${event.isCompleted}, date=${event.date}', 
        tag: 'HabitBloc',
      );
      
      final currentState = state as HabitLoaded;
      _startOperation(operationKey);
      emit(currentState.copyWith(isMarkingCompletion: true, loadingHabitId: event.habitId));
      
      try {
        final result = await _executeWithTimeout(
          () => markHabitForDate(event.habitId, event.isCompleted, event.date),
          'Mark habit completion',
          operationKey,
        );
        
        result.when(
          success: (_) {
            AppLogger.i('Successfully marked habit completion', tag: 'HabitBloc');
            // Reload entries for the current selected date to reflect the change
            add(LoadDateEntries(date: currentState.selectedDate));
          },
          failure: (error) {
            AppLogger.e(
              'Failed to mark habit completion', 
              tag: 'HabitBloc', 
              error: error.toString(),
              stackTrace: StackTrace.current,
            );
            emit(HabitError(message: error.toString()));
          },
        );
      } on TimeoutException {
        emit(HabitError(message: 'Failed to update habit: Operation timed out'));
      }
    }
  }

  Future<void> _onCreateHabit(CreateHabit event, Emitter<HabitState> emit) async {
    final operationKey = 'create_habit';
    
    // Check for debouncing and concurrent operations
    if (_shouldDebounceOperation(operationKey) || _isOperationInProgress(operationKey)) {
      AppLogger.i('Skipping duplicate/concurrent habit creation operation', tag: 'HabitBloc');
      return;
    }

    AppLogger.i(
      'Creating new habit: ${event.habit.name}', 
      tag: 'HabitBloc',
    );
    
    // Update loading state based on current state
    if (state is HabitLoaded) {
      final currentState = state as HabitLoaded;
      _startOperation(operationKey);
      emit(currentState.copyWith(isCreating: true));
    } else {
      _startOperation(operationKey);
      emit(HabitLoading(isCreating: true));
    }
    
    try {
      final result = await _executeWithTimeout(
        () => createHabit(event.habit),
        'Create habit',
        operationKey,
      );
      
      result.when(
        success: (_) {
          AppLogger.i('Successfully created habit', tag: 'HabitBloc');
          // Reload habits to include the new one
          add(const LoadHabits());
        },
        failure: (error) {
          AppLogger.e(
            'Failed to create habit', 
            tag: 'HabitBloc', 
            error: error.toString(),
            stackTrace: StackTrace.current,
          );
          emit(HabitError(message: error.toString()));
        },
      );
    } on TimeoutException {
      emit(HabitError(message: 'Failed to create habit: Operation timed out'));
    }
  }

  Future<void> _onDeleteHabit(DeleteHabit event, Emitter<HabitState> emit) async {
    if (state is HabitLoaded) {
      final operationKey = 'delete_${event.habitId}';
      
      // Check for debouncing and concurrent operations
      if (_shouldDebounceOperation(operationKey) || _isOperationInProgress(operationKey)) {
        AppLogger.i('Skipping duplicate/concurrent habit deletion operation: $operationKey', tag: 'HabitBloc');
        return;
      }

      AppLogger.i(
        'Deleting habit: habitId=${event.habitId}', 
        tag: 'HabitBloc',
      );
      
      final currentState = state as HabitLoaded;
      _startOperation(operationKey);
      emit(currentState.copyWith(isDeleting: true));
      
      try {
        final result = await _executeWithTimeout(
          () => deleteHabit(event.habitId),
          'Delete habit',
          operationKey,
        );
        
        result.when(
          success: (_) {
            AppLogger.i('Successfully deleted habit', tag: 'HabitBloc');
            // Reload habits to reflect the deletion
            add(const LoadHabits());
          },
          failure: (error) {
            AppLogger.e(
              'Failed to delete habit', 
              tag: 'HabitBloc', 
              error: error.toString(),
              stackTrace: StackTrace.current,
            );
            emit(HabitError(message: error.toString()));
          },
        );
      } on TimeoutException {
        emit(HabitError(message: 'Failed to delete habit: Operation timed out'));
      }
    }
  }
}
