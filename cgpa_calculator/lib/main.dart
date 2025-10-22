// This is the complete University Portal & CGPA Tracker application, now including
// a mock authentication system with Role-Based Access Control (RBAC), and enhanced responsiveness.

import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';
// The application now uses only system default fonts to avoid asset errors.

// --- ENUM: USER ROLES ---
enum UserRole { student, teacher, admin }

// --- CONSTANTS: GRADING SCHEME WEIGHTS ---

const Map<String, double> defaultWeights = {
  'Quiz': 0.10,
  'Assignment': 0.15,
  'Lab': 0.15,
  'Midterm': 0.20,
  'Final': 0.40,
};

// --- REALISM CONSTANT: MINIMUM SUBMISSIONS REQUIRED ---
const Map<String, int> minSubmissions = {
  'Quiz': 4, // Requires 4 quizzes to count toward final grade
  'Assignment': 4, // Requires 4 assignments
  'Lab': 4, // Requires 4 lab reports
  'Midterm': 1, // Midterm/Final are assumed to be a single event
  'Final': 1,
};

// --- GRADING & CALCULATION LOGIC ---

double _mapPercentageToGradePoints(double totalPercentage) {
  if (totalPercentage >= 90) return 4.0;
  if (totalPercentage >= 87) return 3.7;
  if (totalPercentage >= 83) return 3.3;
  if (totalPercentage >= 80) return 3.0;
  if (totalPercentage >= 77) return 2.7;
  if (totalPercentage >= 73) return 2.3;
  if (totalPercentage >= 70) return 2.0;
  if (totalPercentage >= 67) return 1.7;
  if (totalPercentage >= 60) return 1.0;
  return 0.0;
}

String _getLetterGrade(double gradePoints) {
  final gradeMap = {
    4.0: 'A',
    3.7: 'A-',
    3.3: 'B+',
    3.0: 'B',
    2.7: 'B-',
    2.3: 'C+',
    2.0: 'C',
    1.7: 'C-',
    1.0: 'D',
    0.0: 'F',
  };
  return gradeMap[gradePoints] ?? 'N/A';
}

// FIX: Calculation now enforces MINIMUM SUBMISSIONS for components to count.
double calculateCourseGradePoints(Course course) {
  double weightedScoreSum = 0;
  double totalWeightUsed = 0;

  defaultWeights.forEach((component, weight) {
    double score = course.rawScores[component] ?? 0;
    double max = course.maxScores[component] ?? 1;
    int minRequired = minSubmissions[component] ?? 1;
    int currentCount = course.submissionCounts[component] ?? 0;

    // Check 1: Must meet minimum submission count (e.g., 4 quizzes)
    // Check 2: Max score must be > 0 to avoid division by zero
    if (currentCount >= minRequired && max > 0) {
      // Component counts! Calculate weighted score.
      double componentPercentage = score / max;
      weightedScoreSum += componentPercentage * weight;
      totalWeightUsed += weight;
    } else {
      // Component does not count, but its weight is still part of the total potential weight.
      // We assume the total grade is calculated only based on *counted* components.
      // If totalWeightUsed is less than 1.0, the student is graded on a reduced total.
    }
  });

  if (totalWeightUsed == 0) {
    return 0.0;
  } // Avoid division by zero if nothing is counted

  // Final grade based on score earned divided by total weight of components counted
  double totalPercentage = (weightedScoreSum / totalWeightUsed) * 100;
  return _mapPercentageToGradePoints(totalPercentage);
}

double calculateGpa(Semester semester) {
  double totalQualityPoints = 0;
  double totalCredits = 0;

  for (var course in semester.courses) {
    final gradePoints = calculateCourseGradePoints(course);
    totalQualityPoints += course.credits * gradePoints;
    totalCredits += course.credits;
  }

  if (totalCredits == 0) return 0.0;
  return double.parse((totalQualityPoints / totalCredits).toStringAsFixed(2));
}

double calculateCgpa(List<Semester> semesters) {
  double totalQualityPoints = 0;
  double totalCredits = 0;

  for (var semester in semesters) {
    for (var course in semester.courses) {
      final gradePoints = calculateCourseGradePoints(course);
      totalQualityPoints += course.credits * gradePoints;
      totalCredits += course.credits;
    }
  }

  if (totalCredits == 0) return 0.0;
  return double.parse((totalQualityPoints / totalCredits).toStringAsFixed(2));
}

