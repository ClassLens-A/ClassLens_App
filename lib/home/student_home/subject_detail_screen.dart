import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:classlens/api/api.dart';
import 'package:classlens/global/global.dart';
import 'student_colors.dart';

class SubjectDetailScreen extends StatefulWidget {
  final Map<String, dynamic> subject;

  const SubjectDetailScreen({super.key, required this.subject});

  @override
  State<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _attendanceHistory = [];
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadSubjectDetails();
  }

  Future<void> _loadSubjectDetails() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final studentId = await getStudentID();
      final subjectId = widget.subject['id'] ?? widget.subject['subject_id'];
      
      if (subjectId == null) {
        // If no subject ID, use the history data from the subject if available
        if (widget.subject['history'] != null) {
          setState(() {
            _attendanceHistory = List<Map<String, dynamic>>.from(widget.subject['history']);
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = 'No subject ID provided';
            _isLoading = false;
          });
        }
        return;
      }

      final result = await ApiServices.getSubjectAttendanceDetails(
        studentId: studentId,
        subjectId: subjectId,
      );

      if (result['status'] == true) {
        final data = result['data'];
        setState(() {
          _attendanceHistory = List<Map<String, dynamic>>.from(data['attendance_records'] ?? []);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = result['message'] ?? 'Failed to load subject details';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Network error. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBackgroundColor,
      appBar: AppBar(
        title: Text(widget.subject['name'], style: const TextStyle(color: primaryTextColor, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: primaryTextColor),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: accentColor))
          : _error.isNotEmpty
              ? _buildErrorState()
              : SingleChildScrollView(
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
                  _buildDetailStat("Total", "${widget.subject['total']}"),
                  Container(width: 1, height: 40, color: Colors.white30),
                  _buildDetailStat("Attended", "${widget.subject['attended']}"),
                  Container(width: 1, height: 40, color: Colors.white30),
                  _buildDetailStat("Percentage", "${widget.subject['percentage'].toInt()}%"),
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
                Text("Teacher: ${widget.subject['teacher']}", style: const TextStyle(fontSize: 12, color: secondaryTextColor)),
              ],
            ),
            const SizedBox(height: 12),

            // List of Sessions
            _attendanceHistory.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(Icons.inbox_outlined, size: 60, color: secondaryTextColor.withOpacity(0.3)),
                          const SizedBox(height: 16),
                          Text("No attendance records yet", style: TextStyle(color: secondaryTextColor.withOpacity(0.5))),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _attendanceHistory.length,
                    itemBuilder: (context, index) {
                      final session = _attendanceHistory[index];
                      final date = session['date'] is DateTime
                          ? session['date']
                          : DateTime.tryParse(session['date'].toString()) ?? DateTime.now();
                      bool isPresent = session['status'] == "Present";

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: cardBackgroundColor, borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            Text(DateFormat.yMMMd().format(date), style: const TextStyle(fontWeight: FontWeight.bold, color: primaryTextColor)),
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

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: attentionColor.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(_error, style: const TextStyle(color: secondaryTextColor)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadSubjectDetails,
            style: ElevatedButton.styleFrom(backgroundColor: accentColor),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
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
