/// Attendance history response data model
class AttendanceHistory {
  final List<AttendanceRecord> attendanceRecords;

  const AttendanceHistory({
    required this.attendanceRecords,
  });

  factory AttendanceHistory.fromJson(Map<String, dynamic> json) {
    final recordsData = json['attendance_records'] as List<dynamic>? ?? [];

    return AttendanceHistory(
      attendanceRecords: recordsData
          .map((record) => AttendanceRecord.fromJson(record as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attendance_records': attendanceRecords.map((r) => r.toJson()).toList(),
    };
  }
}

/// Individual attendance record
class AttendanceRecord {
  final String date;
  final String subjectName;
  final String status;
  final String? time;

  const AttendanceRecord({
    required this.date,
    required this.subjectName,
    required this.status,
    this.time,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
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