double calculateTotalCredits(List<Semester> semesters) {
  return semesters.fold(
      0.0,
      (sum, sem) =>
          sum + sem.courses.fold(0.0, (cSum, course) => cSum + course.credits));
}

// --- MODELS ---

class Course {
  String name;
  double credits;

  // RAW SCORE and MAX SCORE represent the TOTAL accumulated score for the component
  Map<String, double> rawScores;
  Map<String, double> maxScores;

  // FIX: New field to track individual submission counts
  Map<String, int> submissionCounts;

  final Key key;

  Course({
    this.name = 'New Course',
    this.credits = 3.0,
    Map<String, double>? rawScores,
    Map<String, double>? maxScores,
    Map<String, int>? submissionCounts,
  })  : rawScores = rawScores ??
            {
              'Quiz': 0,
              'Assignment': 0,
              'Lab': 0,
              'Midterm': 0,
              'Final': 0
            }, // Start at 0 for realism
        maxScores = maxScores ??
            {
              'Quiz': 40,
              'Assignment': 60,
              'Lab': 60,
              'Midterm': 50,
              'Final': 100
            }, // Total max possible
        // FIX: Initialize submission counts (0 for repeating, 1 for single exams)
        submissionCounts = submissionCounts ??
            {'Quiz': 0, 'Assignment': 0, 'Lab': 0, 'Midterm': 0, 'Final': 0},
        key = ValueKey(Random().nextDouble().toString() + name);

  Map<String, dynamic> toJson() => {
        'name': name,
        'credits': credits,
        'rawScores': rawScores,
        'maxScores': maxScores,
        'submissionCounts': submissionCounts, // Added to JSON
      };

  factory Course.fromJson(Map<String, dynamic> json) {
    Map<String, double> deserializeScores(Map<String, dynamic> scoreMap) {
      return scoreMap
          .map((k, v) => MapEntry(k, v is int ? v.toDouble() : v as double));
    }

    Map<String, int> deserializeCounts(Map<String, dynamic> countMap) {
      return countMap.map((k, v) => MapEntry(k, v as int));
    }

    return Course(
      name: json['name'] as String,
      credits: json['credits'] is int
          ? (json['credits'] as int).toDouble()
          : json['credits'] as double,
      rawScores: deserializeScores(json['rawScores'] as Map<String, dynamic>),
      maxScores: deserializeScores(json['maxScores'] as Map<String, dynamic>),
      submissionCounts:
          deserializeCounts(json['submissionCounts'] as Map<String, dynamic>),
    );
  }
}

class Semester {
  String name;
  List<Course> courses;
  final Key key;

  Semester({required this.name, required this.courses})
      : key = ValueKey(name + Random().nextDouble().toString());

  Map<String, dynamic> toJson() => {
        'name': name,
        'courses': courses.map((c) => c.toJson()).toList(),
      };

  factory Semester.fromJson(Map<String, dynamic> json) {
    return Semester(
      name: json['name'] as String,
      courses: (json['courses'] as List<dynamic>)
          .map((cJson) => Course.fromJson(cJson as Map<String, dynamic>))
          .toList(),
    );
  }
}

// --- MAIN APP ENTRY POINT ---

void main() {
  runApp(const UniPortalApp());
}

class UniPortalApp extends StatelessWidget {
  const UniPortalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'University Portal System',
      theme: ThemeData(
        useMaterial3: true,
        // FIX CONFIRMED: Using null explicitly uses the default system font,
        fontFamily: null,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00509D),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
        ),
        cardTheme: CardTheme(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      home: const UniPortalMainScreen(),
    );
  }
}

// --- PORTAL MAIN SCREEN (Manages Navigation and Shared State) ---

class UniPortalMainScreen extends StatefulWidget {
  const UniPortalMainScreen({super.key});

  @override
  State<UniPortalMainScreen> createState() => _UniPortalAppState();
}

