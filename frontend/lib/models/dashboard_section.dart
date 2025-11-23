class DashboardSection {
  final String id;
  final String type;
  int order;

  DashboardSection({required this.id, required this.type, required this.order});

  Map<String, dynamic> toJson() => {'id': id, 'type': type, 'order': order};

  factory DashboardSection.fromJson(Map<String, dynamic> json) =>
      DashboardSection(
        id: json['id'],
        type: json['type'],
        order: json['order'],
      );
}

class DashboardSectionType {
  static const String focusTimer = 'focus_timer';
  static const String quickOverview = 'quick_overview';
  static const String upcomingExams = 'upcoming_exams';
  static const String classRoutine = 'class_routine';
  static const String quickNotes = 'quick_notes';

  static List<DashboardSection> getDefaultSections() {
    return [
      DashboardSection(id: '1', type: focusTimer, order: 0),
      DashboardSection(id: '2', type: quickOverview, order: 1),
      DashboardSection(id: '3', type: upcomingExams, order: 2),
      DashboardSection(id: '4', type: classRoutine, order: 3),
      DashboardSection(id: '5', type: quickNotes, order: 4),
    ];
  }
}
