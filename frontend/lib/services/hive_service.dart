import 'package:hive_flutter/hive_flutter.dart';
import '../models/task_model.dart';
import '../models/note_model.dart';
import '../models/goal_model.dart';
import '../models/exam_model.dart';
import '../models/class_routine_model.dart';
import '../models/user_model.dart';

class HiveService {
  // Box names
  static const String tasksBox = 'tasks';
  static const String notesBox = 'notes';
  static const String goalsBox = 'goals';
  static const String examsBox = 'exams';
  static const String routinesBox = 'routines';
  static const String userBox = 'user';

  // Initialize Hive
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(TaskAdapter());
    Hive.registerAdapter(NoteAdapter());
    Hive.registerAdapter(GoalAdapter());
    Hive.registerAdapter(ExamAdapter());
    Hive.registerAdapter(SyllabusTopicAdapter());
    Hive.registerAdapter(ClassRoutineAdapter());
    Hive.registerAdapter(UserAdapter());

    // Open boxes
    await _openBox<Task>(tasksBox);
    await _openBox<Note>(notesBox);
    await _openBox<Goal>(goalsBox);
    await _openBox<Exam>(examsBox);
    await _openBox<ClassRoutine>(routinesBox);
    await _openBox<User>(userBox);
  }

  static Future<void> _openBox<T>(String boxName) async {
    try {
      await Hive.openBox<T>(boxName);
    } catch (e) {
      print('Error opening box $boxName: $e');
      await Hive.deleteBoxFromDisk(boxName);
      await Hive.openBox<T>(boxName);
    }
  }

  // ===== TASKS =====
  Future<List<Task>> getTasks() async {
    final box = Hive.box<Task>(tasksBox);
    return box.values.toList();
  }

  Future<void> addTask(Task task) async {
    final box = Hive.box<Task>(tasksBox);
    task.id = DateTime.now().millisecondsSinceEpoch.toString();
    await box.put(task.id, task);
  }

  Future<void> updateTask(Task task) async {
    final box = Hive.box<Task>(tasksBox);
    if (task.id != null) {
      await box.put(task.id, task);
    }
  }

  Future<void> deleteTask(String id) async {
    final box = Hive.box<Task>(tasksBox);
    await box.delete(id);
  }

  // ===== NOTES =====
  Future<List<Note>> getNotes() async {
    final box = Hive.box<Note>(notesBox);
    return box.values.toList();
  }

  Future<void> addNote(Note note) async {
    final box = Hive.box<Note>(notesBox);
    note.id = DateTime.now().millisecondsSinceEpoch.toString();
    await box.put(note.id, note);
  }

  Future<void> updateNote(Note note) async {
    final box = Hive.box<Note>(notesBox);
    if (note.id != null) {
      await box.put(note.id, note);
    }
  }

  Future<void> deleteNote(String id) async {
    final box = Hive.box<Note>(notesBox);
    await box.delete(id);
  }

  // ===== GOALS =====
  Future<List<Goal>> getGoals() async {
    final box = Hive.box<Goal>(goalsBox);
    return box.values.toList();
  }

  Future<void> addGoal(Goal goal) async {
    final box = Hive.box<Goal>(goalsBox);
    goal.id = DateTime.now().millisecondsSinceEpoch.toString();
    await box.put(goal.id, goal);
  }

  Future<void> updateGoal(Goal goal) async {
    final box = Hive.box<Goal>(goalsBox);
    if (goal.id != null) {
      await box.put(goal.id, goal);
    }
  }

  Future<void> deleteGoal(String id) async {
    final box = Hive.box<Goal>(goalsBox);
    await box.delete(id);
  }

  // ===== EXAMS =====
  Future<List<Exam>> getExams() async {
    final box = Hive.box<Exam>(examsBox);
    return box.values.toList();
  }

  Future<void> addExam(Exam exam) async {
    final box = Hive.box<Exam>(examsBox);
    exam.id = DateTime.now().millisecondsSinceEpoch.toString();
    await box.put(exam.id, exam);
  }

  Future<void> updateExam(Exam exam) async {
    final box = Hive.box<Exam>(examsBox);
    if (exam.id != null) {
      await box.put(exam.id, exam);
    }
  }

  Future<void> deleteExam(String id) async {
    final box = Hive.box<Exam>(examsBox);
    await box.delete(id);
  }

  // ===== CLASS ROUTINES =====
  Future<List<ClassRoutine>> getClassRoutines() async {
    final box = Hive.box<ClassRoutine>(routinesBox);
    return box.values.toList();
  }

  Future<void> addClassRoutine(ClassRoutine routine) async {
    final box = Hive.box<ClassRoutine>(routinesBox);
    routine.id = DateTime.now().millisecondsSinceEpoch.toString();
    await box.put(routine.id, routine);
  }

  Future<void> updateClassRoutine(ClassRoutine routine) async {
    final box = Hive.box<ClassRoutine>(routinesBox);
    if (routine.id != null) {
      await box.put(routine.id, routine);
    }
  }

  Future<void> deleteClassRoutine(String id) async {
    final box = Hive.box<ClassRoutine>(routinesBox);
    await box.delete(id);
  }

  // ===== USER =====
  Future<User?> getUser() async {
    final box = Hive.box<User>(userBox);
    if (box.isNotEmpty) {
      return box.getAt(0);
    }
    return null;
  }

  Future<void> saveUser(User user) async {
    final box = Hive.box<User>(userBox);
    await box.put(0, user);
  }
}