class _UniPortalAppState extends State<UniPortalMainScreen> {
  static const String _dataKey = 'cgpa_data_v2';
  static const String _authKey = 'user_id';

  bool _isLoading = true;
  int _selectedIndex = 0;

  // --- AUTH STATE ---
  bool _isAuthenticated = false;
  String? _currentUserId;
  UserRole _currentUserRole = UserRole.student; // Default role
  // --- END AUTH STATE ---

  List<Semester> semesters = [
    Semester(
      name: 'Current Semester (Fall 2025)',
      courses: [
        // Default course data starts with 0 scores for realism
        Course(name: 'Software Engineering', credits: 4.0),
        Course(name: 'Database Systems', credits: 3.0),
        Course(name: 'Elective: AI Ethics', credits: 3.0),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  // --- AUTHENTICATION LOGIC (MOCK) ---

  Future<String?> _getSavedUserId() async {
    debugPrint('MOCK: Checking saved user ID for key: $_authKey');
    return null;
  }

  Future<void> _setSavedUserId(String userId) async {
    debugPrint('MOCK: Saving user ID: $userId to key: $_authKey');
  }

  // MOCK: Assigns role based on ID for demonstration
  UserRole _getRoleFromUserId(String userId) {
    if (userId.startsWith('A')) return UserRole.admin;
    if (userId.startsWith('T')) return UserRole.teacher;
    return UserRole.student;
  }

  void _checkAuthStatus() async {
    final savedUserId = await _getSavedUserId();

    setState(() {
      if (savedUserId != null && savedUserId.isNotEmpty) {
        _currentUserId = savedUserId;
        _currentUserRole = _getRoleFromUserId(savedUserId);
        _isAuthenticated = true;
      }
      _isLoading = false;
    });

    if (_isAuthenticated) {
      _loadData();
    }
  }

  void login(String userId) {
    final role = _getRoleFromUserId(userId);
    _setSavedUserId(userId);
    setState(() {
      _currentUserId = userId;
      _currentUserRole = role;
      _isAuthenticated = true;
      _isLoading = true;
    });
    _loadData();
  }

  void logout() {
    _setSavedUserId('');
    setState(() {
      _currentUserId = null;
      _isAuthenticated = false;
      _currentUserRole = UserRole.student;
      semesters = [];
      _selectedIndex = 0; // Reset to dashboard/login
    });
  }

  // --- PERSISTENCE LOGIC ---

  Future<String?> _getSavedData() async {
    debugPrint('MOCK: Attempting to retrieve data for key: $_dataKey');
    return null;
  }

  Future<void> _setSavedData(String json) async {
    debugPrint('MOCK: Saving data to key: $_dataKey');
  }

  void _loadData() async {
    final data = await _getSavedData();
    List<Semester> loadedSemesters = [];

    if (data != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(data);
        loadedSemesters = jsonList
            .map((sJson) => Semester.fromJson(sJson as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('Error decoding saved data: $e');
      }
    }

    setState(() {
      if (loadedSemesters.isNotEmpty) {
        semesters = loadedSemesters;
      } else {
        semesters = [
          Semester(
              name: 'Current Semester (Fall 2025)',
              courses: [Course(name: 'Placeholder Course', credits: 3.0)])
        ];
      }
      _isLoading = false;
    });
  }

  void _saveData() async {
    if (!_isAuthenticated) return;
    final jsonString = jsonEncode(semesters.map((s) => s.toJson()).toList());
    await _setSavedData(jsonString);
  }

  // --- STATE MUTATORS (Passed to child widgets) ---
  void _addSemester() {
    setState(() {
      semesters.add(
        Semester(
          name: 'Semester ${semesters.length + 1} (New Record)',
          courses: [Course()],
        ),
      );
      _saveData();
    });
  }

  void _addCourse(int semesterIndex) {
    setState(() {
      semesters[semesterIndex].courses.add(Course());
      _saveData();
    });
  }

  // FIX: Added new method to update score and max score for a component
  void _updateComponentScores(int semIndex, int courseIndex, String component,
      double newScore, double newMaxScore) {
    setState(() {
      final course = semesters[semIndex].courses[courseIndex];
      course.rawScores[component] = newScore;
      course.maxScores[component] = newMaxScore;
      _saveData();
    });
  }

  // FIX: Added new method to increment submission count
  void _incrementSubmissionCount(
      int semIndex, int courseIndex, String component) {
    setState(() {
      final course = semesters[semIndex].courses[courseIndex];
      course.submissionCounts[component] =
          (course.submissionCounts[component] ?? 0) + 1;
      _saveData();
    });
  }

  // Existing update method simplified for non-score updates
  void _updateCourse(int semIndex, int courseIndex,
      {String? name, double? credits}) {
    setState(() {
      final course = semesters[semIndex].courses[courseIndex];
      if (name != null) {
        course.name = name;
      }
      if (credits != null) {
        course.credits = credits;
      }
      _saveData();
    });
  }

  void _renameSemester(int semIndex, String newName) {
    setState(() {
      semesters[semIndex].name = newName;
      _saveData();
    });
  }

  void _deleteSemester(int semIndex) {
    setState(() {
      semesters.removeAt(semIndex);
      _saveData();
    });
  }

  void deleteCourse(int semIndex, int courseIndex) {
    setState(() {
      semesters[semIndex].courses.removeAt(courseIndex);
      _saveData();
    });
  }

  // --- SCREEN BUILDER ---
  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated || _isLoading) {
      return AuthGate(
        isAuthenticated: _isAuthenticated,
        isLoading: _isLoading,
        login: login,
      );
    }

    // Define pages based on role access
    final List<Widget> pages = <Widget>[
      if (_currentUserRole == UserRole.admin) const AdminPanelScreen(),
      if (_currentUserRole == UserRole.student ||
          _currentUserRole == UserRole.teacher)
        DashboardScreen(semesters: semesters, role: _currentUserRole),
      CourseManagerScreen(
        semesters: semesters,
        addSemester: _addSemester,
        addCourse: _addCourse,
        updateCourse: _updateCourse,
        renameSemester: _renameSemester,
        deleteSemester: _deleteSemester,
        deleteCourse: deleteCourse,
        updateComponentScores: _updateComponentScores, // Pass new method
        incrementSubmissionCount: _incrementSubmissionCount, // Pass new method
        isTeacherOrAdmin: _currentUserRole !=
            UserRole.student, // Allow teachers/admins to modify marks
      ),
      ProfileScreen(
        userId: _currentUserId,
        role: _currentUserRole,
        logout: logout,
      ),
    ];

    // Define navigation items based on role access
    List<BottomNavigationBarItem> navItems = [
      if (_currentUserRole == UserRole.admin)
        const BottomNavigationBarItem(
            icon: Icon(Icons.security), label: 'Admin'),
      if (_currentUserRole == UserRole.student ||
          _currentUserRole == UserRole.teacher)
        const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard), label: 'Dashboard'),
      const BottomNavigationBarItem(
          icon: Icon(Icons.calculate), label: 'Courses'),
      const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
    ];

    // Adjust selected index if an admin is viewing, as the dashboard is skipped
    final int effectiveIndex = _currentUserRole == UserRole.admin
        ? _selectedIndex.clamp(0, navItems.length - 1)
        : _selectedIndex.clamp(0, navItems.length - 1);

    // Prevent navigating to non-existent screens after a role change
    if (effectiveIndex >= pages.length) {
      // If the current index is out of bounds (e.g., switched from Student to Admin), reset to 0
      WidgetsBinding.instance
          .addPostFrameCallback((_) => setState(() => _selectedIndex = 0));
      return const Scaffold(
          body: Center(child: Text("Switching portal view...")));
    }

    return Scaffold(
      body: pages[effectiveIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: effectiveIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: navItems,
      ),
    );
  }
}

