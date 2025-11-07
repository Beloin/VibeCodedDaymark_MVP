import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daymark/app/di/dependency_injection.dart';
import 'package:daymark/app/shared/theme/app_theme.dart';
import 'package:daymark/features/habit_tracker/presentation/bloc/habit_bloc.dart';
import 'package:daymark/features/habit_tracker/presentation/pages/home_page.dart';
import 'package:daymark/services/habit_service.dart';
import 'package:daymark/services/sample_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection
  await initDependencies();
  
  // Seed with sample data
  await _seedSampleData();
  
  runApp(const DaymarkApp());
}

class DaymarkApp extends StatelessWidget {
  const DaymarkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HabitBloc>(
          create: (context) => HabitBloc(
            getHabits: sl(),
            getTodayEntries: sl(),
            getDateEntries: sl(),
            markHabitForDate: sl(),
            createHabit: sl(),
            deleteHabit: sl(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Daymark',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: const HomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

Future<void> _seedSampleData() async {
  try {
    // Database is already initialized via dependency injection
    final habitService = sl<HabitService>();
    final result = await habitService.getHabits();
    await result.when(
      success: (habits) async {
        if (habits.isEmpty) {
          // Seed with sample data
          await SampleData.seedDatabase(habitService);
        }
      },
      failure: (error) async {
        // If there's an error, seed the data
        await SampleData.seedDatabase(habitService);
      },
    );
  } catch (e) {
    // If any error occurs, try to seed the data
    final habitService = sl<HabitService>();
    await SampleData.seedDatabase(habitService);
  }
}