import 'dart:convert';
import 'dart:io';
import 'package:classlens/data_models/absentees_student.dart';
import 'package:classlens/data_models/subjects.dart';
import 'package:classlens/data_models/teacher_profile.dart';
import 'package:classlens/data_models/teacher_subjects.dart';
import 'package:http/http.dart' as http;
import 'package:classlens/data_models/departments.dart';
import 'package:classlens/data_models/task_status.dart';
import 'package:classlens/data_models/student_list.dart';
import 'package:classlens/global/config.dart';
import '../global/global.dart';


class ApiServices{
  static final String _baseUrl = AppConfig.baseUrl;

  static Future<List<Departments>> getDepartments() async{
    print("base url is $_baseUrl");

    String apiUrl = '$_baseUrl/getDepartments/';

    try{

      final response = await http.get(Uri.parse(apiUrl));

      if(response.statusCode == 200){
        final List<dynamic> jsonData = jsonDecode(response.body);
        List<Departments> departmentList = jsonData.map((json)=> Departments.fromJson(json as Map<String,dynamic>)).toList();
        return departmentList;
      }
      else{
        throw Exception('Failed to load Departments${response.statusCode}');
      }

    }
    catch(e){
      print(e.toString());
      throw Exception("Failed to load : ${e}");
    }
  }

  static Future<String?> signUpTeacher({required final String name, required String email, required String password,required String? departmentID}) async{

    String endpoint = "$_baseUrl/registerNewTeacher";
    final url = Uri.parse(endpoint);

    try{

      final headers = {
        'Content-Type': 'application/json; charset=UTF-8'
      };

     final body = jsonEncode({
       "name":name,
       "email":email,
       "password":password,
       "departmentID":departmentID
     });

     final response = await http.post(
       url,
       headers: headers,
       body: body
     );

     if(response.statusCode==201){
       print('Sign up successful!');
       return "success";
     }
     else{
       return "failed";
     }

    }
    catch(e){
      print(e.toString());
      return 'Could not connect to the server.';
    }
  }

  static Future<bool> sendOpt({required final String email}) async {
    String endpoint = "$_baseUrl/sendOtp";
    final url = Uri.parse(endpoint);

    try{

      const headers = {
        'Content-Type': 'application/json; charset=UTF-8'
      };

      final body = jsonEncode({
        "email":email
      });

      final response = await http.post(url,headers: headers,body: body);

      if(response.statusCode==200){
        print("mail sent");
        return Future.value(true);
      }
      else{
        print("mail not sent");
        return Future.value(false);
      }

    }
    catch(e){
      print(e.toString());
      return Future.value(false);
    }
  }

  static Future<bool> verifyOpt({required final String email, required final int otp})async{
    String endpoint = "$_baseUrl/verifyOtp";
    final url = Uri.parse(endpoint);

    try{
      const headers = {
        'Content-Type': 'application/json; charset=UTF-8'
      };

      final body = jsonEncode({
        "email":email,
        "otp":otp
      });

      final response = await http.post(url,headers: headers,body: body);

      if(response.statusCode==200){
        print("otp verified");
        return Future.value(true);
      }
      else{
        return Future.value(false);
      }
    }
    catch(e){
      print(e.toString());
      return Future.value(false);
    }
  }

  static Future<String> verifyEmail({required final String email}) async{
    String endpoint = "$_baseUrl/verifyEmail";
    final url = Uri.parse(endpoint);

    const headers ={
      'Content-Type': 'application/json; charset=UTF-8'
    };

    final body=jsonEncode({
      'email':email
    });

    try{
      final response = await http.post(url,headers: headers,body: body);

      if(response.statusCode==200){
        print("email verified");
        return Future.value("verified");
      }
      else{
        print("email not verified");
        final jsonBody = jsonDecode(response.body);
        return Future.value(jsonBody['detail']?? "No message");
      }

    }
    catch(e){
      print(e.toString());
      return Future.value(e.toString());
    }
  }

