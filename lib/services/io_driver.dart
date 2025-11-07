import 'package:daymark/app/shared/errors/result.dart';
import 'package:daymark/app/shared/errors/error_code.dart';
import 'package:daymark/app/shared/errors/app_error.dart';
import 'package:daymark/features/habit_tracker/data/models/habit_model.dart';
import 'package:daymark/features/habit_tracker/data/models/habit_entry_model.dart';
import 'package:daymark/features/habit_tracker/domain/entities/habit.dart';
import 'package:daymark/features/habit_tracker/domain/entities/habit_entry.dart';
import 'package:daymark/services/habit_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// IO driver implementation using SQLite for local storage
class IODriver implements HabitService {
  static Database? _database;
  static const String _dbName = 'daymark.db';
  static const int _dbVersion = 1;

  // Table names
  static const String _tableHabits = 'habits';
  static const String _tableHabitEntries = 'habit_entries';

  /// Initialize the database - must be called before any operations
  Future<void> initialize() async {
    _database ??= await _initDatabase();
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableHabits (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT,
        isActive INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE $_tableHabitEntries (
        id TEXT PRIMARY KEY,
        habitId TEXT NOT NULL,
        date TEXT NOT NULL,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        completedAt TEXT,
        FOREIGN KEY (habitId) REFERENCES $_tableHabits(id) ON DELETE CASCADE,
        UNIQUE(habitId, date)
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
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);
      
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableHabitEntries,
        where: 'date BETWEEN ? AND ?',
        whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      );
      
      final entries = maps.map((map) => HabitEntryModel.fromJson(map)).toList();
      return Success(entries.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Failure.withAppError(StorageError('Failed to fetch today\'s entries'));
    }
  }

  @override
  FutureResult<bool, ErrorCode> markHabitForToday(String habitId, bool isCompleted) async {
    try {
      final today = DateTime.now();
      final db = await database;
      
      // Check if entry exists in database
      final List<Map<String, dynamic>> existingEntries = await db.query(
        _tableHabitEntries,
        where: 'habitId = ? AND date = ?',
        whereArgs: [habitId, today.toIso8601String()],
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
          id: '${habitId}_${today.toIso8601String()}',
          habitId: habitId,
          date: today,
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
      return Failure.withAppError(StorageError('Failed to mark habit for today'));
    }
  }
}