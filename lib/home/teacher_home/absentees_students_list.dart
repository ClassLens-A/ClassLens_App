import 'package:classlens/data_models/class_session_data.dart';
import 'package:classlens/global/global.dart';
import 'package:flutter/material.dart';
import 'package:classlens/api/api.dart';
import 'package:classlens/data_models/absentees_student.dart';
import 'dart:ui';

import 'package:lottie/lottie.dart';

const Color primaryTextColor = Color(0xFF1A2533);
const Color secondaryTextColor = Color(0xFF6C757D);
const Color cardBackgroundColor = Colors.white;
const Color primaryBackgroundColor = Color(0xFFF0F4F8);
const Color accentColor = Color(0xFF4A90E2);
const Color attentionColor = Color(0xFFE53935);
const Color dividerColor = Color(0xFFE8E8E8);


const Color circleColor1 = Color.fromARGB(255, 178, 218, 255);
const Color circleColor2 = Color.fromARGB(255, 201, 247, 222);

// --- Color list for avatars ---
const List<Color> _avatarColors = [
  Color(0xFF6E8CF3), // Blue/Purple
  Color(0xFF20C997), // Green
  Color(0xFFFE924B), // Orange
  Color(0xFFF7678B), // Pink
  Color(0xFF4AC2E2), // Cyan
  Color(0xFF8B77E8), // Violet
  Color(0xFFE55C7A), // Raspberry
  Color(0xFFF3BF43), // Golden Yellow
];

class AbsenteesStudentList extends StatefulWidget {
  final int sessionID;
  final String subjectName;

  const AbsenteesStudentList({
    super.key,
    required this.sessionID,
    required this.subjectName,
  });

  @override
  State<AbsenteesStudentList> createState() => _AbsenteesStudentListState();
}

