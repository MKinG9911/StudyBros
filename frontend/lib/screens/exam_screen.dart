import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/exam_provider.dart';
import '../models/exam_model.dart';
import '../utils/constants.dart';
import '../widgets/theme_toggle_button.dart';

class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExamProvider>(context, listen: false).fetchExams();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Preparation'),
        actions: const [
          ThemeToggleButton(),
        ],
      ),
      body: Consumer<ExamProvider>(
        builder: (context, examProvider, child) {
          if (examProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (examProvider.exams.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 80,
                    color: AppColors.textSecondary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  const Text("No exams scheduled", style: AppTextStyles.body),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: examProvider.exams.length,
            itemBuilder: (context, index) =>
                ExamCard(exam: examProvider.exams[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddExamDialog(context),
      ),
    );
  }

  void _showAddExamDialog(BuildContext context) {
    final subjectController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Add Exam"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: subjectController,
                decoration: InputDecoration(
                  labelText: "Subject",
                  hintText: "e.g., Mathematics",
                  hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7)),
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(DateFormat('MMM dd, yyyy').format(selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => selectedDate = date);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (subjectController.text.isNotEmpty) {
                  final exam = Exam(
                    userId: 'local',
                    subject: subjectController.text,
                    examDate: selectedDate,
                  );
                  Provider.of<ExamProvider>(
                    context,
                    listen: false,
                  ).addExam(exam);
                  Navigator.pop(context);
                }
              },
              child: const Text("Add"),
            ),
          ],
        ),
      ),
    );
  }
}

class ExamCard extends StatefulWidget {
  final Exam exam;

  const ExamCard({super.key, required this.exam});

  @override
  State<ExamCard> createState() => _ExamCardState();
}

class _ExamCardState extends State<ExamCard> {
  final TextEditingController _topicController = TextEditingController();

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final daysLeft = widget.exam.daysRemaining;
    final Color countdownColor = daysLeft <= 3
        ? Colors.red
        : (daysLeft <= 7 ? Colors.orange : AppColors.primary);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          width: 60,
          decoration: BoxDecoration(
            color: countdownColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$daysLeft',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: countdownColor,
                  ),
                ),
                Text(
                  'days',
                  style: TextStyle(fontSize: 10, color: countdownColor),
                ),
              ],
            ),
          ),
        ),
        title: Builder(
          builder: (context) {
            final color = Theme.of(context).colorScheme.onSurface;
            return Text(
              widget.exam.subject,
              style: AppTextStyles.heading2.copyWith(
                fontSize: 18,
                color: color,
              ),
            );
          },
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('MMM dd, yyyy').format(widget.exam.examDate),
              style: AppTextStyles.caption,
            ),
            if (widget.exam.syllabus.isNotEmpty) ...[
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: widget.exam.completionPercentage / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation(countdownColor),
                minHeight: 4,
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
              onPressed: () => _showEditExamDialog(context),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Delete Exam"),
                    content: const Text(
                      "Are you sure you want to delete this exam?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          Provider.of<ExamProvider>(
                            context,
                            listen: false,
                          ).deleteExam(widget.exam.id!);
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text("Delete"),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        children: [
          GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Syllabus Checklist",
                        style: AppTextStyles.heading2.copyWith(fontSize: 16),
                      ),
                      Text(
                        "Add topics to track",
                        style: AppTextStyles.caption.copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...widget.exam.syllabus.asMap().entries.map((entry) {
                    final index = entry.key;
                    final topic = entry.value;
                    final theme = Theme.of(context);
                    final activeColor = theme.colorScheme.onSurface;
                    final completedColor = activeColor.withOpacity(0.5);

                    return CheckboxListTile(
                      title: Text(
                        topic.title,
                        style: TextStyle(
                          decoration: topic.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: topic.isCompleted
                              ? completedColor
                              : activeColor,
                          fontSize: 14,
                        ),
                      ),
                      value: topic.isCompleted,
                      onChanged: (value) {
                        Provider.of<ExamProvider>(
                          context,
                          listen: false,
                        ).toggleSyllabusItem(widget.exam, index);
                      },
                      secondary: IconButton(
                        icon: const Icon(
                          Icons.close,
                          size: 18,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          Provider.of<ExamProvider>(
                            context,
                            listen: false,
                          ).deleteSyllabusTopic(widget.exam, index);
                        },
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    );
                  }),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _topicController,
                          decoration: InputDecoration(
                            hintText: "Add topic...",
                            hintStyle: TextStyle(
                              color: Colors.grey.withOpacity(0.7),
                              fontSize: 14,
                            ),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            border: const OutlineInputBorder(),
                          ),
                          onSubmitted: (_) => _addTopic(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _addTopic,
                        icon: const Icon(
                          Icons.add_circle,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addTopic() {
    if (_topicController.text.isNotEmpty) {
      Provider.of<ExamProvider>(
        context,
        listen: false,
      ).addSyllabusTopic(widget.exam, _topicController.text);
      _topicController.clear();
    }
  }

  void _showEditExamDialog(BuildContext context) {
    final subjectController = TextEditingController(text: widget.exam.subject);
    DateTime selectedDate = widget.exam.examDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Edit Exam"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: subjectController,
                decoration: InputDecoration(
                  labelText: "Subject",
                  hintText: "e.g., Mathematics",
                  hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7)),
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(DateFormat('MMM dd, yyyy').format(selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => selectedDate = date);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (subjectController.text.isNotEmpty) {
                  final updatedExam = widget.exam;
                  updatedExam.subject = subjectController.text;
                  updatedExam.examDate = selectedDate;

                  Provider.of<ExamProvider>(
                    context,
                    listen: false,
                  ).updateExam(updatedExam);
                  Navigator.pop(context);
                }
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
