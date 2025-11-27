import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/exam_model.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(initSettings);
  }

  static Future<void> requestPermissions() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.requestNotificationsPermission();
  }

  // Schedule exam reminders (3, 2, 1 days before)
  static Future<void> scheduleExamReminder(Exam exam) async {
    if (exam.id == null) return;

    final examDate = exam.examDate;
    final now = DateTime.now();

    // Cancel existing notifications for this exam
    await cancelExamNotifications(exam.id!);

    // Schedule notifications for 3, 2, and 1 days before
    for (int daysBefore in [3, 2, 1]) {
      final notificationDate = examDate.subtract(Duration(days: daysBefore));

      if (notificationDate.isAfter(now)) {
        final id =
            int.parse(exam.id!.hashCode.toString().substring(0, 6)) +
            daysBefore;

        await _notifications.zonedSchedule(
          id,
          'Exam Reminder: ${exam.subject}',
          'Your ${exam.subject} exam is in $daysBefore day${daysBefore > 1 ? "s" : ""}!',
          tz.TZDateTime.from(
            DateTime(
              notificationDate.year,
              notificationDate.month,
              notificationDate.day,
              9,
              0,
            ),
            tz.local,
          ),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'exam_channel',
              'Exam Reminders',
              channelDescription: 'Notifications for upcoming exams',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }
    }
  }

  static Future<void> cancelExamNotifications(String examId) async {
    final baseId = int.parse(examId.hashCode.toString().substring(0, 6));
    for (int i = 1; i <= 3; i++) {
      await _notifications.cancel(baseId + i);
    }
  }

  // Show focus timer complete notification
  static Future<void> showTimerComplete() async {
    await _notifications.show(
      999,
      'Focus Session Complete!',
      'Great job! Time for a break.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'timer_channel',
          'Focus Timer',
          channelDescription: 'Notifications for focus timer completion',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}
