/// Student profile data model
class StudentProfile {
  final String email;
  final String department;
  final String semester;
  final double attendancePercentage;
  final int totalClasses;

  const StudentProfile({
    required this.email,
    required this.department,
    required this.semester,
    required this.attendancePercentage,
    required this.totalClasses,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    // Ensure attendance_percentage is converted to double to handle both int and double from API
    final num attendancePercentageRaw = json['attendance_percentage'] is num
        ? json['attendance_percentage'] as num
        : 0.0;

    return StudentProfile(
      email: json['email'] ?? '',
      department: json['department'] ?? '',
      semester: json['semester'] ?? '',
      attendancePercentage: attendancePercentageRaw.toDouble(),
      totalClasses: json['total_classes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'department': department,
      'semester': semester,
      'attendance_percentage': attendancePercentage,
      'total_classes': totalClasses,
    };
  }
}
