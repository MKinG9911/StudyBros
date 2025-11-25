import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import 'daily_planner_screen.dart';
import 'notes_screen.dart';
import 'weekly_planner_screen.dart';
import 'exam_screen.dart';
import 'class_routine_screen.dart';
import '../providers/notes_provider.dart';
import '../providers/task_provider.dart';
import '../providers/exam_provider.dart';
import '../providers/focus_timer_provider.dart';
import '../providers/user_provider.dart';
import '../providers/dashboard_provider.dart';
import '../models/dashboard_section.dart';
import 'profile_screen.dart';
import 'focus_mode_screen.dart';
import 'dart:io';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeDashboard(
        onNavigateToTab: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      const DailyPlannerScreen(),
      const WeeklyPlannerScreen(),
      const ExamScreen(),
      const NotesScreen(),
    ];

    // Fetch data for preview
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotesProvider>(context, listen: false).fetchNotes();
      Provider.of<TaskProvider>(context, listen: false).fetchTasks();
      Provider.of<ExamProvider>(context, listen: false).fetchExams();
      Provider.of<UserProvider>(context, listen: false).fetchUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 150),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.98, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut),
              ),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(_selectedIndex),
          child: _screens[_selectedIndex],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Daily',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_week_outlined),
            activeIcon: Icon(Icons.view_week),
            label: 'Weekly',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            activeIcon: Icon(Icons.school),
            label: 'Exams',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note_outlined),
            activeIcon: Icon(Icons.note),
            label: 'Notes',
          ),
        ],
      ),
    );
  }
}

class HomeDashboard extends StatelessWidget {
  final Function(int) onNavigateToTab;

