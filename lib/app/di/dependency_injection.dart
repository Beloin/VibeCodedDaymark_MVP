import 'package:get_it/get_it.dart';
import 'package:daymark/features/habit_tracker/domain/repositories/habit_repository.dart';
import 'package:daymark/features/habit_tracker/data/repositories/habit_repository_impl.dart';
import 'package:daymark/features/habit_tracker/domain/usecases/get_habits.dart';
import 'package:daymark/features/habit_tracker/domain/usecases/get_today_entries.dart';
import 'package:daymark/features/habit_tracker/domain/usecases/mark_habit_today.dart';
import 'package:daymark/services/habit_service.dart';
import 'package:daymark/services/io_driver.dart';

/// Service locator for dependency injection
final GetIt sl = GetIt.instance;

/// Initialize dependency injection
Future<void> initDependencies() async {
  // Services - initialize database first
  final ioDriver = IODriver();
  await ioDriver.initialize();
  sl.registerLazySingleton<HabitService>(() => ioDriver);
  
  // Repositories
  sl.registerLazySingleton<HabitRepository>(
    () => HabitRepositoryImpl(sl()),
  );
  
  // Use cases
  sl.registerLazySingleton(() => GetHabits(sl()));
  sl.registerLazySingleton(() => GetTodayEntries(sl()));
  sl.registerLazySingleton(() => MarkHabitToday(sl()));
}

/// Reset dependencies for testing
void resetDependencies() {
  sl.reset();
}