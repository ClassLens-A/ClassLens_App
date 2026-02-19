/// Subject attendance details data model
class SubjectAttendance {
  final List<SubjectAttendanceRecord> attendanceRecords;

  const SubjectAttendance({
    required this.attendanceRecords,
  });

  factory SubjectAttendance.fromJson(Map<String, dynamic> json) {
    final recordsData = json['attendance_records'] as List<dynamic>? ?? [];

    return SubjectAttendance(
      attendanceRecords: recordsData
          .map((record) => SubjectAttendanceRecord.fromJson(record as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attendance_records': attendanceRecords.map((r) => r.toJson()).toList(),
    };
  }
}

/// Individual subject attendance record
class SubjectAttendanceRecord {
  final String date;
  final String status;

  const SubjectAttendanceRecord({
    required this.date,
    required this.status,
  });

  factory SubjectAttendanceRecord.fromJson(Map<String, dynamic> json) {
    return SubjectAttendanceRecord(
      date: json['date'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'status': status,
    };
  }
}
