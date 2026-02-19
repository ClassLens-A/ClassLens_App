/// Student dashboard data model
class StudentDashboard {
  final List<DashboardSubject> subjects;
  final List<RecentActivity> recentActivity;

  const StudentDashboard({
    required this.subjects,
    required this.recentActivity,
  });

  factory StudentDashboard.fromJson(Map<String, dynamic> json) {
    final subjectsData = json['subjects'] as List<dynamic>? ?? [];
    final recentActivityData = json['recent_activity'] as List<dynamic>? ?? [];

    return StudentDashboard(
      subjects: subjectsData
          .map((subject) => DashboardSubject.fromJson(subject as Map<String, dynamic>))
          .toList(),
      recentActivity: recentActivityData
          .map((activity) => RecentActivity.fromJson(activity as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subjects': subjects.map((s) => s.toJson()).toList(),
      'recent_activity': recentActivity.map((a) => a.toJson()).toList(),
    };
  }
}

/// Subject information in dashboard
class DashboardSubject {
  final int id;
  final String name;
  final String teacher;
  final int total;
  final int attended;
  final double percentage;

  const DashboardSubject({
    required this.id,
    required this.name,
    required this.teacher,
    required this.total,
    required this.attended,
    required this.percentage,
  });

  factory DashboardSubject.fromJson(Map<String, dynamic> json) {
    // Ensure percentage is converted to double
    final num percentageRaw = json['percentage'] is num
        ? json['percentage'] as num
        : 0.0;

    return DashboardSubject(
      id: json['id'] ?? json['subject_id'] ?? 0,
      name: json['name'] ?? '',
      teacher: json['teacher'] ?? '',
      total: json['total'] ?? 0,
      attended: json['attended'] ?? 0,
      percentage: percentageRaw.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'teacher': teacher,
      'total': total,
      'attended': attended,
      'percentage': percentage,
    };
  }
}

/// Recent activity item
class RecentActivity {
  final String date;
  final String subjectName;
  final String status;
  final String? time;

  const RecentActivity({
    required this.date,
    required this.subjectName,
    required this.status,
    this.time,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      date: json['date'] ?? '',
      subjectName: json['subject_name'] ?? json['subject'] ?? '',
      status: json['status'] ?? '',
      time: json['time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'subject_name': subjectName,
      'status': status,
      if (time != null) 'time': time,
    };
  }
}