  const HomeDashboard({super.key, required this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: AppColors.background,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 16,
            bottom: 16,
          ),
          alignment: Alignment.center,
          child: Text(
            "StudyBros",
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        Expanded(
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Consumer<UserProvider>(
                    builder: (context, userProvider, child) {
                      final user = userProvider.user;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Hello, ${user.name}!",
                                  style: AppTextStyles.heading1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Ready to study today?",
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            icon: const Icon(Icons.tune, size: 24),
                            onPressed: () => _showCustomizeDialog(context),
                            tooltip: 'Customize Dashboard',
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProfileScreen(),
                                ),
                              );
                            },
                            child: CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.primary,
                              backgroundImage: user.profilePicturePath != null
                                  ? FileImage(File(user.profilePicturePath!))
                                  : null,
                              child: user.profilePicturePath == null
                                  ? const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 30),

                  Consumer<DashboardProvider>(
                    builder: (context, dashboardProvider, child) {
                      return Column(
                        children: dashboardProvider.sections.map((section) {
                          Widget sectionWidget;
                          switch (section.type) {
                            case DashboardSectionType.focusTimer:
                              sectionWidget = _buildFocusTimerSection();
                              break;
                            case DashboardSectionType.dailyTasks:
                              sectionWidget = _buildDailyTasksSection();
                              break;
                            case DashboardSectionType.upcomingExams:
                              sectionWidget = _buildUpcomingExamsSection();
                              break;
                            case DashboardSectionType.classRoutine:
                              sectionWidget = _buildClassRoutineSection(
                                context,
                              );
                              break;
                            case DashboardSectionType.quickNotes:
                              sectionWidget = _buildQuickNotesSection(context);
                              break;
                            default:
                              sectionWidget = const SizedBox.shrink();
                          }
                          return Column(
                            children: [
                              sectionWidget,
                              const SizedBox(height: 30),
                            ],
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFocusTimerSection() {
    return Consumer<FocusTimerProvider>(
      builder: (context, timerProvider, child) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FocusModeScreen()),
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFF8F85FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Focus Timer",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (!timerProvider.isRunning)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: timerProvider.durationMinutes,
                            dropdownColor: AppColors.primary,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white,
                            ),
                            items:
                                [
                                      5,
                                      10,
                                      15,
                                      25,
                                      30,
                                      45,
                                      60,
                                      90,
                                      120,
                                      180,
                                      240,
                                      300,
                                      360,
                                    ]
                                    .map(
                                      (mins) => DropdownMenuItem(
                                        value: mins,
                                        child: Text('${mins}m'),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                timerProvider.setDuration(value);
                              }
                            },
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      timerProvider.displayTime,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        if (timerProvider.isRunning || timerProvider.isPaused)
                          GestureDetector(
                            onTap: () => timerProvider.resetTimer(),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.refresh,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () {
                            if (timerProvider.isRunning) {
                              timerProvider.pauseTimer();
                            } else {
                              timerProvider.startTimer();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Icon(
                              timerProvider.isRunning
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: AppColors.primary,
                              size: 32,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (timerProvider.isRunning) ...[
                  const SizedBox(height: 12),
                  const Center(
                    child: Text(
                      "Tap to focus more",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDailyTasksSection() {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final today = DateTime.now();
        final tasks = taskProvider.tasks.where((task) {
          final isSameDay =
              task.date.year == today.year &&
              task.date.month == today.month &&
              task.date.day == today.day;
          return isSameDay;
        }).toList();

        // Sort by start time
        tasks.sort((a, b) => a.startTime.compareTo(b.startTime));

        // Take top 3
        final displayTasks = tasks.take(3).toList();

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Daily Tasks", style: AppTextStyles.heading2),
                TextButton(
                  onPressed: () =>
                      onNavigateToTab(1), // Navigate to Daily Planner
                  child: const Text("View All"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (displayTasks.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.task_alt,
                      size: 48,
                      color: AppColors.textSecondary.withOpacity(0.3),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "No tasks for today",
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...displayTasks.map((task) {
                final now = DateTime.now();
                // Check if task time is passed (using end time or start time? usually end time implies due)
                // User said "If those 3 tasks' time are passed from the current time then show 'due task'"
                // I'll use end time for "passed".
                final isPassed = task.endTime.isBefore(now);
                final isCompleted = task.isCompleted;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isCompleted
                          ? AppColors.accent.withOpacity(0.5)
                          : Colors.transparent,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Checkbox
                      GestureDetector(
                        onTap: () {
                          taskProvider.toggleTaskCompletion(task);
                        },
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompleted
                                ? AppColors.accent
                                : Colors.transparent,
                            border: Border.all(
                              color: isCompleted
                                  ? AppColors.accent
                                  : AppColors.textSecondary,
                              width: 2,
                            ),
                          ),
                          child: isCompleted
                              ? const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Task Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: AppTextStyles.body.copyWith(
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: isCompleted
                                    ? AppColors.textSecondary
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${TimeOfDay.fromDateTime(task.startTime).format(context)} - ${TimeOfDay.fromDateTime(task.endTime).format(context)}",
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                      // Status Label
                      if (!isCompleted)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isPassed
                                ? Colors.red.withOpacity(0.1)
                                : Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isPassed ? "Due Task" : "Task to do",
                            style: TextStyle(
                              color: isPassed ? Colors.red : Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
          ],
        );
      },
    );
  }

  Widget _buildUpcomingExamsSection() {
    return Consumer<ExamProvider>(
      builder: (context, examProvider, child) {
        final upcomingExams =
            examProvider.exams
                .where((exam) => exam.examDate.isAfter(DateTime.now()))
                .toList()
              ..sort((a, b) => a.examDate.compareTo(b.examDate));

        if (upcomingExams.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Upcoming Exams", style: AppTextStyles.heading2),
                  TextButton(
                    onPressed: () => onNavigateToTab(3),
                    child: const Text("View All"),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 48,
                      color: AppColors.textSecondary.withOpacity(0.3),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "No upcoming exams",
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        final topExams = upcomingExams.take(2).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Upcoming Exams", style: AppTextStyles.heading2),
                TextButton(
                  onPressed: () => onNavigateToTab(3),
                  child: const Text("View All"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...topExams.map((exam) {
              final daysLeft = exam.examDate.difference(DateTime.now()).inDays;

              Color statusColor;
              if (daysLeft <= 1) {
                statusColor = const Color(0xFFEF5350); // Soft Red
              } else if (daysLeft <= 2) {
                statusColor = const Color(0xFFFFCA28); // Yellow
              } else {
                statusColor = const Color(0xFF66BB6A); // Green
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: statusColor.withOpacity(0.5),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.school, color: statusColor),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exam.subject,
                            style: AppTextStyles.heading2.copyWith(
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${daysLeft <= 0 ? 'Today' : '$daysLeft days left'} • ${DateFormat('MMM d').format(exam.examDate)}",
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 12,
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildClassRoutineSection(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final routinePath = userProvider.user.classRoutinePath;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Class Routine", style: AppTextStyles.heading2),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ClassRoutineScreen(),
                  ),
                );
              },
              child: routinePath == null
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.05),
                            AppColors.accent.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.calendar_month_outlined,
                            size: 48,
                            color: AppColors.primary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Tap to view/upload routine",
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: FileImage(File(routinePath)),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.5),
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        alignment: Alignment.bottomLeft,
                        child: const Text(
                          "Tap to view routine",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickNotesSection(BuildContext context) {
    return Consumer<NotesProvider>(
      builder: (context, notesProvider, child) {
        final recentNotes = notesProvider.notes.take(3).toList();

        if (recentNotes.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Quick Notes", style: AppTextStyles.heading2),
                TextButton(
                  onPressed: () => onNavigateToTab(4),
                  child: const Text("View All"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: recentNotes.length,
                itemBuilder: (context, index) {
                  final note = recentNotes[index];
                  return Container(
                    width: 140,
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(note.colorValue),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.title,
                          style: AppTextStyles.heading2.copyWith(
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Text(
                          DateFormat(
                            'MMM d',
                          ).format(note.createdAt ?? DateTime.now()),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textPrimary.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCustomizeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Consumer<DashboardProvider>(
        builder: (context, dashboardProvider, child) {
          return AlertDialog(
            title: const Text("Customize Dashboard"),
            content: SizedBox(
              width: double.maxFinite,
              child: ReorderableListView.builder(
                shrinkWrap: true,
                itemCount: dashboardProvider.sections.length,
                onReorder: (oldIndex, newIndex) {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  dashboardProvider.reorderSections(oldIndex, newIndex);
                },
                itemBuilder: (context, index) {
                  final section = dashboardProvider.sections[index];
                  return ListTile(
                    key: ValueKey(section.id),
                    leading: Icon(_getSectionIcon(section.type)),
                    title: Text(_getSectionName(section.type)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_upward),
                          onPressed: index == 0
                              ? null
                              : () {
                                  dashboardProvider.reorderSections(
                                    index,
                                    index - 1,
                                  );
                                },
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_downward),
                          onPressed:
                              index == dashboardProvider.sections.length - 1
                              ? null
                              : () {
                                  dashboardProvider.reorderSections(
                                    index,
                                    index + 1,
                                  );
                                },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  dashboardProvider.resetToDefault();
                },
                child: const Text("Reset to Default"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Done"),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getSectionName(String type) {
    switch (type) {
      case DashboardSectionType.focusTimer:
        return 'Focus Timer';
      case DashboardSectionType.dailyTasks:
        return 'Daily Tasks';
      case DashboardSectionType.upcomingExams:
        return 'Upcoming Exams';
      case DashboardSectionType.classRoutine:
        return 'Class Routine';
      case DashboardSectionType.quickNotes:
        return 'Quick Notes';
      default:
        return 'Unknown';
    }
  }

  IconData _getSectionIcon(String type) {
    switch (type) {
      case DashboardSectionType.focusTimer:
        return Icons.timer;
      case DashboardSectionType.dailyTasks:
        return Icons.check_circle;
      case DashboardSectionType.upcomingExams:
        return Icons.school;
      case DashboardSectionType.classRoutine:
        return Icons.schedule;
      case DashboardSectionType.quickNotes:
        return Icons.note;
      default:
        return Icons.widgets;
    }
  }
}
