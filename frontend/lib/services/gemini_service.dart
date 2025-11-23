import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/task_model.dart';
import 'dart:convert';

class GeminiService {
  // API Key - TODO: Move to environment variables for production
  static const String _apiKey = 'AIzaSyDR7NGZZGRZByeVBpc5VsbS_nwPpirSvv0';

  static Future<List<Task>> parseScheduleText(
    String input,
    DateTime selectedDate,
  ) async {
    try {
      final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);

      final prompt =
          '''
You are a smart schedule assistant. Parse the following text into a structured daily schedule.
Extract tasks with their time ranges. If times are not specified, suggest reasonable times.
Include breakfast, lunch and dinner time as tasks.
Also include free time and go to bed time as tasks.
Try to make the bed time around 11:50pm. Manage all the tasks before that time.
Use 24-hour format for times.

Important rules:
- Each task should have a title, start time, and end time
- If no time is mentioned, infer from context (morning = 8-9am, afternoon = 2-3pm, evening = 6-7pm)
- If duration mentioned but no start time, suggest appropriate start time
- Return ONLY valid JSON array, no other text

Input text: "$input"

Return format (JSON only):
[
  {
    "title": "Task name",
    "startHour": 8,
    "startMinute": 0,
    "endHour": 10,
    "endMinute": 0
  }
]
''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      if (response.text == null) {
        throw Exception('No response from AI');
      }

      // Clean the response to extract JSON
      String jsonText = response.text!.trim();

      // Remove markdown code blocks if present
      if (jsonText.startsWith('```json')) {
        jsonText = jsonText.substring(7);
      } else if (jsonText.startsWith('```')) {
        jsonText = jsonText.substring(3);
      }
      if (jsonText.endsWith('```')) {
        jsonText = jsonText.substring(0, jsonText.length - 3);
      }
      jsonText = jsonText.trim();

      // Parse JSON
      final List<dynamic> tasksJson = jsonDecode(jsonText);

      // Convert to Task objects
      List<Task> tasks = [];
      for (var taskData in tasksJson) {
        final startTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          taskData['startHour'] ?? 0,
          taskData['startMinute'] ?? 0,
        );

        final endTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          taskData['endHour'] ?? 0,
          taskData['endMinute'] ?? 0,
        );

        tasks.add(
          Task(
            userId: 'local',
            title: taskData['title'] ?? 'Unnamed Task',
            startTime: startTime,
            endTime: endTime,
            date: selectedDate,
          ),
        );
      }

      return tasks;
    } catch (e) {
      print('Error parsing schedule: $e');
      rethrow;
    }
  }
}
