import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/goal_provider.dart';
import '../models/goal_model.dart';
import '../widgets/theme_toggle_button.dart';

class WeeklyPlannerScreen extends StatefulWidget {
  const WeeklyPlannerScreen({super.key});

  @override
  State<WeeklyPlannerScreen> createState() => _WeeklyPlannerScreenState();
}

class _WeeklyPlannerScreenState extends State<WeeklyPlannerScreen> {
  final List<String> _days = [
    "Saturday",
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
  ];

  final List<Color> _dayColors = [
    const Color(0xFF9C27B0), // Purple
    const Color(0xFF673AB7), // Deep Purple
    const Color(0xFF3F51B5), // Indigo
    const Color(0xFF2196F3), // Blue
    const Color(0xFF009688), // Teal
    const Color(0xFF4CAF50), // Green
    const Color(0xFFFF9800), // Orange
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GoalProvider>(context, listen: false).fetchGoals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Goals'),
        actions: const [
          ThemeToggleButton(),
        ],
      ),
      body: Consumer<GoalProvider>(
        builder: (context, goalProvider, child) {
          if (goalProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _days.length,
            itemBuilder: (context, index) {
              final day = _days[index];
              final color = _dayColors[index];
              final dayGoals = goalProvider.goals
                  .where((goal) => goal.day == day)
                  .toList();

              return _buildDayCard(context, day, color, dayGoals);
            },
          );
        },
      ),
    );
  }

  Widget _buildDayCard(
    BuildContext context,
    String day,
    Color color,
    List<Goal> goals,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  day,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add_circle, color: color),
                  onPressed: () => _showAddGoalDialog(context, day),
                  tooltip: "Add Goal for $day",
                ),
              ],
            ),
          ),

          // Goals List
          if (goals.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  "No goals for $day",
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: goals.length,
              separatorBuilder: (context, index) =>
                  Divider(height: 1, color: Colors.grey[100]),
              itemBuilder: (context, index) {
                final goal = goals[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  leading: Transform.scale(
                    scale: 1.2,
                    child: Checkbox(
                      value: goal.isCompleted,
                      activeColor: color,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: (value) {
                        Provider.of<GoalProvider>(
                          context,
                          listen: false,
                        ).toggleGoalCompletion(goal);
                      },
                    ),
                  ),
                  title: Text(
                    goal.title,
                    style: TextStyle(
                      decoration: goal.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      color: goal.isCompleted ? Colors.grey : Colors.black87,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: Colors.blue,
                          size: 20,
                        ),
                        onPressed: () => _showEditGoalDialog(context, goal),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                        onPressed: () {
                          Provider.of<GoalProvider>(
                            context,
                            listen: false,
                          ).deleteGoal(goal.id!);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context, String day) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Goal for $day"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "What's your goal?",
            hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7)),
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final goal = Goal(
                  userId: 'local',
                  title: controller.text,
                  weekStartDate:
                      DateTime.now(), // Not strictly used for this view anymore
                  day: day,
                );
                Provider.of<GoalProvider>(context, listen: false).addGoal(goal);
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _showEditGoalDialog(BuildContext context, Goal goal) {
    final controller = TextEditingController(text: goal.title);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Goal"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "Update your goal",
            hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7)),
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                goal.title = controller.text;
                Provider.of<GoalProvider>(
                  context,
                  listen: false,
                ).updateGoal(goal);
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
