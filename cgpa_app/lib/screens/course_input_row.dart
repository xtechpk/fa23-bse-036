import 'package:flutter/material.dart';
import '../data/models/course.dart';
import '../providers/cgpa_logic.dart';

// ---------------------
// 3.7 WIDGETS (lib/widgets/course_input_row.dart)
// ---------------------

class CourseInputRow extends StatelessWidget {
  final Course course;
  final ValueChanged<double> onGradeChanged;
  final ValueChanged<double> onCreditsChanged;
  final VoidCallback onRemove;

  const CourseInputRow({
    super.key,
    required this.course,
    required this.onGradeChanged,
    required this.onCreditsChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Course Name
        Expanded(
          flex: 4,
          child: TextFormField(
            initialValue: course.name,
            decoration: InputDecoration(
              labelText: 'Course Name',
              hintText: 'e.g., Calculus',
              isDense: true,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onChanged: (value) => course.name = value,
          ),
        ),
        const SizedBox(width: 8),

        // Credits Input
        Expanded(
          flex: 2,
          child: TextFormField(
            initialValue: course.credits.toString(),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Credits',
              isDense: true,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onChanged: (value) {
              final credits = double.tryParse(value) ?? 0.0;
              onCreditsChanged(credits);
            },
          ),
        ),
        const SizedBox(width: 8),

        // Grade Dropdown
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<String>(
            value: 'A',
            decoration: InputDecoration(
              labelText: 'Grade',
              isDense: true,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            items: ['A', 'B', 'C', 'D', 'F']
                .map((grade) => DropdownMenuItem(
                      value: grade,
                      child: Text(grade),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                // Use logic layer helper
                double gradePoint = CgpaCalculatorLogic.getGradePoint(value);
                onGradeChanged(gradePoint);
              }
            },
          ),
        ),

        // Remove Button
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onRemove,
        ),
      ],
    );
  }
}
