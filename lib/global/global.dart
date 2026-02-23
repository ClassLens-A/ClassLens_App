import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:classlens/api/api.dart';

late String userName;
late int userID;
late Box classSessionBox;

// Keys for SharedPreferences
const String _keyRememberMe = "rememberMe";
const String _keyUserType = "userType"; // "student" or "teacher"

// Teacher keys
const String _keyTeacherName = "teacherName";
const String _keyTeacherID = "teacherID";

// Student keys
const String _keyStudentName = "studentName";
const String _keyStudentID = "studentID";
const String _keyStudentPRN = "studentPRN";

// ==================== Common ====================

Future<bool> getRememberMe() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.getBool(_keyRememberMe) ?? false;
}

Future<String?> getUserType() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.getString(_keyUserType);
}

Future<void> clearUserSession() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  await pref.clear();
}

// ==================== Teacher ====================

Future<String> getUserName() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.getString(_keyTeacherName) ?? "Teacher";
}

Future<int> getUserID() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.getInt(_keyTeacherID) ?? 0;
}

Future<void> saveTeacherSession({
  required bool rememberMe,
  required String teacherName,
  required int teacherID,
}) async {
  // Validate teacherID before storing
  if (teacherID <= 0) {
    throw ArgumentError('Invalid teacher ID: $teacherID. Teacher ID must be greater than 0.');
  }

  // Validate teacherName is not empty or whitespace only
  if (teacherName.trim().isEmpty) {
    throw ArgumentError('Teacher name cannot be empty.');
  }

  // Validate teacherName length (optional: reasonable limits)
  if (teacherName.trim().length < 2) {
    throw ArgumentError('Teacher name must be at least 2 characters long.');
  }

  if (teacherName.trim().length > 100) {
    throw ArgumentError('Teacher name cannot exceed 100 characters.');
  }

  SharedPreferences pref = await SharedPreferences.getInstance();
  await pref.setBool(_keyRememberMe, rememberMe);
  await pref.setString(_keyUserType, "teacher");
  await pref.setString(_keyTeacherName, teacherName.trim());
  await pref.setInt(_keyTeacherID, teacherID);
}

// ==================== Student ====================

Future<String> getStudentName() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.getString(_keyStudentName) ?? "Student";
}

Future<int> getStudentID() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.getInt(_keyStudentID) ?? 0;
}

Future<String> getStudentPRN() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.getString(_keyStudentPRN) ?? "";
}

Future<void> saveStudentSession({
  required bool rememberMe,
  required String studentName,
  required int studentID,
  required String prn,
}) async {
  // Validate studentID before storing
  if (studentID <= 0) {
    throw ArgumentError('Invalid student ID: $studentID. Student ID must be greater than 0.');
  }

  // Validate studentName is not empty or whitespace only
  if (studentName.trim().isEmpty) {
    throw ArgumentError('Student name cannot be empty.');
  }

  // Validate studentName length (optional: reasonable limits)
  if (studentName.trim().length < 2) {
    throw ArgumentError('Student name must be at least 2 characters long.');
  }

  if (studentName.trim().length > 100) {
    throw ArgumentError('Student name cannot exceed 100 characters.');
  }

  // Validate PRN is not empty or whitespace only
  if (prn.trim().isEmpty) {
    throw ArgumentError('Student PRN cannot be empty.');
  }

  // Validate PRN format (assuming numeric PRN)
  final prnInt = int.tryParse(prn.trim());
  if (prnInt == null || prnInt <= 0) {
    throw ArgumentError('Invalid PRN format: $prn. PRN must be a valid positive number.');
  }

  SharedPreferences pref = await SharedPreferences.getInstance();
  await pref.setBool(_keyRememberMe, rememberMe);
  await pref.setString(_keyUserType, "student");
  await pref.setString(_keyStudentName, studentName.trim());
  await pref.setInt(_keyStudentID, studentID);
  await pref.setString(_keyStudentPRN, prn.trim());
}

// ==================== FCM Notification Token ====================

/// Registers the FCM token for a student after login
Future<void> registerFCMToken(int studentId) async {
  try {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    
    // Request permission for notifications
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await messaging.getToken();
      
      if (token != null) {
        print("FCM Token: $token");
        await ApiServices.updateNotificationToken(
          studentId: studentId,
          notificationToken: token,
        );
      }
      
      // Listen for token refresh
      messaging.onTokenRefresh.listen((newToken) async {
        print("FCM Token refreshed: $newToken");
        final currentStudentId = await getStudentID();
        if (currentStudentId > 0) {
          await ApiServices.updateNotificationToken(
            studentId: currentStudentId,
            notificationToken: newToken,
          );
        }
      });
    } else {
      print("Notification permission denied");
    }
  } catch (e) {
    print("Error registering FCM token: $e");
  }
}

/// Removes the FCM token for a student on logout
Future<void> unregisterFCMToken() async {
  try {
    final studentId = await getStudentID();
    if (studentId > 0) {
      await ApiServices.removeNotificationToken(studentId: studentId);
    }
  } catch (e) {
    print("Error unregistering FCM token: $e");
  }
}