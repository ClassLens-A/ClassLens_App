import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'student_colors.dart';

class SubjectDetailScreen extends StatelessWidget {
  final Map<String, dynamic> subject;

  const SubjectDetailScreen({super.key, required this.subject});

  // Vyom's actual attendance history by subject (PRN: 8022054043)
  List<Map<String, dynamic>> _getHistory() {
    final subjectName = subject['name'] as String;
    
    if (subjectName.contains('Applied Mathematics')) {
      return [
        {"date": DateTime(2025, 11, 29, 0, 33), "status": "Present"},
        {"date": DateTime(2025, 11, 28, 23, 51), "status": "Present"},
        {"date": DateTime(2025, 11, 28, 23, 36), "status": "Present"},
        {"date": DateTime(2025, 11, 28, 17, 1), "status": "Present"},
        {"date": DateTime(2025, 11, 28, 16, 3), "status": "Present"},
        {"date": DateTime(2025, 11, 26, 15, 12), "status": "Present"},
        {"date": DateTime(2025, 11, 26, 15, 9), "status": "Present"},
        {"date": DateTime(2025, 11, 25, 16, 11), "status": "Present"},
        {"date": DateTime(2025, 11, 25, 16, 9), "status": "Absent"},
        {"date": DateTime(2025, 11, 25, 15, 58), "status": "Present"},
        {"date": DateTime(2025, 11, 25, 15, 53), "status": "Absent"},
        {"date": DateTime(2025, 11, 24, 0, 14), "status": "Present"},
        {"date": DateTime(2025, 11, 23, 23, 56), "status": "Present"},
        {"date": DateTime(2025, 11, 23, 23, 46), "status": "Absent"},
        {"date": DateTime(2025, 11, 23, 23, 43), "status": "Absent"},
        {"date": DateTime(2025, 11, 23, 20, 25), "status": "Present"},
        {"date": DateTime(2025, 11, 23, 20, 17), "status": "Absent"},
        {"date": DateTime(2025, 11, 23, 20, 12), "status": "Absent"},
        {"date": DateTime(2025, 11, 23, 20, 7), "status": "Absent"},
        {"date": DateTime(2025, 11, 23, 19, 54), "status": "Absent"},
        {"date": DateTime(2025, 11, 23, 19, 46), "status": "Absent"},
      ];
    } else if (subjectName.contains('Electronics')) {
      return [
        {"date": DateTime(2025, 11, 25, 23, 55), "status": "Absent"},
        {"date": DateTime(2025, 11, 25, 16, 16), "status": "Present"},
        {"date": DateTime(2025, 11, 24, 0, 16), "status": "Present"},
      ];
    }
    
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBackgroundColor,
      appBar: AppBar(
        title: Text(subject['name'], style: const TextStyle(color: primaryTextColor, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: primaryTextColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Stats Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF6E8CF3), accentColor]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: accentColor.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDetailStat("Total", "${subject['total']}"),
                  Container(width: 1, height: 40, color: Colors.white30),
                  _buildDetailStat("Attended", "${subject['attended']}"),
                  Container(width: 1, height: 40, color: Colors.white30),
                  _buildDetailStat("Percentage", "${subject['percentage'].toInt()}%"),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Icons.history, color: secondaryTextColor),
                const SizedBox(width: 8),
                const Text("Attendance Log", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryTextColor)),
                const Spacer(),
                Text("Teacher: ${subject['teacher']}", style: const TextStyle(fontSize: 12, color: secondaryTextColor)),
              ],
            ),
            const SizedBox(height: 12),

            // List of Sessions
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _getHistory().length,
              itemBuilder: (context, index) {
                final session = _getHistory()[index];
                bool isPresent = session['status'] == "Present";

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: cardBackgroundColor, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Text(DateFormat.yMMMd().format(session['date']), style: const TextStyle(fontWeight: FontWeight.bold, color: primaryTextColor)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: (isPresent ? successColor : attentionColor).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text(session['status'], style: TextStyle(color: isPresent ? successColor : attentionColor, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDetailStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
