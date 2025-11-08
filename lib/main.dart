import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daymark/app/di/dependency_injection.dart';
import 'package:daymark/app/shared/theme/app_theme.dart';
import 'package:daymark/app/shared/utils/logger.dart';
import 'package:daymark/features/habit_tracker/presentation/bloc/habit_bloc.dart';
import 'package:daymark/features/habit_tracker/presentation/bloc/config_bloc.dart';
import 'package:daymark/features/habit_tracker/presentation/pages/home_page_refactored_fixed.dart';
import 'package:daymark/services/habit_service.dart';
import 'package:daymark/services/sample_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize dependency injection with timeout
    await initDependencies().timeout(const Duration(seconds: 10));
    
    // Seed with sample data with timeout
    await _seedSampleData().timeout(const Duration(seconds: 5));
    
    runApp(const DaymarkApp());
  } catch (e) {
    // If initialization fails, still run the app but show error state
    runApp(const DaymarkApp());
  }
}

class DaymarkApp extends StatelessWidget {
  const DaymarkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HabitBloc>(
          create: (context) => sl<HabitBloc>(),
        ),
        BlocProvider<ConfigBloc>(
          create: (context) => sl<ConfigBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'Daymark',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: const HomePageRefactoredFixed(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

Future<void> _seedSampleData() async {
  try {
    // Database is already initialized via dependency injection
    final habitService = sl<HabitService>();
    final result = await habitService.getHabits().timeout(const Duration(seconds: 5));
    await result.when(
      success: (habits) async {
        if (habits.isEmpty) {
          // Seed with sample data
          await SampleData.seedDatabase(habitService).timeout(const Duration(seconds: 5));
        }
      },
      failure: (error) async {
        // If there's an error, seed the data
        await SampleData.seedDatabase(habitService).timeout(const Duration(seconds: 5));
      },
    );
  } catch (e) {
    // If any error occurs, log it but don't crash the app
    AppLogger.e(
      'Failed to seed sample data', 
      tag: 'main', 
      error: e.toString(),
      stackTrace: StackTrace.current,
    );
    // Continue without seeding - the app should still work
  }
}