  static Future<bool> setPassword({required final String email, required final String password}) async{
    String endpoint = "$_baseUrl/setPassword";
    final url = Uri.parse(endpoint);

    const headers ={
      'Content-Type': 'application/json; charset=UTF-8'
    };

    final body=jsonEncode({
      'email':email,
      'password':password
    });

    try{
      final response = await http.post(url,headers: headers,body: body);

      if(response.statusCode==200){
        print("otp verified");
        return Future.value(true);
      }
      else{
        return Future.value(false);
      }
    }
    catch(e){
      print(e.toString());
      return Future.value(false);
    }
  }

  static Future<Map<String,dynamic>> validateTeacher({required final String email, required final String password}) async{
    String endpoint = "$_baseUrl/validateTeacher";
    final url = Uri.parse(endpoint);

    const headers = {
      'Content-Type': 'application/json; charset=UTF-8'
    };

    final body=jsonEncode({
      'email':email,
      'password':password

    });

    try{

      final response = await http.post(url,headers: headers,body: body);
      String jsonBody = response.body;
      String teacherName = jsonDecode(jsonBody)['teacher_name'];
      int teacherID = jsonDecode(jsonBody)['teacher_id'];
      String message = jsonDecode(jsonBody)['message'];
      if(response.statusCode==200){

        print("teacher validated successfully");

        return {'status':true,'teacherID':teacherID,'teacherName':teacherName,'message':message};
      }
      else{
        print("teacher validation failed");
        return {'status':false,'teacherName':'teacher','message':message};
      }

    }
    catch(e){
      print(e.toString());
      return {'status':false,'teacherName':'teacher','message':'exception'};
    }
  }

  static Future<List<Subjects>> getSubjects({required final String departmentName,required final int year, required final int semester}) async{
    String endpoint = '$_baseUrl/getSubjectDetails';
    final url = Uri.parse(endpoint);


    const headers = {
      'Content-Type': 'application/json; charset=UTF-8'
    };

    final body = jsonEncode({
      'department':departmentName,
      'year':year,
      'semester':semester
    });

    try{

      final response = await http.post(
          url,
          headers: headers,
          body: body
      );
      if(response.statusCode==200){
        final List<dynamic> jsonData = jsonDecode(response.body)['subjects'];
        return jsonData.map((json)=>Subjects.fromJson(json)).toList();
      }
      else{
        String message = jsonDecode(response.body)['detail'];
        print(message);
        return Future.value([]);
      }
    }
    catch(e){
      print(e.toString());
      throw Exception('Failed to connect to the server: $e');
    }
  }

