import 'dart:io';
import 'package:classlens/api/api.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Using consistent color constants from your app
const Color primaryTextColor = Color(0xFF1A2533);
const Color secondaryTextColor = Color(0xFF6C757D);

class ProcessingScreen extends StatefulWidget {
  final List<File> imageFiles;
  final String departmentName;
  final int semester;
  final int year;
  final String subject;
  final int subjectID;

  const ProcessingScreen({
    super.key,
    required this.imageFiles,
    required this.departmentName,
    required this.semester,
    required this.year,
    required this.subject,
    required this.subjectID
  });

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  @override
  void initState() {
    super.initState();
    _startUpload();
  }

  Future<void> _startUpload() async {
    try {

      Map<String,dynamic> returnedUrl = await ApiServices.markAttendance(
        imageFiles: widget.imageFiles,
        departmentName: widget.departmentName,
        semester: widget.semester,
        year: widget.year,
        subject: widget.subject,
        subjectID: widget.subjectID,

      );
      
      if (mounted) {

        String taskID = returnedUrl['task_id'];
        String message = returnedUrl['message'];
        Navigator.of(context).pop(taskID);
      }

    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop('Error: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF0F4F8), Color(0xFFD9E2EC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                const Text(
                  'Processing Attendance',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ),
                const SizedBox(height: 40),


                Lottie.asset(
                  'assets/animations/loading.json',
                  width: 200,
                  height: 200,
                ),

                const SizedBox(height: 40),


                const Text(
                  'This may take a moment. Please don\'t close the app.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}