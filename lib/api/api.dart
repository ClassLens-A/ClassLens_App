import 'dart:convert';
import 'dart:io';
import 'package:classlens/data_models/subjects.dart';
import 'package:classlens/data_models/teacher_profile.dart';
import 'package:classlens/data_models/teacher_subjects.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:classlens/data_models/departments.dart';
import 'package:classlens/data_models/task_status.dart';
import 'package:classlens/data_models/student_list.dart';
import 'package:classlens/data_models/student_profile.dart';
import 'package:classlens/data_models/student_dashboard.dart';
import 'package:classlens/data_models/attendance_history.dart';
import 'package:classlens/data_models/subject_attendance.dart';
import 'package:classlens/global/config.dart';
import '../data_models/present_absentees_student.dart';
import '../global/global.dart';

class ApiServices {
  static final String _baseUrl = AppConfig.baseUrl;

  static Future<List<Departments>> getDepartments() async {
    print("base url is $_baseUrl");

    String apiUrl = '$_baseUrl/getDepartments/';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        List<Departments> departmentList = jsonData
            .map((json) => Departments.fromJson(json as Map<String, dynamic>))
            .toList();
        return departmentList;
      } else {
        throw Exception('Failed to load Departments${response.statusCode}');
      }
    } catch (e) {
      print(e.toString());
      throw Exception("Failed to load : ${e}");
    }
  }

  static Future<String?> signUpTeacher({
    required final String name,
    required String email,
    required String password,
    required String? departmentID,
  }) async {
    String endpoint = "$_baseUrl/registerNewTeacher";
    final url = Uri.parse(endpoint);

    try {
      final headers = {'Content-Type': 'application/json; charset=UTF-8'};

      final body = jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "departmentID": departmentID,
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201) {
        print('Sign up successful!');
        return "success";
      } else {
        return "failed";
      }
    } catch (e) {
      print(e.toString());
      return 'Could not connect to the server.';
    }
  }

  static Future<bool> sendOpt({required final String email}) async {
    String endpoint = "$_baseUrl/sendOtp";
    final url = Uri.parse(endpoint);

    try {
      const headers = {'Content-Type': 'application/json; charset=UTF-8'};

      final body = jsonEncode({"email": email});

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        print("mail sent");
        return Future.value(true);
      } else {
        print("mail not sent");
        return Future.value(false);
      }
    } catch (e) {
      print(e.toString());
      return Future.value(false);
    }
  }

  static Future<bool> verifyOpt({
    required final String email,
    required final int otp,
  }) async {
    String endpoint = "$_baseUrl/verifyOtp";
    final url = Uri.parse(endpoint);

    try {
      const headers = {'Content-Type': 'application/json; charset=UTF-8'};

      final body = jsonEncode({"email": email, "otp": otp});

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        print("otp verified");
        return Future.value(true);
      } else {
        return Future.value(false);
      }
    } catch (e) {
      print(e.toString());
      return Future.value(false);
    }
  }

  static Future<String> verifyEmail({required final String email}) async {
    String endpoint = "$_baseUrl/verifyEmail";
    final url = Uri.parse(endpoint);

    const headers = {'Content-Type': 'application/json; charset=UTF-8'};

    final body = jsonEncode({'email': email});

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        print("email verified");
        return Future.value("verified");
      } else {
        print("email not verified");
        final jsonBody = jsonDecode(response.body);
        return Future.value(jsonBody['detail'] ?? "No message");
      }
    } catch (e) {
      print(e.toString());
      return Future.value(e.toString());
    }
  }

  static Future<bool> setPassword({
    required final String email,
    required final String password,
  }) async {
    String endpoint = "$_baseUrl/setPassword";
    final url = Uri.parse(endpoint);

    const headers = {'Content-Type': 'application/json; charset=UTF-8'};

    final body = jsonEncode({'email': email, 'password': password});

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        print("otp verified");
        return Future.value(true);
      } else {
        return Future.value(false);
      }
    } catch (e) {
      print(e.toString());
      return Future.value(false);
    }
  }

  static Future<Map<String, dynamic>> validateTeacher({
    required final String email,
    required final String password,
  }) async {
    String endpoint = "$_baseUrl/validateTeacher";
    final url = Uri.parse(endpoint);

    const headers = {'Content-Type': 'application/json; charset=UTF-8'};

    final body = jsonEncode({'email': email, 'password': password});

    try {
      final response = await http.post(url, headers: headers, body: body);
      String jsonBody = response.body;
      String teacherName = jsonDecode(jsonBody)['teacher_name'];
      int teacherID = jsonDecode(jsonBody)['teacher_id'];
      String message = jsonDecode(jsonBody)['message'];
      if (response.statusCode == 200) {
        print("teacher validated successfully");

        return {
          'status': true,
          'teacherID': teacherID,
          'teacherName': teacherName,
          'message': message,
        };
      } else {
        print("teacher validation failed");
        return {'status': false, 'teacherName': 'teacher', 'message': message};
      }
    } catch (e) {
      print(e.toString());
      return {
        'status': false,
        'teacherName': 'teacher',
        'message': 'exception',
      };
    }
  }

  static Future<List<Subjects>> getSubjects({
    required final String departmentName,
    required final int year,
    required final int semester,
  }) async {
    String endpoint = '$_baseUrl/getSubjectDetails';
    final url = Uri.parse(endpoint);

    const headers = {'Content-Type': 'application/json; charset=UTF-8'};

    final body = jsonEncode({
      'department': departmentName,
      'year': year,
      'semester': semester,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body)['subjects'];
        return jsonData.map((json) => Subjects.fromJson(json)).toList();
      } else {
        String message = jsonDecode(response.body)['detail'];
        print(message);
        return Future.value([]);
      }
    } catch (e) {
      print(e.toString());
      throw Exception('Failed to connect to the server: $e');
    }
  }

  static Future<Map<String,dynamic>> markAttendance({required final List<File> imageFiles, required final String departmentName, required final int semester,required final int year, required final String subject,required final int subjectID}) async {
    String endpoint = '$_baseUrl/markAttendance';
    final url = Uri.parse(endpoint);
    try {
      final request = http.MultipartRequest('POST', url);

      print(userID);

      request.fields['departmentName'] = departmentName;
      request.fields['semester'] = semester.toString();
      request.fields['year'] = year.toString();
      request.fields['subject'] = subject;
      request.fields["teacherID"]=userID.toString();
      request.fields["subjectID"]=subjectID.toString();
      print(subjectID);
      print(subject);

      for(var image in imageFiles) {
        request.files.add(
            await http.MultipartFile.fromPath(
                'photo',
                image.path
            )
        );
      }

      print("sent the request");
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print(response);

      if(response.statusCode==202){
        final responseData = json.decode(response.body);
        return {"message":responseData['message'],"task_id":responseData["task_id"]};
      }
      else{
        throw Exception('Failed to mark attendance: ${response.statusCode}');
      }
    }
    catch(e){
      print(e.toString());
      return {"message":e.toString()};
    }


  }

  static Future<TaskStatus> checkTaskStatus({required taskID}) async {
    String endpoint = '$_baseUrl/attendanceStatus/$taskID/';

    final url = Uri.parse(endpoint);

    try {
      final response = await http.get(url);

      if (response.statusCode == 200 || response.statusCode == 202) {
        final jsonBody = jsonDecode(response.body);
        return TaskStatus.fromJson(jsonBody);
      } else {
        throw Exception('Failed to check task status');
      }
    } catch (e) {
      print(e.toString());
      return TaskStatus(status: "error", result: e.toString());
    }
  }

  static Future<List<TeacherSubjects>> getTeacherSubjects({
    required teacherID,
  }) async {
    String endpoint = '$_baseUrl/getSubjects/';
    final url = Uri.parse(endpoint);

    const header = {'Content-Type': 'application/json; charset=UTF-8'};

    final body = jsonEncode({'teacher_id': teacherID});

    try {
      final response = await http.post(url, headers: header, body: body);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final subjects = jsonData['subjects'];

        if (subjects != null) {
          final List<dynamic> jsonData = jsonDecode(response.body)['subjects'];
          return jsonData
              .map((json) => TeacherSubjects.fromJson(json))
              .toList();
        }
        return Future.value(List<TeacherSubjects>.empty());
      } else {
        print("error");
        return Future.value(List<TeacherSubjects>.empty());
      }
    } catch (e) {
      print(e.toString());
      return Future.value(List<TeacherSubjects>.empty());
    }
  }

  static Future<List<StudentList>> getStudentList({required subjectID}) async {
    String endpoint = '$_baseUrl/students/attendance/';
    final url = Uri.parse(endpoint);

    const header = {'Content-Type': 'application/json; charset=UTF-8'};

    final body = jsonEncode({'subject_id': subjectID});

    try {
      final response = await http.post(url, headers: header, body: body);

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);

        final students = jsonBody['attendance'];

        if (students != null) {
          final List<dynamic> students = jsonBody['attendance'];
          return students.map((json) => StudentList.fromJson(json)).toList();
        } else {
          return Future.value(List<StudentList>.empty());
        }
      } else {
        return Future.value(List<StudentList>.empty());
      }
    } catch (e) {
      print(e);
      return Future.value(List<StudentList>.empty());
    }
  }

  static Future<List<PresentAbsenteesStudents>> getPresentAbsentStudents({required int sessionID,required bool isPresent}) async{
    String endpoint = "$_baseUrl/getPresentAbsentList/";
    final url = Uri.parse(endpoint);

    const header ={
      'Content-Type': 'application/json; charset=UTF-8'
    };

    final body = jsonEncode({
      'class_session_id':sessionID,
      'isPresent':isPresent
    });
    try{
      final response = await http.post(
          url,
          headers: header,
          body: body
      );

      if(response.statusCode==200){
        final jsonBody = jsonDecode(response.body);

        final students = jsonBody["students"];
        if(students!=null){
          final List<dynamic> students = jsonBody["students"];
          print(response.body);
          return students.map((json)=>PresentAbsenteesStudents.fromJson(json)).toList();
        }
        else{
          return Future.value(List<PresentAbsenteesStudents>.empty());
        }
      }
      else{
        print(response.body);
        return Future.value(List<PresentAbsenteesStudents>.empty());
      }
    }
    catch(e){
      print(e.toString());
      return Future.value(List<PresentAbsenteesStudents>.empty());
    }
  }

  static Future<bool> changeAttendance({
    required sessionID,
    required List<int> students,
  }) async {
    String endpoint = "$_baseUrl/changeAttendance/";
    final url = Uri.parse(endpoint);

    const header = {'Content-Type': 'application/json; charset=UTF-8'};

    final body = jsonEncode({
      'class_session_id': sessionID,
      'student_list': students,
    });
    try {
      final response = await http.post(url, headers: header, body: body);

      if (response.statusCode == 200) {
        return Future.value(true);
      } else {
        return Future.value(false);
      }
    } catch (e) {
      print(e.toString());
      return Future.value(false);
    }
  }

  static Future<TeacherProfile> getTeacherProfile({required teacherID}) async {
    String endpoint = '$_baseUrl/teacherProfile/$teacherID';
    final url = Uri.parse(endpoint);

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);

        final profile = jsonBody["teacher_profile"];
        if (profile != null) {
          print(profile);
          return TeacherProfile.fromJson(profile);
        } else {
          return Future.value(
            TeacherProfile(
              name: "teacher",
              email: "null",
              totalSubjects: 0,
              totalStudents: 0,
              department: "null",
              dateJoined: DateTime.now(),
            ),
          );
        }
      } else {
        return Future.value(
          TeacherProfile(
            name: "teacher",
            email: "null",
            totalSubjects: 0,
            totalStudents: 0,
            department: "null",
            dateJoined: DateTime.now(),
          ),
        );
      }
    } catch (e) {
      print(e.toString());
      return Future.value(
        TeacherProfile(
          name: "teacher",
          email: "null",
          totalSubjects: 0,
          totalStudents: 0,
          department: "null",
          dateJoined: DateTime.now(),
        ),
      );
    }
  }

  static Future<Map<String, dynamic>> validateStudent({
    required final int prn,
    required final String password,
  }) async {
    String endpoint = "$_baseUrl/validateStudent";
    final url = Uri.parse(endpoint);

    const headers = {'Content-Type': 'application/json; charset=UTF-8'};

    final body = jsonEncode({'prn': prn, 'password': password});

    try {
      final response = await http.post(url, headers: headers, body: body);
      String jsonBody = response.body;

      if (response.statusCode == 200) {
        var decoded = jsonDecode(jsonBody);
        String studentName = decoded['student_name'];
        int studentId = decoded['student_id'];
        int studentPrn = decoded['prn'];
        String message = decoded['message'];

        print("student validated successfully");
        print(message);
        return {
          'status': true,
          'studentName': studentName,
          'student_id': studentId,
          'prn': studentPrn,
          'message': message
        };
      } else {
        print("student validation failed");
        // Handle potential missing 'detail' key safely
        var decoded = jsonDecode(jsonBody);
        String detail = decoded is Map && decoded.containsKey('detail') 
            ? decoded['detail'] 
            : 'Validation failed';
        return {'status': false, 'studentName': 'student', 'student_id': 0, 'prn': 0, 'message': detail};
      }
    } catch (e) {
      print(e.toString());
      return {'status': false, 'studentName': 'student', 'student_id': 0, 'prn': 0, 'message': 'exception'};
    }
  }

  /// Fetches the student dashboard data including subjects and attendance
  static Future<Map<String, dynamic>> getStudentDashboard({
    required int studentId,
  }) async {
    // Validate studentId
    if (studentId <= 0) {
      return {
        'status': false,
        'message': 'Invalid student ID',
      };
    }

    String endpoint = "$_baseUrl/student/dashboard/";
    final url = Uri.parse(endpoint);

    const headers = {'Content-Type': 'application/json; charset=UTF-8'};
    final body = jsonEncode({'student_id': studentId});

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final dashboard = StudentDashboard.fromJson(jsonData);
        return {
          'status': true,
          'dashboard': dashboard,
          // Keep backward compatibility with existing code
          'data': jsonData,
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'status': false,
          'message': errorData['detail'] ?? 'Failed to load dashboard',
        };
      }
    } catch (e) {
      print("Error fetching student dashboard: $e");
      return {
        'status': false,
        'message': 'Network error. Please try again.',
      };
    }
  }

  static Future<Map<String, String>> verifyPRN({required int prn}) async {
    String endpoint = "$_baseUrl/verifyPRN";
    final url = Uri.parse(endpoint);

    const headers = {'Content-Type': 'application/json; charset=UTF-8'};

    final body = jsonEncode({'prn': prn});

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        print("PRN verified");
        var decoded = jsonDecode(response.body);
        print(decoded['email']);
        return {
          "status": "verified",
          "email": decoded['email'].toString(),
        };
      } else {
        final jsonBody = jsonDecode(response.body);
        print("PRN not verified");
        return {
          "status": "error",
          "message": jsonBody['detail'] ?? "Unknown error",
        };
      }
    } catch (e) {
      print(e.toString());
      return {"status": "error", "message": e.toString()};
    }
  }

  static Future<bool> registerStudent({
    required int prn,
    required String password,
    required List<int> photoBytes,
    required String photoFilename,
  }) async {
    try {
      String endpoint = "$_baseUrl/setPassword";
      final url = Uri.parse(endpoint);

      // Send as multipart/form-data
      final request = http.MultipartRequest('POST', url);
      request.fields['prn'] = prn.toString();
      request.fields['password'] = password;

      final multipartFile = http.MultipartFile.fromBytes(
        'photo',
        photoBytes,
        filename: photoFilename,
        contentType: MediaType('image', 'jpeg'), // Adjust if needed
      );
      request.files.add(multipartFile);

      print('Sending image to backend...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        print("Password set and student registered successfully");
        return true;
      } else {
        print("Failed to register student: ${response.statusCode}");
        print(response.body);
        return false;
      }
    } catch (e) {
      print("Error in registerStudent API call: $e");
      return false;
    }
  }

  /// Updates the FCM notification token for a student
  static Future<bool> updateNotificationToken({
    required int studentId,
    required String notificationToken,
  }) async {
    String endpoint = "$_baseUrl/student/notification-token/";
    final url = Uri.parse(endpoint);

    const headers = {'Content-Type': 'application/json; charset=UTF-8'};
    final body = jsonEncode({
      'student_id': studentId,
      'notification_token': notificationToken,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        print("Notification token updated successfully");
        return true;
      } else {
        print("Failed to update notification token: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error updating notification token: $e");
      return false;
    }
  }

  /// Removes the FCM notification token for a student (on logout)
  static Future<bool> removeNotificationToken({
    required int studentId,
  }) async {
    String endpoint = "$_baseUrl/student/notification-token/remove/";
    final url = Uri.parse(endpoint);

    const headers = {'Content-Type': 'application/json; charset=UTF-8'};
    final body = jsonEncode({'student_id': studentId});

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        print("Notification token removed successfully");
        return true;
      } else {
        print("Failed to remove notification token: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error removing notification token: $e");
      return false;
    }
  }

  /// Fetches student profile details
  static Future<Map<String, dynamic>> getStudentProfile({
    required int studentId,
  }) async {
    // Validate studentId
    if (studentId <= 0) {
      return {
        'status': false,
        'message': 'Invalid student ID',
      };
    }

    String endpoint = "$_baseUrl/student/profile/";
    final url = Uri.parse(endpoint);

    const headers = {'Content-Type': 'application/json; charset=UTF-8'};
    final body = jsonEncode({'student_id': studentId});

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final profile = StudentProfile.fromJson(jsonData);
        return {
          'status': true,
          'profile': profile,
          // Keep backward compatibility with existing code
          'data': jsonData,
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'status': false,
          'message': errorData['detail'] ?? 'Failed to load profile',
        };
      }
    } catch (e) {
      print("Error fetching student profile: $e");
      return {
        'status': false,
        'message': 'Network error. Please try again.',
      };
    }
  }

  /// Fetches student attendance history for a specific date range
  static Future<Map<String, dynamic>> getStudentAttendanceHistory({
    required int studentId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Validate studentId
    if (studentId <= 0) {
      return {
        'status': false,
        'message': 'Invalid student ID',
      };
    }

    // Validate date range
    if (endDate.isBefore(startDate)) {
      return {
        'status': false,
        'message': 'End date must be after start date',
      };
    }

    // Validate dates are not in the future
    final now = DateTime.now();
    if (startDate.isAfter(now) || endDate.isAfter(now)) {
      return {
        'status': false,
        'message': 'Dates cannot be in the future',
      };
    }

    String endpoint = "$_baseUrl/student/attendance/history/";
    final url = Uri.parse(endpoint);

    const headers = {'Content-Type': 'application/json; charset=UTF-8'};
    final body = jsonEncode({
      'student_id': studentId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final history = AttendanceHistory.fromJson(jsonData);
        return {
          'status': true,
          'history': history,
          // Keep backward compatibility with existing code
          'data': jsonData,
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'status': false,
          'message': errorData['detail'] ?? 'Failed to load attendance history',
        };
      }
    } catch (e) {
      print("Error fetching attendance history: $e");
      return {
        'status': false,
        'message': 'Network error. Please try again.',
      };
    }
  }

  /// Fetches detailed attendance for a specific subject
  static Future<Map<String, dynamic>> getSubjectAttendanceDetails({
    required int studentId,
    required int subjectId,
  }) async {
    // Validate studentId
    if (studentId <= 0) {
      return {
        'status': false,
        'message': 'Invalid student ID',
      };
    }

    // Validate subjectId
    if (subjectId <= 0) {
      return {
        'status': false,
        'message': 'Invalid subject ID',
      };
    }

    String endpoint = "$_baseUrl/student/subject/attendance/";
    final url = Uri.parse(endpoint);

    const headers = {'Content-Type': 'application/json; charset=UTF-8'};
    final body = jsonEncode({
      'student_id': studentId,
      'subject_id': subjectId,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final attendance = SubjectAttendance.fromJson(jsonData);
        return {
          'status': true,
          'attendance': attendance,
          // Keep backward compatibility with existing code
          'data': jsonData,
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'status': false,
          'message': errorData['detail'] ?? 'Failed to load subject details',
        };
      }
    } catch (e) {
      print("Error fetching subject attendance: $e");
      return {
        'status': false,
        'message': 'Network error. Please try again.',
      };
    }
  }
}
