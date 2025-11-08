import 'package:get_it/get_it.dart';
import 'package:daymark/features/habit_tracker/domain/repositories/habit_repository.dart';
import 'package:daymark/features/habit_tracker/data/repositories/habit_repository_impl.dart';
import 'package:daymark/features/habit_tracker/domain/repositories/config_repository.dart';
import 'package:daymark/features/habit_tracker/data/repositories/config_repository_impl.dart';
import 'package:daymark/features/habit_tracker/domain/usecases/get_habits.dart';
import 'package:daymark/features/habit_tracker/domain/usecases/get_today_entries.dart';
import 'package:daymark/features/habit_tracker/domain/usecases/get_date_entries.dart';
import 'package:daymark/features/habit_tracker/domain/usecases/get_habit_entries.dart';
import 'package:daymark/features/habit_tracker/domain/usecases/mark_habit_for_date.dart';
import 'package:daymark/features/habit_tracker/domain/usecases/create_habit.dart';
import 'package:daymark/features/habit_tracker/domain/usecases/delete_habit.dart';
import 'package:daymark/features/habit_tracker/domain/usecases/get_config.dart';
import 'package:daymark/features/habit_tracker/domain/usecases/update_config.dart';
import 'package:daymark/features/habit_tracker/domain/usecases/update_preferred_view.dart';
import 'package:daymark/features/habit_tracker/domain/usecases/update_weeks_to_display.dart';
import 'package:daymark/features/habit_tracker/domain/usecases/update_habit_color.dart';
import 'package:daymark/features/habit_tracker/domain/usecases/reset_config.dart';
import 'package:daymark/features/habit_tracker/presentation/bloc/habit_bloc.dart';
import 'package:daymark/features/habit_tracker/presentation/bloc/config_bloc.dart';
import 'package:daymark/services/habit_service.dart';
import 'package:daymark/services/config_service.dart';
import 'package:daymark/services/io_driver.dart';
import 'package:daymark/services/mock_service.dart';

/// Service locator for dependency injection
final GetIt sl = GetIt.instance;

/// Initialize dependency injection
Future<void> initDependencies() async {
  try {
    // Try to use SQLite-based service first
    final ioDriver = IODriver();
    await ioDriver.initialize();
    sl.registerLazySingleton<HabitService>(() => ioDriver);
    sl.registerLazySingleton<ConfigService>(() => ioDriver);

    // Repositories
    sl.registerLazySingleton<HabitRepository>(
      () => HabitRepositoryImpl(sl()),
    );
    sl.registerLazySingleton<ConfigRepository>(
      () => ConfigRepositoryImpl(sl()),
    );

    // Use cases
    sl.registerLazySingleton(() => GetHabits(sl()));
    sl.registerLazySingleton(() => GetTodayEntries(sl()));
    sl.registerLazySingleton(() => GetDateEntries(sl()));
    sl.registerLazySingleton(() => GetHabitEntries(sl()));
    sl.registerLazySingleton(() => MarkHabitForDate(sl()));
    sl.registerLazySingleton(() => CreateHabitUseCase(sl()));
    sl.registerLazySingleton(() => DeleteHabitUseCase(sl()));

    // Configuration use cases
    sl.registerLazySingleton(() => GetConfig(sl()));
    sl.registerLazySingleton(() => UpdateConfig(sl()));
    sl.registerLazySingleton(() => UpdatePreferredView(sl()));
    sl.registerLazySingleton(() => UpdateWeeksToDisplay(sl()));
    sl.registerLazySingleton(() => UpdateHabitColor(sl()));
    sl.registerLazySingleton(() => ResetConfig(sl()));

    // BLoCs
    sl.registerFactory(() => HabitBloc(
          getHabits: sl(),
          getTodayEntries: sl(),
          getDateEntries: sl(),
          getHabitEntries: sl(),
          markHabitForDate: sl(),
          createHabit: sl(),
          deleteHabit: sl(),
        ));
    sl.registerFactory(() => ConfigBloc(
          getConfig: sl(),
          updatePreferredView: sl(),
          updateWeeksToDisplay: sl(),
          updateHabitColor: sl(),
          resetConfig: sl(),
        ));
  } catch (e) {
    // If SQLite fails (e.g., on Linux desktop), use mock service
    sl.reset();

    // Register mock services
    final mockService = MockService();
    await mockService.initialize();
    sl.registerLazySingleton<HabitService>(() => mockService);
    sl.registerLazySingleton<ConfigService>(() => mockService);

    // Register repositories
    sl.registerLazySingleton<HabitRepository>(
      () => HabitRepositoryImpl(sl()),
    );
    sl.registerLazySingleton<ConfigRepository>(
      () => ConfigRepositoryImpl(sl()),
    );

    // Register use cases
    sl.registerLazySingleton(() => GetHabits(sl()));
    sl.registerLazySingleton(() => GetTodayEntries(sl()));
    sl.registerLazySingleton(() => GetDateEntries(sl()));
    sl.registerLazySingleton(() => GetHabitEntries(sl()));
    sl.registerLazySingleton(() => MarkHabitForDate(sl()));
    sl.registerLazySingleton(() => CreateHabitUseCase(sl()));
    sl.registerLazySingleton(() => DeleteHabitUseCase(sl()));

    // Configuration use cases
    sl.registerLazySingleton(() => GetConfig(sl()));
    sl.registerLazySingleton(() => UpdateConfig(sl()));
    sl.registerLazySingleton(() => UpdatePreferredView(sl()));
    sl.registerLazySingleton(() => UpdateWeeksToDisplay(sl()));
    sl.registerLazySingleton(() => UpdateHabitColor(sl()));
    sl.registerLazySingleton(() => ResetConfig(sl()));

    // Register BLoCs
    sl.registerFactory(() => HabitBloc(
          getHabits: sl(),
          getTodayEntries: sl(),
          getDateEntries: sl(),
          getHabitEntries: sl(),
          markHabitForDate: sl(),
          createHabit: sl(),
          deleteHabit: sl(),
        ));
    sl.registerFactory(() => ConfigBloc(
          getConfig: sl(),
          updatePreferredView: sl(),
          updateWeeksToDisplay: sl(),
          updateHabitColor: sl(),
          resetConfig: sl(),
        ));

    // Seed with sample data for testing
    await mockService.seedSampleData();
  }
}

/// Reset dependencies for testing
void resetDependencies() {
  sl.reset();
}

