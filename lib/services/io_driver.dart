import 'package:daymark/app/shared/errors/result.dart';
import 'package:daymark/app/shared/errors/error_code.dart';
import 'package:daymark/app/shared/errors/app_error.dart';
import 'package:daymark/features/habit_tracker/data/models/habit_model.dart';
import 'package:daymark/features/habit_tracker/data/models/habit_entry_model.dart';
import 'package:daymark/features/habit_tracker/data/models/config_model.dart';
import 'package:daymark/features/habit_tracker/domain/entities/habit.dart';
import 'package:daymark/features/habit_tracker/domain/entities/habit_entry.dart';
import 'package:daymark/features/habit_tracker/domain/entities/app_config.dart';
import 'package:daymark/services/habit_service.dart';
import 'package:daymark/services/config_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// IO driver implementation using SQLite for local storage
class IODriver implements HabitService, ConfigService {
  static Database? _database;
  static const String _dbName = 'daymark.db';
  static const int _dbVersion = 1;

  // Table names
  static const String _tableHabits = 'habits';
  static const String _tableHabitEntries = 'habit_entries';
  static const String _tableConfig = 'app_config';

  /// Initialize the database - must be called before any operations
  Future<void> initialize() async {
    try {
      _database ??= await _initDatabase().timeout(const Duration(seconds: 10));
    } catch (e) {
      // Reset database on failure to allow retry
      _database = null;
      rethrow;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    var database = await openDatabase(
      path,
      version: _dbVersion,
    );

    // Create anyways on start
    _createTables(database, _dbVersion);

    return database;
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableHabits (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        color TEXT NOT NULL DEFAULT '#2196F3',
        createdAt TEXT NOT NULL,
        updatedAt TEXT,
        isActive INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableHabitEntries (
        id TEXT PRIMARY KEY,
        habitId TEXT NOT NULL,
        date TEXT NOT NULL,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        completedAt TEXT,
        FOREIGN KEY (habitId) REFERENCES $_tableHabits(id) ON DELETE CASCADE,
        UNIQUE(habitId, date)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableConfig (
        id TEXT PRIMARY KEY,
        preferredView TEXT NOT NULL,
        weeksToDisplay INTEGER NOT NULL,
        habitColorsJson TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT
      )
    ''');
  }

  @override
  FutureResult<List<Habit>, ErrorCode> getHabits() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(_tableHabits);
      final habits = maps.map((map) => HabitModel.fromJson(map)).toList();
      return Success(habits.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Failure.withAppError(StorageError('Failed to fetch habits'));
    }
  }

  @override
  FutureResult<Habit, ErrorCode> getHabit(String id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableHabits,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) {
        return const Failure(ErrorCode.habitNotFound);
      }

      final habit = HabitModel.fromJson(maps.first);
      return Success(habit.toEntity());
    } catch (e) {
      return Failure.withAppError(StorageError('Failed to fetch habit'));
    }
  }

  @override
  FutureResult<Habit, ErrorCode> createHabit(Habit habit) async {
    try {
      final db = await database;
      final model = HabitModel.fromEntity(habit);
      await db.insert(_tableHabits, model.toJson());
      return Success(habit);
    } catch (e) {
      return Failure.withAppError(StorageError('Failed to create habit'));
    }
  }

  @override
  FutureResult<Habit, ErrorCode> updateHabit(Habit habit) async {
    try {
      final db = await database;
      final model = HabitModel.fromEntity(habit);
      final updatedModel = model.copyWith(updatedAt: DateTime.now());
      
      await db.update(
        _tableHabits,
        updatedModel.toJson(),
        where: 'id = ?',
        whereArgs: [habit.id],
      );
      
      return Success(updatedModel.toEntity());
    } catch (e) {
      return Failure.withAppError(StorageError('Failed to update habit'));
    }
  }

  @override
  FutureResult<bool, ErrorCode> deleteHabit(String id) async {
    try {
      final db = await database;
      await db.delete(
        _tableHabits,
        where: 'id = ?',
        whereArgs: [id],
      );
      return const Success(true);
    } catch (e) {
      return Failure.withAppError(StorageError('Failed to delete habit'));
    }
  }

  @override
  FutureResult<List<HabitEntry>, ErrorCode> getHabitEntries(
    String habitId, 
    DateTime startDate, 
    DateTime endDate,
  ) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableHabitEntries,
        where: 'habitId = ? AND date BETWEEN ? AND ?',
        whereArgs: [
          habitId, 
          startDate.toIso8601String(), 
          endDate.toIso8601String()
        ],
      );
      
      final entries = maps.map((map) => HabitEntryModel.fromJson(map)).toList();
      return Success(entries.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Failure.withAppError(StorageError('Failed to fetch habit entries'));
    }
  }

  @override
  FutureResult<HabitEntry, ErrorCode> getHabitEntry(String habitId, DateTime date) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableHabitEntries,
        where: 'habitId = ? AND date = ?',
        whereArgs: [habitId, date.toIso8601String()],
      );

      if (maps.isEmpty) {
        // Return a default entry if none exists
        final defaultEntry = HabitEntry(
          id: '${habitId}_${date.toIso8601String()}',
          habitId: habitId,
          date: date,
          isCompleted: false,
        );
        return Success(defaultEntry);
      }

      final entry = HabitEntryModel.fromJson(maps.first);
      return Success(entry.toEntity());
    } catch (e) {
      return Failure.withAppError(StorageError('Failed to fetch habit entry'));
    }
  }

  @override
  FutureResult<HabitEntry, ErrorCode> createHabitEntry(HabitEntry entry) async {
    try {
      final db = await database;
      final model = HabitEntryModel.fromEntity(entry);
      await db.insert(_tableHabitEntries, model.toJson());
      return Success(entry);
    } catch (e) {
      return Failure.withAppError(StorageError('Failed to create habit entry'));
    }
  }

  @override
  FutureResult<HabitEntry, ErrorCode> updateHabitEntry(HabitEntry entry) async {
    try {
      final db = await database;
      final model = HabitEntryModel.fromEntity(entry);
      
      await db.update(
        _tableHabitEntries,
        model.toJson(),
        where: 'id = ?',
        whereArgs: [entry.id],
      );
      
      return Success(entry);
    } catch (e) {
      return Failure.withAppError(StorageError('Failed to update habit entry'));
    }
  }

  @override
  FutureResult<bool, ErrorCode> deleteHabitEntry(String id) async {
    try {
      final db = await database;
      await db.delete(
        _tableHabitEntries,
        where: 'id = ?',
        whereArgs: [id],
      );
      return const Success(true);
    } catch (e) {
      return Failure.withAppError(StorageError('Failed to delete habit entry'));
    }
  }

  @override
  FutureResult<List<HabitEntry>, ErrorCode> getTodayEntries() async {
    return getDateEntries(DateTime.now());
  }

  @override
  FutureResult<List<HabitEntry>, ErrorCode> getDateEntries(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
      
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableHabitEntries,
        where: 'date BETWEEN ? AND ?',
        whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      );
      
      final entries = maps.map((map) => HabitEntryModel.fromJson(map)).toList();
      return Success(entries.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Failure.withAppError(StorageError('Failed to fetch date entries'));
    }
  }

  @override
  FutureResult<bool, ErrorCode> markHabitForToday(String habitId, bool isCompleted) async {
    return markHabitForDate(habitId, isCompleted, DateTime.now());
  }

  @override
  FutureResult<bool, ErrorCode> markHabitForDate(String habitId, bool isCompleted, DateTime date) async {
    try {
      final db = await database;
      
      // Check if entry exists in database
      final List<Map<String, dynamic>> existingEntries = await db.query(
        _tableHabitEntries,
        where: 'habitId = ? AND date = ?',
        whereArgs: [habitId, date.toIso8601String()],
      );
      
      final entryExists = existingEntries.isNotEmpty;
      
      if (entryExists) {
        // Update existing entry
        final existingEntry = HabitEntryModel.fromJson(existingEntries.first);
        final updatedEntry = existingEntry.copyWith(
          isCompleted: isCompleted,
          completedAt: isCompleted ? DateTime.now() : null,
        );
        
        return await updateHabitEntry(updatedEntry.toEntity()).then((result) {
          return result.when(
            success: (_) => const Success(true),
            failure: (error) => Failure(error),
          );
        });
      } else {
        // Create new entry
        final newEntry = HabitEntry(
          id: '${habitId}_${date.toIso8601String()}',
          habitId: habitId,
          date: date,
          isCompleted: isCompleted,
          completedAt: isCompleted ? DateTime.now() : null,
        );
        
        return await createHabitEntry(newEntry).then((result) {
          return result.when(
            success: (_) => const Success(true),
            failure: (error) => Failure(error),
          );
        });
      }
    } catch (e) {
      return Failure.withAppError(StorageError('Failed to mark habit for date'));
    }
  }

  // Configuration Service Implementation
  @override
  FutureResult<AppConfig, ErrorCode> getConfig() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(_tableConfig);
      
      if (maps.isEmpty) {
        // Create default config if none exists
        final defaultConfig = AppConfig.defaultConfig;
        return await createConfig(defaultConfig);
      }
      
      final config = ConfigModel.fromJson(maps.first);
      return Success(config.toEntity());
    } catch (e) {
      return Failure.withAppError(StorageError('Failed to fetch configuration'));
    }
  }

  @override
  FutureResult<AppConfig, ErrorCode> updateConfig(AppConfig config) async {
    try {
      final db = await database;
      final model = ConfigModel.fromEntity(config);
      final updatedModel = model.copyWith(updatedAt: DateTime.now().toIso8601String());
      
      await db.update(
        _tableConfig,
        updatedModel.toJson(),
        where: 'id = ?',
        whereArgs: [config.id],
      );
      
      return Success(updatedModel.toEntity());
    } catch (e) {
      return Failure.withAppError(StorageError('Failed to update configuration'));
    }
  }

  @override
  FutureResult<AppConfig, ErrorCode> updatePreferredView(ViewType viewType) async {
    final configResult = await getConfig();
    return configResult.when(
      success: (config) => updateConfig(config.copyWith(preferredView: viewType)),
      failure: (error) => Failure(error),
    );
  }

  @override
  FutureResult<AppConfig, ErrorCode> updateWeeksToDisplay(int weeks) async {
    final configResult = await getConfig();
    return configResult.when(
      success: (config) => updateConfig(config.copyWith(weeksToDisplay: weeks)),
      failure: (error) => Failure(error),
    );
  }

  @override
  FutureResult<AppConfig, ErrorCode> updateHabitColor(String habitId, String color) async {
    final configResult = await getConfig();
    return configResult.when(
      success: (config) {
        final updatedColors = Map<String, String>.from(config.habitColors);
        updatedColors[habitId] = color;
        return updateConfig(config.copyWith(habitColors: updatedColors));
      },
      failure: (error) => Failure(error),
    );
  }

  @override
  FutureResult<AppConfig, ErrorCode> removeHabitColor(String habitId) async {
    final configResult = await getConfig();
    return configResult.when(
      success: (config) {
        final updatedColors = Map<String, String>.from(config.habitColors);
        updatedColors.remove(habitId);
        return updateConfig(config.copyWith(habitColors: updatedColors));
      },
      failure: (error) => Failure(error),
    );
  }

  @override
  FutureResult<AppConfig, ErrorCode> resetToDefaults() async {
    try {
      final db = await database;
      final defaultConfig = AppConfig.defaultConfig;
      final model = ConfigModel.fromEntity(defaultConfig);
      
      await db.delete(_tableConfig);
      await db.insert(_tableConfig, model.toJson());
      
      return Success(defaultConfig);
    } catch (e) {
      return Failure.withAppError(StorageError('Failed to reset configuration'));
    }
  }

  /// Helper method to create initial configuration
  FutureResult<AppConfig, ErrorCode> createConfig(AppConfig config) async {
    try {
      final db = await database;
      final model = ConfigModel.fromEntity(config);
      await db.insert(_tableConfig, model.toJson());
      return Success(config);
    } catch (e) {
      return Failure.withAppError(StorageError('Failed to create configuration'));
    }
  }
}
