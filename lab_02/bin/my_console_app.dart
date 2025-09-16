import 'dart:io';
import 'dart:convert';

// ---------- Helper Functions ----------
String input(String prompt) {
  stdout.write(prompt);
  return stdin.readLineSync() ?? '';
}

int inputInt(String prompt) {
  while (true) {
    stdout.write(prompt);
    try {
      return int.parse(stdin.readLineSync() ?? '');
    } catch (_) {
      print('❌ Invalid number, try again.');
    }
  }
}

bool isEligible(int age) => age >= 18; // arrow function
int square(int n) => n * n;

Map<String, dynamic> inputData() {
  String name = input('Enter name: ');
  int age = inputInt('Enter age: ');
  String city = input('Enter city: ');

  // hobbies list
  stdout.write('Enter hobbies (comma separated): ');
  List<String> hobbies =
      (stdin.readLineSync() ?? '').split(',').map((h) => h.trim()).toList();

  // subjects set
  stdout.write('Enter subjects (comma separated): ');
  Set<String> subjects =
      (stdin.readLineSync() ?? '').split(',').map((s) => s.trim()).toSet();

  String roll = input('Enter roll number (optional, press Enter to skip): ');
  String dept = input('Enter department (optional, press Enter to skip): ');

  return {
    'name': name,
    'age': age,
    'city': city,
    'hobbies': hobbies,
    'subjects': subjects, // stored as Set
    'rollNumber': roll.isEmpty ? null : roll,
    'department': dept.isEmpty ? null : dept,
  };
}

void showData(List<Map<String, dynamic>> students) {
  if (students.isEmpty) {
    print('📭 No students found.');
    return;
  }

  for (var s in students) {
    print('\n--- Student Info ---');
    print('Name: ${s['name']}');
    print('Age: ${s['age']} (${isEligible(s['age']) ? "Adult" : "Underage"})');
    print('City: ${s['city']}');
    print('Hobbies: ${(s['hobbies'] as List).join(", ")}');
    print('Subjects: ${(s['subjects'] as Set).join(", ")}');
    if (s['rollNumber'] != null) print('Roll No: ${s['rollNumber']}');
    if (s['department'] != null) print('Department: ${s['department']}');
  }
}

void exportToJson(List<Map<String, dynamic>> students) {
  // Convert Sets to Lists for JSON compatibility
  var encodable = students.map((s) {
    return {
      'name': s['name'],
      'age': s['age'],
      'city': s['city'],
      'hobbies': s['hobbies'], // already List
      'subjects': (s['subjects'] as Set).toList(), // FIXED
      'rollNumber': s['rollNumber'],
      'department': s['department'],
    };
  }).toList();

  String jsonStr = jsonEncode(encodable);
  print('\n📦 Exported JSON Data:\n$jsonStr');
}

// ---------- Main ----------
void main() {
  List<Map<String, dynamic>> students = [];

  while (true) {
    print('\n===== Student Info Manager =====');
    print('1. Add Student');
    print('2. Show All Students');
    print('3. Export Data as JSON');
    print('4. Exit');

    String choice = input('Enter choice: ');

    switch (choice) {
      case '1':
        var student = inputData();
        students.add(student);
        print('✅ Student added successfully!');
        print('Square of age (demo arrow function): ${square(student['age'])}');
        break;

      case '2':
        showData(students);
        break;

      case '3':
        exportToJson(students);
        break;

      case '4':
        print('👋 Exiting program...');
        return;

      default:
        print('⚠️ Invalid choice. Try again.');
    }
  }
}
