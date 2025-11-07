import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daymark/features/habit_tracker/domain/entities/habit.dart';
import 'package:daymark/features/habit_tracker/domain/entities/habit_entry.dart';
import 'package:daymark/features/habit_tracker/domain/usecases/get_habits.dart';
import 'package:daymark/features/habit_tracker/domain/usecases/get_today_entries.dart';
import 'package:daymark/features/habit_tracker/domain/usecases/mark_habit_today.dart';
import 'package:daymark/app/shared/utils/logger.dart';

part 'habit_event.dart';
part 'habit_state.dart';

/// BLoC for managing habit tracking state
class HabitBloc extends Bloc<HabitEvent, HabitState> {
  final GetHabits getHabits;
  final GetTodayEntries getTodayEntries;
  final MarkHabitToday markHabitToday;

  HabitBloc({
    required this.getHabits,
    required this.getTodayEntries,
    required this.markHabitToday,
  }) : super(HabitInitial()) {
    on<LoadHabits>(_onLoadHabits);
    on<LoadTodayEntries>(_onLoadTodayEntries);
    on<MarkHabitCompleted>(_onMarkHabitCompleted);
  }

  Future<void> _onLoadHabits(LoadHabits event, Emitter<HabitState> emit) async {
    AppLogger.i('Loading habits', tag: 'HabitBloc');
    emit(HabitLoading());
    
    final result = await getHabits();
    result.when(
      success: (habits) {
        AppLogger.i('Successfully loaded ${habits.length} habits', tag: 'HabitBloc');
        emit(HabitLoaded(habits: habits));
        // Automatically load today's entries after habits are loaded
        add(const LoadTodayEntries());
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
  }

  Future<void> _onLoadTodayEntries(LoadTodayEntries event, Emitter<HabitState> emit) async {
    if (state is HabitLoaded) {
      AppLogger.i('Loading today\'s entries', tag: 'HabitBloc');
      final currentState = state as HabitLoaded;
      
      final result = await getTodayEntries();
      result.when(
        success: (entries) {
          AppLogger.i('Successfully loaded ${entries.length} today\'s entries', tag: 'HabitBloc');
          emit(currentState.copyWith(todayEntries: entries));
        },
        failure: (error) {
          AppLogger.e(
            'Failed to load today\'s entries', 
            tag: 'HabitBloc', 
            error: error.toString(),
            stackTrace: StackTrace.current,
          );
          // Don't emit error state, just keep the current state with empty entries
          emit(currentState.copyWith(todayEntries: const []));
        },
      );
    }
  }

  Future<void> _onMarkHabitCompleted(MarkHabitCompleted event, Emitter<HabitState> emit) async {
    if (state is HabitLoaded) {
      AppLogger.i(
        'Marking habit completion: habitId=${event.habitId}, isCompleted=${event.isCompleted}', 
        tag: 'HabitBloc',
      );
      
      final result = await markHabitToday(event.habitId, event.isCompleted);
      result.when(
        success: (_) {
          AppLogger.i('Successfully marked habit completion', tag: 'HabitBloc');
          // Reload today's entries to reflect the change
          add(LoadTodayEntries());
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
    }
  }
}