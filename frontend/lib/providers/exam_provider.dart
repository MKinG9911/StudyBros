import 'package:flutter/material.dart';
import '../models/exam_model.dart';
import '../services/hive_service.dart';
// import '../services/notification_service.dart'; // Temporarily disabled

class ExamProvider with ChangeNotifier {
  final HiveService _hiveService = HiveService();
  List<Exam> _exams = [];
  bool _isLoading = false;

  List<Exam> get exams => _exams;
  bool get isLoading => _isLoading;

  Future<void> fetchExams() async {
    _isLoading = true;
    notifyListeners();
    try {
      _exams = await _hiveService.getExams();
      // Check and schedule notifications for upcoming exams
      // for (var exam in _exams) {
      //   if (exam.notificationsEnabled) {
      //     await NotificationService.scheduleExamReminder(exam);
      //   }
      // }
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addExam(Exam exam) async {
    try {
      await _hiveService.addExam(exam);
      // if (exam.notificationsEnabled) {
      //   await NotificationService.scheduleExamReminder(exam);
      // }
      await fetchExams();
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateExam(Exam exam) async {
    try {
      await _hiveService.updateExam(exam);
      // if (exam.notificationsEnabled) {
      //   await NotificationService.scheduleExamReminder(exam);
      // } else {
      //   await NotificationService.cancelExamNotifications(exam.id!);
      // }
      notifyListeners();
    } catch (e) {
      print(e);
      await fetchExams();
    }
  }

  Future<void> deleteExam(String id) async {
    try {
      // await NotificationService.cancelExamNotifications(id);
      await _hiveService.deleteExam(id);
      await fetchExams();
    } catch (e) {
      print(e);
    }
  }

  void toggleSyllabusItem(Exam exam, int index) {
    exam.syllabus[index].isCompleted = !exam.syllabus[index].isCompleted;
    updateExam(exam);
  }

  void addSyllabusTopic(Exam exam, String topic) {
    exam.syllabus.add(SyllabusTopic(title: topic));
    updateExam(exam);
  }

  void deleteSyllabusTopic(Exam exam, int index) {
    exam.syllabus.removeAt(index);
    updateExam(exam);
  }
}