class _AbsenteesStudentListState extends State<AbsenteesStudentList> {
  List<AbsenteesStudents> _masterList = [];
  List<AbsenteesStudents> _filteredList = [];
  final Set<int> _selectedStudents = {};

  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
    _searchController.addListener(_filterStudents);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    if (mounted) setState(() { _isLoading = true; });
    _searchController.clear();
    _selectedStudents.clear();
    final students = await ApiServices.getAbsentStudents(sessionID: widget.sessionID);
    if (mounted) {
      setState(() {
        _masterList = students;
        _filteredList = students;
        _isLoading = false;
      });
    }
  }

  void _filterStudents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredList = _masterList.where((student) {
        return student.studentName.toLowerCase().contains(query) ||
            student.studentID.toString().contains(query) ||
            student.studentPRN.toString().contains(query);
      }).toList();
    });
  }

  void _onStudentTapped(int studentID) {
    setState(() {
      if (_selectedStudents.contains(studentID)) {
        _selectedStudents.remove(studentID);
      } else {
        _selectedStudents.add(studentID);
      }
    });
  }

  void _onClearPressed() {
    setState(() {
      _selectedStudents.clear();
    });
  }

  Future<void> _onSavePressed() async {
    print("Marking selected students as present: $_selectedStudents");
    bool result = await ApiServices.changeAttendance(sessionID: widget.sessionID, students: _selectedStudents.toList());

    if(result) {
      SessionStats? ss = classSessionBox.get(widget.sessionID);
      if(ss!=null) {
        ss.presentCount += _selectedStudents.length;
        ss.absentCount -= _selectedStudents.length;
        await ss.save();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Marked ${_selectedStudents.length} students as present."),
          backgroundColor: Colors.green,
        ),
      );
    }
    _loadStudents();
  }

  @override
  Widget build(BuildContext UBuildContext) {
    final screenSize = MediaQuery.of(context).size;
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    const buttonBarHeight = 90.0;

    return Scaffold(
      backgroundColor: primaryBackgroundColor,
      body: Stack(
        children: [

          Positioned(
            top: -screenSize.width * 0.3,
            left: -screenSize.width * 0.3,
            child: CircleAvatar(
              radius: screenSize.width * 0.45,
              backgroundColor: circleColor1.withOpacity(0.5),
            ),
          ),
          Positioned(
            bottom: -screenSize.width * 0.4,
            right: -screenSize.width * 0.4,
            child: CircleAvatar(
              radius: screenSize.width * 0.5,
              backgroundColor: circleColor2.withOpacity(0.5),
            ),
          ),


          Column(
            children: [

              SizedBox(height: kToolbarHeight + topPadding + 60.0),


              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadStudents,
                  color: accentColor,
                  child: _isLoading
                      ? Center(child: Lottie.asset('assets/animations/loading2.json',width: screenSize.width*0.8,height: screenSize.height*0.8,fit: BoxFit.contain))
                      : _filteredList.isEmpty
                      ? _buildEmptyState()
                      : _buildStudentList(buttonBarHeight + bottomPadding),
                ),
              ),
            ],
          ),


          _buildBlurredAppBar(context),

          _buildBlurredBottomBar(context, buttonBarHeight, bottomPadding),
        ],
      ),
    );
  }


  Widget _buildStudentList(double bottomPadding) {
    return ListView.builder(
      padding: EdgeInsets.only(top: 8.0, bottom: bottomPadding),
      itemCount: _filteredList.length,
      itemBuilder: (context, index) {
        final student = _filteredList[index];
        final isSelected = _selectedStudents.contains(student.studentID);

        final color = _avatarColors[index % _avatarColors.length];

        return Material(
          color: isSelected ? accentColor.withOpacity(0.1) : Colors.transparent,
          child: InkWell(
            onTap: () => _onStudentTapped(student.studentID),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Column(
                children: [
                  Row(
                    children: [

                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            student.studentName.isNotEmpty
                                ? student.studentName[0].toUpperCase()
                                : '',
                            style: TextStyle(
                              color: color, // Strong text color
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Text Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student.studentName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: primaryTextColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'ID: ${student.studentID} | PRN: ${student.studentPRN}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Checkbox Icon
                      Icon(
                        isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: isSelected ? accentColor : secondaryTextColor.withOpacity(0.5),
                        size: 26,
                      ),
                    ],
                  ),
                  if (index < _filteredList.length - 1)
                    Padding(
                      padding: const EdgeInsets.only(left: 60.0, top: 12.0),
                      child: Divider(color: dividerColor, height: 1),
                    )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        _searchController.text.isEmpty
            ? 'No absentees to mark present.'
            : 'No students found matching "${_searchController.text}".',
        style: const TextStyle(fontSize: 18, color: secondaryTextColor),
      ),
    );
  }


  Widget _buildBlurredAppBar(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Container(

            color: cardBackgroundColor.withOpacity(0.75),
            child: Column(
              children: [

                Container(
                  padding: EdgeInsets.only(top: topPadding, left: 4.0, right: 16.0),
                  height: kToolbarHeight + topPadding,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: primaryTextColor),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.subjectName,
                        style: const TextStyle(
                          color: primaryTextColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 12.0),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: primaryTextColor),
                    cursorColor: accentColor,
                    decoration: InputDecoration(
                      hintText: 'Search by name or ID...',
                      hintStyle: TextStyle(color: secondaryTextColor.withOpacity(0.7)),
                      prefixIcon: Icon(
                        Icons.search,
                        color: secondaryTextColor.withOpacity(0.7),
                      ),
                      filled: true,

                      fillColor: primaryBackgroundColor.withOpacity(0.7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(
                          color: cardBackgroundColor.withOpacity(0.5),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(
                          color: cardBackgroundColor.withOpacity(0.5),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(
                          color: accentColor,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBlurredBottomBar(BuildContext context, double height, double padding) {
    bool isSaveDisabled = _selectedStudents.isEmpty;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Container(
            padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, padding + 16.0),

            color: cardBackgroundColor.withOpacity(0.75),
            child: Row(
              children: [

                Expanded(
                  child: OutlinedButton(
                    onPressed: _onClearPressed,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: attentionColor,
                      side: const BorderSide(color: attentionColor, width: 2),
                      shape: const StadiumBorder(),

                      backgroundColor: cardBackgroundColor.withOpacity(0.8),
                    ),
                    child: const Text(
                      'Clear',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Save Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: isSaveDisabled ? null : _onSavePressed,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      disabledBackgroundColor: accentColor.withOpacity(0.4),
                      disabledForegroundColor: Colors.white.withOpacity(0.8),
                    ),
                    child: Text(
                      isSaveDisabled
                          ? 'Save'
                          : 'Save (${_selectedStudents.length})',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
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