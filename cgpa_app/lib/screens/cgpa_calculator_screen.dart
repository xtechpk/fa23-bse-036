import 'package:flutter/material.dart';
import '../data/models/course.dart';
import '../providers/cgpa_logic.dart';
import '../data/models/user.dart';
import '../data/services/api_service.dart';
import 'course_input_row.dart';
import 'result_pill.dart';

// ---------------------
// 3.5 SCREENS (lib/screens/cgpa_calculator_screen.dart)
// ---------------------

class CgpaCalculatorScreen extends StatefulWidget {
  final User user;
  final ApiService authService;
  final VoidCallback onUpdate;

  const CgpaCalculatorScreen({
    super.key,
    required this.user,
    required this.authService,
    required this.onUpdate,
  });

  @override
  State<CgpaCalculatorScreen> createState() => _CgpaCalculatorScreenState();
}

class _CgpaCalculatorScreenState extends State<CgpaCalculatorScreen> {
  final List<Course> _courses = [Course(name: 'Course 1', credits: 3.0)];
  double _currentSemesterGpa = 0.0;
  double _cumulativeCgpa = 0.0;

  final TextEditingController _previousGpaController = TextEditingController();
  final TextEditingController _previousCreditsController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializePreviousGpa();
  }

  void _initializePreviousGpa() {
    final prevGpa = widget.user.cumulativeGpa;
    if (prevGpa != null) {
      _previousGpaController.text = prevGpa.toStringAsFixed(2);
      // Note: Previous credits would also be loaded from the real backend here.
    }
  }

  void _addCourse() {
    setState(() {
      _courses.add(Course(name: 'Course ${_courses.length + 1}', credits: 3.0));
    });
  }

  void _removeCourse(int index) {
    setState(() {
      _courses.removeAt(index);
      _calculateGpa();
    });
  }

  void _calculateGpa() {
    double? prevCgpa = double.tryParse(_previousGpaController.text);
    double? prevCredits = double.tryParse(_previousCreditsController.text);

    // Call the dedicated logic layer for calculation
    final results = CgpaCalculatorLogic.calculateGpa(
      courses: _courses,
      prevCgpa: prevCgpa,
      prevCredits: prevCredits,
    );

    setState(() {
      _currentSemesterGpa = results['semesterGpa']!;
      _cumulativeCgpa = results['cumulativeCgpa']!;
    });

    // Save previous CGPA to the mock database via API call
    widget.authService.updatePreviousCgpa(prevCgpa).then((_) {
      widget.onUpdate();
    }).catchError((e) {
      // In a real app, show a toast or message for the failed save
      ('Failed to save previous CGPA: $e');
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Previous Semester CGPA (Optional) Input Card ---
          Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            margin: const EdgeInsets.only(bottom: 20),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Previous Semester Data (Optional)',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _previousGpaController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Previous CGPA',
                            hintText: 'e.g., 3.5',
                            prefixIcon: Icon(Icons.star),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _previousCreditsController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Previous Total Credits',
                            hintText: 'e.g., 60.0',
                            prefixIcon: Icon(Icons.numbers),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // --- Current Semester Courses Input ---
          Text(
            'Current Semester Grades',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700),
          ),
          const SizedBox(height: 10),
          ..._courses.asMap().entries.map((entry) {
            int index = entry.key;
            Course course = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: CourseInputRow(
                key: ValueKey(course),
                course: course,
                onGradeChanged: (newGrade) {
                  course.grade = newGrade;
                },
                onCreditsChanged: (newCredits) {
                  course.credits = newCredits;
                },
                onRemove: () => _removeCourse(index),
              ),
            );
          }),

          // --- Add Course Button ---
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _addCourse,
              icon: const Icon(Icons.add, color: Colors.green),
              label: const Text('Add Course',
                  style: TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 20),

          // --- Calculate Button ---
          ElevatedButton.icon(
            onPressed: _calculateGpa,
            icon: const Icon(Icons.calculate),
            label: const Text('Calculate CGPA', style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(height: 30),

          // --- Results Display Card ---
          Card(
            color: Colors.green.shade700,
            elevation: 8,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ResultPill(
                    title: 'Semester GPA',
                    value: _currentSemesterGpa.toStringAsFixed(2),
                    color: Colors.green.shade200,
                  ),
                  ResultPill(
                    title: 'Cumulative CGPA',
                    value: _cumulativeCgpa.toStringAsFixed(2),
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
