import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daymark/features/habit_tracker/domain/entities/habit.dart';
import 'package:daymark/features/habit_tracker/domain/entities/habit_entry.dart';
import 'package:daymark/features/habit_tracker/domain/usecases/get_habits.dart';
import 'package:daymark/features/habit_tracker/domain/usecases/get_today_entries.dart';
import 'package:daymark/features/habit_tracker/domain/usecases/mark_habit_today.dart';

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
    emit(HabitLoading());
    
    final result = await getHabits();
    result.when(
      success: (habits) => emit(HabitLoaded(habits: habits)),
      failure: (error) => emit(HabitError(message: error.toString())),
    );
  }

  Future<void> _onLoadTodayEntries(LoadTodayEntries event, Emitter<HabitState> emit) async {
    if (state is HabitLoaded) {
      final currentState = state as HabitLoaded;
      emit(HabitLoading());
      
      final result = await getTodayEntries();
      result.when(
        success: (entries) => emit(currentState.copyWith(todayEntries: entries)),
        failure: (error) => emit(HabitError(message: error.toString())),
      );
    }
  }

  Future<void> _onMarkHabitCompleted(MarkHabitCompleted event, Emitter<HabitState> emit) async {
    if (state is HabitLoaded) {
      final result = await markHabitToday(event.habitId, event.isCompleted);
      result.when(
        success: (_) {
          // Reload today's entries to reflect the change
          add(LoadTodayEntries());
        },
        failure: (error) => emit(HabitError(message: error.toString())),
      );
    }
  }
}