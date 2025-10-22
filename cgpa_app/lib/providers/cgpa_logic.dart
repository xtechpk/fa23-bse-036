// ---
// --- 2. LOGIC / PROVIDER LAYER (lib/providers/cgpa_logic.dart) ---
// ---

// This class encapsulates the business logic, simulating a change notifier/provider
import '../data/models/course.dart';

class CgpaCalculatorLogic {
  // Helper function to map letter grade to 4.0 scale
  static double getGradePoint(String letter) {
    switch (letter.toUpperCase()) {
      case 'A':
        return 4.0;
      case 'B':
        return 3.0;
      case 'C':
        return 2.0;
      case 'D':
        return 1.0;
      default:
        return 0.0; // F or not set
    }
  }

  static Map<String, double> calculateGpa({
    required List<Course> courses,
    required double? prevCgpa,
    required double? prevCredits,
  }) {
    double totalGradePoints = 0.0;
    double totalCredits = 0.0;

    // 1. Calculate Current Semester GPA
    for (var course in courses) {
      totalGradePoints += course.grade * course.credits;
      totalCredits += course.credits;
    }

    double semGpa = totalCredits > 0 ? totalGradePoints / totalCredits : 0.0;

    // 2. Calculate Cumulative CGPA
    double finalCgpa;

    // Check if optional previous data is valid for cumulative calculation
    if (prevCgpa != null && prevCredits != null && prevCredits > 0) {
      // Full Cumulative Formula: (Previous GP * Previous Credits + Current GP * Current Credits) / (Previous Credits + Current Credits)
      double prevGradePoints = prevCgpa * prevCredits;
      double currentGradePoints = semGpa * totalCredits;
      double finalTotalCredits = prevCredits + totalCredits;

      finalCgpa = finalTotalCredits > 0
          ? (prevGradePoints + currentGradePoints) / finalTotalCredits
          : semGpa;
    } else {
      // If optional data is missing or invalid, CGPA is just the current GPA.
      finalCgpa = semGpa;
    }

    return {
      'semesterGpa': semGpa,
      'cumulativeCgpa': finalCgpa,
    };
  }
}