// --------------------------------------------------------------------------
// --- AUTHENTICATION SCREENS (No change) ---
// --------------------------------------------------------------------------

class AuthGate extends StatelessWidget {
  final bool isAuthenticated;
  final bool isLoading;
  final Function(String) login;

  const AuthGate({
    super.key,
    required this.isAuthenticated,
    required this.isLoading,
    required this.login,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Checking credentials...')
            ],
          ),
        ),
      );
    }

    return LoginScreen(login: login);
  }
}

class LoginScreen extends StatefulWidget {
  final Function(String) login;
  const LoginScreen({super.key, required this.login});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Use responsive padding for controllers
  final _emailController = TextEditingController(text: 'student@uni.edu');
  final _passwordController = TextEditingController(text: 'password');
  final _formKey = GlobalKey<FormState>();

  // MOCK: Fixed mock IDs for demonstration of role-based access
  final Map<String, String> mockUsers = {
    'student@uni.edu': 'S20220101', // Student Role
    'teacher@uni.edu': 'T80001001', // Teacher Role
    'admin@uni.edu': 'A90000001', // Admin Role
  };

  void _attemptLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text;

      // MOCK: Check if email is in the mock user list
      final mockUserId = mockUsers[email.toLowerCase()];

      if (mockUserId != null) {
        // --- FIX: Explicitly assign role for display confirmation ---
        final assignedRole = context
            .findAncestorStateOfType<_UniPortalAppState>()
            ?._getRoleFromUserId(mockUserId);

        // Call the login function in the main state
        widget.login(mockUserId);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Login successful! Assigned Role: ${assignedRole?.toString().split('.').last.toUpperCase() ?? 'STUDENT'}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Login failed: Invalid credentials or account type.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Determine screen size for responsive width constraint
    final double screenWidth = MediaQuery.of(context).size.width;
    final double maxFormWidth = screenWidth > 600 ? 400.0 : screenWidth * 0.9;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: ConstrainedBox(
            // Constrain form width on large screens
            constraints: BoxConstraints(maxWidth: maxFormWidth),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'University Portal Login',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText:
                          'ID / Email (Hint: student@uni.edu, teacher@uni.edu, admin@uni.edu)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your ID' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your password' : null,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _attemptLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('LOGIN', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const RegistrationScreen()));
                    },
                    child: Text(
                      'New Student? Register Here',
                      style: TextStyle(color: colorScheme.secondary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Student Registration'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.onSecondary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Registration is currently handled by the Admissions Office.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              const Text('Please contact support for manual account creation.'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------------------------------
// --- SCREEN 0 (ADMIN): ADMIN PANEL (Enhanced Mock Functionality) ---
// --------------------------------------------------------------------------

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Portal: User Management'),
        backgroundColor: colorScheme.error,
        foregroundColor: colorScheme.onError,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Administrator Access',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: colorScheme.onErrorContainer),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Mock Management Actions',
                style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            _buildAdminActionTile(
                context,
                'Manage User Accounts',
                'View, add, and modify user roles and permissions.',
                Icons.people,
                colorScheme.primary),
            _buildAdminActionTile(
                context,
                'System Logs & Audit',
                'Access real-time system logs and performance data.',
                Icons.analytics,
                colorScheme.primary),
            _buildAdminActionTile(
                context,
                'Course Catalog Approval',
                'Approve new course additions and updates.',
                Icons.library_books,
                colorScheme.primary),
            const SizedBox(height: 24),
            Text('Quick Status', style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            _buildStatusCard(
                context, 'Total Users', '3 (Mocked)', Icons.verified_user),
            _buildStatusCard(context, 'Active Sessions', '78',
                Icons.online_prediction, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminActionTile(BuildContext context, String title,
      String subtitle, IconData icon, Color color) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Action: $title triggered (Mocked).')));
        },
      ),
    );
  }

  Widget _buildStatusCard(
      BuildContext context, String title, String value, IconData icon,
      [Color? color]) {
    final theme = Theme.of(context);
    final displayColor = color ?? theme.colorScheme.secondary;
    return Card(
      color: displayColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: displayColor, size: 30),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                Text(value,
                    style: TextStyle(fontSize: 16, color: displayColor)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------------------------------
// --- SCREEN 1: DASHBOARD (No functional change) ---
// --------------------------------------------------------------------------

class DashboardScreen extends StatelessWidget {
  final List<Semester> semesters;
  final UserRole role; // Added role
  const DashboardScreen(
      {super.key, required this.semesters, required this.role});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final totalCgpa = calculateCgpa(semesters);
    final totalCredits = calculateTotalCredits(semesters);
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;

    final roleString = role.toString().split('.').last.toUpperCase();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Welcome Card ---
            Card(
              color: colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // FIX: Simplified interpolation
                    Text(
                      'Welcome Back, $roleString!',
                      style: TextStyle(
                        fontSize: isLargeScreen ? 28 : 24,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Chip(
                      // Highlight the user's role
                      label: Text(
                          '$roleString PORTAL ACCESS'), // FIX: Simplified interpolation
                      backgroundColor: role == UserRole.teacher
                          ? Colors.amber.shade200
                          : colorScheme.primaryContainer,
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: role == UserRole.teacher
                            ? Colors.brown.shade800
                            : colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'View your academic progress and register for new assignments.',
                      style: TextStyle(
                        color:
                            colorScheme.onSecondaryContainer.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- CGPA & Credits Summary (Responsive Layout) ---
            LayoutBuilder(
              builder: (context, constraints) {
                final useRow = constraints.maxWidth > 600;
                return useRow
                    ? Row(
                        children: [
                          Expanded(
                              child: _buildSummaryCard(
                                  context,
                                  'CGPA',
                                  totalCgpa.toStringAsFixed(2),
                                  Icons.school,
                                  totalCgpa >= 3.0
                                      ? Colors.green
                                      : colorScheme.primary)),
                          const SizedBox(width: 16),
                          Expanded(
                              child: _buildSummaryCard(
                                  context,
                                  'Total Credits',
                                  totalCredits.toStringAsFixed(1),
                                  Icons.bookmark_added,
                                  colorScheme.tertiary)),
                        ],
                      )
                    : Column(
                        children: [
                          _buildSummaryCard(
                              context,
                              'CGPA',
                              totalCgpa.toStringAsFixed(2),
                              Icons.school,
                              totalCgpa >= 3.0
                                  ? Colors.green
                                  : colorScheme.primary),
                          const SizedBox(height: 16),
                          _buildSummaryCard(
                              context,
                              'Total Credits',
                              totalCredits.toStringAsFixed(1),
                              Icons.bookmark_added,
                              colorScheme.tertiary),
                        ],
                      );
              },
            ),
            const SizedBox(height: 24),

            // --- Current Semester Record ---
            Text('Semester Records',
                style: Theme.of(context).textTheme.titleLarge),
            const Divider(),

            ...semesters.map((semester) {
              final gpa = calculateGpa(semester);
              return Card(
                child: ListTile(
                  title: Text(semester.name,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${semester.courses.length} Courses'),
                  trailing: Text(
                    'GPA: ${gpa.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: gpa >= 3.0
                          ? Colors.green.shade700
                          : colorScheme.primary,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(value,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    )),
            Text(title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    )),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------------------------------
// --- SCREEN 2: COURSE MANAGER (Mark Input/View) ---
// --------------------------------------------------------------------------

class CourseManagerScreen extends StatelessWidget {
  final List<Semester> semesters;
  final Function addSemester;
  final Function addCourse;
  final Function updateCourse;
  final Function renameSemester;
  final Function deleteSemester;
  final Function deleteCourse;
  final Function updateComponentScores; // New update method
  final Function incrementSubmissionCount; // New increment method
  final bool isTeacherOrAdmin;

  const CourseManagerScreen({
    super.key,
    required this.semesters,
    required this.addSemester,
    required this.addCourse,
    required this.updateCourse,
    required this.renameSemester,
    required this.deleteSemester,
    required this.deleteCourse,
    required this.updateComponentScores, // Required
    required this.incrementSubmissionCount, // Required
    required this.isTeacherOrAdmin,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final totalCgpa = calculateCgpa(semesters);

    return Scaffold(
      appBar: AppBar(
        title: Text(isTeacherOrAdmin
            ? 'Mark Entry Portal'
            : 'Course & Assignment Manager'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        actions: [
          if (isTeacherOrAdmin)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Chip(
                label: const Text('Teacher/Admin View'),
                backgroundColor: colorScheme.tertiaryContainer,
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: colorScheme.tertiaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Current CGPA: ${totalCgpa.toStringAsFixed(2)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onTertiaryContainer,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            ...semesters.asMap().entries.map((entry) {
              final semIndex = entry.key;
              final semester = entry.value;
              final semesterGpa = calculateGpa(semester);

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _buildSemesterCard(
                    context, semIndex, semester, semesterGpa, colorScheme),
              );
            }),

            // Hide add semester for non-admin/non-teacher to simulate course registration process
            if (isTeacherOrAdmin)
              OutlinedButton.icon(
                onPressed: () => addSemester(),
                icon: const Icon(Icons.add_box_outlined),
                label: const Text('ADD NEW SEMESTER RECORD (Teacher/Admin)'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: colorScheme.primary,
                  side: BorderSide(color: colorScheme.primary.withOpacity(0.5)),
                ),
              ),
            if (!isTeacherOrAdmin)
              const Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Text(
                    'Note: Contact your advisor or use the registration module to add/drop courses.',
                    textAlign: TextAlign.center),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildSemesterCard(BuildContext context, int semIndex,
      Semester semester, double gpa, ColorScheme colorScheme) {
    return Card(
      key: semester.key,
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: semester.name,
                enabled: isTeacherOrAdmin, // Only teachers/admins can rename
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                  hintStyle:
                      TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
                ),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: colorScheme.primary,
                ),
                onChanged: (newName) => renameSemester(semIndex, newName),
              ),
            ),

            // Semester GPA Display
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('GPA: ${gpa.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: gpa >= 3.0
                          ? Colors.green.shade700
                          : colorScheme.onSurface,
                    )),
                Text('${semester.courses.length} Courses',
                    style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withOpacity(0.6))),
              ],
            ),
          ],
        ),
        children: [
          const Divider(height: 1, thickness: 1),
          // --- Courses List ---
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: semester.courses.length,
            itemBuilder: (context, courseIndex) {
              return _buildCourseRow(context, semIndex, courseIndex,
                  semester.courses[courseIndex]);
            },
          ),

          // --- Add Course Button ---
          if (isTeacherOrAdmin)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextButton.icon(
                onPressed: () => addCourse(semIndex),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text(
                    'Register New Course/Assignment (Teacher/Admin)'),
              ),
            ),

          // --- Delete Semester Button ---
          if (isTeacherOrAdmin)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: TextButton.icon(
                onPressed: () => deleteSemester(semIndex),
                icon: Icon(Icons.delete_forever, color: colorScheme.error),
                label: Text('Delete Semester Record',
                    style: TextStyle(color: colorScheme.error)),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildCourseRow(
      BuildContext context, int semIndex, int courseIndex, Course course) {
    final colorScheme = Theme.of(context).colorScheme;
    final finalGradePoints = calculateCourseGradePoints(course);
    final finalLetterGrade = _getLetterGrade(finalGradePoints);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    // Dismissible is used for the "industry standard" swipe-to-delete action
    return Dismissible(
      key: course.key,
      direction: isTeacherOrAdmin
          ? DismissDirection.endToStart
          : DismissDirection.none, // Only teachers/admins can delete courses
      background: Container(
        color: colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (!isTeacherOrAdmin) {
          return false;
        }
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Confirm Deletion"),
              content:
                  Text("Are you sure you want to delete '${course.name}'?"),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("CANCEL"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("DELETE"),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        deleteCourse(semIndex, courseIndex);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${course.name} removed.')),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            // --- HEADER ROW (Course Name, Credits, Grade) ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Course Name Input
                Expanded(
                  flex: isSmallScreen ? 2 : 3,
                  child: TextFormField(
                    initialValue: course.name,
                    enabled:
                        isTeacherOrAdmin, // Only teachers/admins can rename
                    decoration: const InputDecoration(
                      labelText: 'Course Name',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (name) =>
                        updateCourse(semIndex, courseIndex, name: name),
                  ),
                ),
                const SizedBox(width: 8),

                // Credits Input
                SizedBox(
                  width: isSmallScreen ? 50 : 60,
                  child: TextFormField(
                    initialValue: course.credits.toString(),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    enabled:
                        isTeacherOrAdmin, // Only teachers/admins can set credits
                    decoration: const InputDecoration(
                      labelText: 'Cr',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      final credits = double.tryParse(value);
                      if (credits != null) {
                        updateCourse(semIndex, courseIndex, credits: credits);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),

                // Final Grade/Points Display
                Container(
                  width: isSmallScreen ? 70 : 80,
                  height: 60,
                  decoration: BoxDecoration(
                    color: finalGradePoints >= 3.0
                        ? Colors.green.shade100
                        : colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(finalLetterGrade,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 18 : 20,
                            fontWeight: FontWeight.bold,
                            color: finalGradePoints >= 3.0
                                ? Colors.green.shade800
                                : colorScheme.onTertiaryContainer,
                          )),
                      Text(
                        '(${finalGradePoints.toStringAsFixed(2)})',
                        style: TextStyle(
                            fontSize: 12,
                            color: finalGradePoints >= 3.0
                                ? Colors.green.shade800
                                : colorScheme.onTertiaryContainer),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // --- RAW MARKS INPUT SECTION (Horizontal Scroll) ---
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: defaultWeights.keys.map((component) {
                  final maxScore = course.maxScores[component] ?? 1;
                  final currentScore = course.rawScores[component] ?? 0;
                  final currentCount = course.submissionCounts[component] ?? 0;
                  final minRequired = minSubmissions[component] ?? 1;
                  final weight = (defaultWeights[component]! * 100).toInt();
                  final isCounted = currentCount >= minRequired;

                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: SizedBox(
                      width:
                          170, // Increased width for better input/button display
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Current Status (Only visible if counting is required)
                          if (minRequired > 1)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Text(
                                isCounted
                                    ? '✅ COUNTED (Min: $minRequired)'
                                    : '⚠️ Needs ${minRequired - currentCount} more',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isCounted
                                      ? Colors.green.shade700
                                      : Colors.orange.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                          // 2. Score Input (Teacher/Admin only)
                          TextFormField(
                            initialValue: currentScore.toString(),
                            keyboardType: TextInputType.number,
                            enabled: isTeacherOrAdmin,
                            decoration: InputDecoration(
                              labelText: '$component Total ($weight%)',
                              hintText: 'Max: $maxScore',
                              suffixText:
                                  'Count: $currentCount', // Display current count
                              isDense: true,
                              border: const OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              final score = double.tryParse(value);
                              if (score != null && score <= maxScore) {
                                // MOCK: Assume the user is setting the new total score and the count hasn't changed unless they tap the button.
                                updateComponentScores(semIndex, courseIndex,
                                    component, score, maxScore);
                              } else if (value.isEmpty) {
                                updateComponentScores(semIndex, courseIndex,
                                    component, 0, maxScore);
                              }
                            },
                          ),

                          // 3. Increment Button (For repeatable assignments)
                          if (minRequired > 1 && isTeacherOrAdmin)
                            Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: SizedBox(
                                height: 30,
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text('Add 1 Submission',
                                      style: TextStyle(fontSize: 12)),
                                  onPressed: () {
                                    incrementSubmissionCount(
                                        semIndex, courseIndex, component);
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------------------------------
// --- SCREEN 3: PROFILE (No functional change) ---
// --------------------------------------------------------------------------

class ProfileScreen extends StatelessWidget {
  final String? userId;
  final UserRole role; // Added role
  final VoidCallback logout;

  const ProfileScreen(
      {super.key, this.userId, required this.logout, required this.role});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final roleString = role.toString().split('.').last.toUpperCase();

    // FIX: Extract nullable userId into a non-nullable variable for cleaner interpolation
    final displayUserId = userId ?? 'N/A';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Profile & Registration'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 16),
            Text('John Doe', style: Theme.of(context).textTheme.headlineMedium),
            // FIX: Use simple interpolation $displayUserId
            Text('ID: $displayUserId',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: colorScheme.primary)),
            const Divider(height: 32),

            _buildInfoTile('User Role', roleString, colorScheme.secondary),
            _buildInfoTile('Program', 'B.Sc. Computer Science'),
            _buildInfoTile('Registration Status', 'Active', Colors.green),
            _buildInfoTile('Total Semesters', '4 (Completed/Registered)'),
            _buildInfoTile('Advisor', 'Prof. Dr. Smith'),

            const SizedBox(height: 40),

            ElevatedButton.icon(
              onPressed: logout,
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value, [Color? color]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value,
              style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