  static Future<Map<String,dynamic>> markAttendance({required final File imageFile, required final String departmentName, required final int semester,required final int year, required final String subject,required final int subjectID}) async {
    String endpoint = '$_baseUrl/markAttendance';
    final url = Uri.parse(endpoint);
    try {
      final request = http.MultipartRequest('POST', url);

      request.fields['departmentName'] = departmentName;
      request.fields['semester'] = semester.toString();
      request.fields['year'] = year.toString();
      request.fields['subject'] = subject;
      request.fields["teacherID"]=userID.toString();
      request.fields["subjectID"]=subjectID.toString();
      print(subjectID);
      print(subject);

      request.files.add(
          await http.MultipartFile.fromPath(
              'photo',
              imageFile.path
          )
      );

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

  static Future<TaskStatus> checkTaskStatus({required taskID}) async{

    String endpoint = '$_baseUrl/attendanceStatus/$taskID/';

    final url =Uri.parse(endpoint);

    try{
      final response = await http.get(url);

      if(response.statusCode==200 || response.statusCode==202){
        final jsonBody = jsonDecode(response.body);
        return TaskStatus.fromJson(jsonBody);
      }
      else{
        throw Exception('Failed to check task status');
      }
    }
    catch(e){
      print(e.toString());
      return TaskStatus(status: "error", result: e.toString());
    }
  }

  static Future<List<TeacherSubjects>> getTeacherSubjects({required teacherID}) async{
    String endpoint = '$_baseUrl/getSubjects/';
    final url = Uri.parse(endpoint);

    const header ={
      'Content-Type': 'application/json; charset=UTF-8'
    };

    final body = jsonEncode({
      'teacher_id':teacherID
    });

    try{
      final response = await http.post(
          url,
          headers: header,
          body: body
      );

      if(response.statusCode==200){

        final jsonData = jsonDecode(response.body);
        final subjects = jsonData['subjects'];


        if(subjects!=null) {
          final List<dynamic> jsonData = jsonDecode(response.body)['subjects'];
          return jsonData.map((json)=>TeacherSubjects.fromJson(json)).toList();
        }
        return Future.value(List<TeacherSubjects>.empty());

      }
      else{
        print("error");
        return Future.value(List<TeacherSubjects>.empty());
      }

    }
    catch(e){
      print(e.toString());
      return Future.value(List<TeacherSubjects>.empty());
    }
  }

  static Future<List<StudentList>> getStudentList({required subjectID}) async{
    String endpoint = '$_baseUrl/students/attendance/';
    final url = Uri.parse(endpoint);

    const header ={
      'Content-Type': 'application/json; charset=UTF-8'
    };

    final body = jsonEncode({
      'subject_id':subjectID
    });

    try{
      final response = await http.post(
          url,
          headers: header,
          body: body
      );

      if(response.statusCode==200){
        final jsonBody = jsonDecode(response.body);

        final students = jsonBody['attendance'];

        if(students!=null){
          final List<dynamic> students = jsonBody['attendance'];
          return students.map((json)=>StudentList.fromJson(json)).toList();
        }
        else{
          return Future.value(List<StudentList>.empty());
        }
      }
      else{
        return Future.value(List<StudentList>.empty());
      }
    }
    catch(e){
      print(e);
      return Future.value(List<StudentList>.empty());
    }

  }

  static Future<List<AbsenteesStudents>> getAbsentStudents({required sessionID}) async{
    String endpoint = "$_baseUrl/getAbsenteesList/";
    final url = Uri.parse(endpoint);

    const header ={
      'Content-Type': 'application/json; charset=UTF-8'
    };

    final body = jsonEncode({
      'class_session_id':sessionID
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
          return students.map((json)=>AbsenteesStudents.fromJson(json)).toList();
        }
        else{
          return Future.value(List<AbsenteesStudents>.empty());
        }
      }
      else{
        print(response.body);
        return Future.value(List<AbsenteesStudents>.empty());
      }
    }
    catch(e){
      print(e.toString());
      return Future.value(List<AbsenteesStudents>.empty());
    }
  }

  static Future<bool> changeAttendance({required sessionID,required List<int> students})async{
    String endpoint = "$_baseUrl/changeAttendance/";
    final url = Uri.parse(endpoint);

    const header ={
      'Content-Type': 'application/json; charset=UTF-8'
    };

    final body = jsonEncode({
      'class_session_id':sessionID,
      'student_list':students
    });
    try{
      final response = await http.post(
        url,
        headers: header,
        body:body,
      );

      if(response.statusCode==200){
        return Future.value(true);
      }
      else{
        return Future.value(false);
      }

    }
    catch(e){
      print(e.toString());
      return Future.value(false);
    }
  }

  static Future<TeacherProfile> getTeacherProfile({required teacherID}) async{
    String endpoint = '$_baseUrl/teacherProfile/$teacherID';
    final url = Uri.parse(endpoint);

    try{

      final response = await http.get(url);
      if(response.statusCode==200){
        final jsonBody = jsonDecode(response.body);

        final profile = jsonBody["teacher_profile"];
        if(profile!=null){
          print(profile);
          return TeacherProfile.fromJson(profile);
        }
        else{
          return Future.value(TeacherProfile(name:"teacher",email: "null",totalSubjects: 0,totalStudents: 0,department: "null",dateJoined: DateTime.now()));
        }
      }
      else{
        return Future.value(TeacherProfile(name:"teacher",email: "null",totalSubjects: 0,totalStudents: 0,department: "null",dateJoined: DateTime.now()));
      }

    }
    catch(e){
      print(e.toString());
      return Future.value(TeacherProfile(name:"teacher",email: "null",totalSubjects: 0,totalStudents: 0,department: "null",dateJoined: DateTime.now()));
    }
  }
}