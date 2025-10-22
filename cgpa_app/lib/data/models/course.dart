// ---------------------
// 1.2 MODELS (lib/data/models/course.dart)
// ---------------------

class Course {
  String name;
  double credits;
  double grade; // e.g., 4.0 for A, 3.0 for B, etc.

  Course({required this.name, required this.credits, this.grade = 0.0});
}
