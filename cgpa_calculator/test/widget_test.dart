// This is the updated widget test file for the University Portal CGPA application.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cgpa_calculator/main.dart'; // UniPortalApp is defined here

void main() {
  // Helper to find the CGPA display text (now located on the Dashboard)
  Finder findCgpaText(String value) => find.text(value);

  // Helper to find the 'ADD NEW SEMESTER RECORD' button
  Finder findAddSemesterButton() =>
      find.widgetWithText(OutlinedButton, 'ADD NEW SEMESTER RECORD');

  // Helper to find the Add Course button within the specified semester
  Finder findAddCourseButton(String semesterName) => find.descendant(
        of: find.widgetWithText(ExpansionTile, semesterName),
        matching:
            find.widgetWithText(TextButton, 'Register New Course/Assignment'),
      );

  // FIX: Helper to find all course name fields by targeting the InputDecorator,
  // resolving the null-aware operator warning by using direct access.
  Finder findCourseNameFields() => find.byWidgetPredicate(
        (widget) {
          if (widget is InputDecorator) {
            return widget.decoration.labelText == 'Course Name';
          }
          return false;
        },
      );

  // FIX: Helper to find a specific component score input field by its label,
  // resolving the null-aware operator warning by using direct access.
  Finder findComponentScoreField(String labelText) => find.byWidgetPredicate(
        (widget) {
          if (widget is InputDecorator) {
            return widget.decoration.labelText == labelText;
          }
          return false;
        },
      );

  // --- TEST 1: Verify Initial CGPA Calculation ---
  testWidgets('Initial CGPA calculation is correct (based on mock scores)',
      (WidgetTester tester) async {
    // FIX: Use UniPortalApp instead of CgpaCalculatorApp
    await tester.pumpWidget(const UniPortalApp());
    await tester.pumpAndSettle();

    // Navigate to the Dashboard (index 0) where the CGPA is displayed
    await tester.tap(find.byIcon(Icons.dashboard));
    await tester.pumpAndSettle();

    // CGPA is calculated based on default raw scores in main.dart:
    // Total Score ≈ 65.5% -> GPA ≈ 1.7 (C-)
    expect(findCgpaText('1.70'), findsOneWidget);
  });

  // --- TEST 2: Add New Semester and Course ---
  testWidgets('Adding new semester and course fields updates the list',
      (WidgetTester tester) async {
    await tester.pumpWidget(const UniPortalApp());
    await tester.pumpAndSettle();

    // Navigate to the Courses Manager (index 1)
    await tester.tap(find.byIcon(Icons.calculate));
    await tester.pumpAndSettle();

    // 1. Verify initial state: 1 semester
    final semesterTiles = find.byType(ExpansionTile);
    expect(semesterTiles, findsNWidgets(1));

    // 2. Add a new semester
    await tester.tap(findAddSemesterButton());
    await tester.pumpAndSettle();

    // Verify 2 semesters now exist
    expect(semesterTiles, findsNWidgets(2));

    // 3. Add a course to the new Semester 2
    const newSemesterName = 'Semester 2 (New Record)';
    await tester.tap(findAddCourseButton(newSemesterName));
    await tester.pumpAndSettle();

    // The initial courses are 3. Adding one more makes it 4.
    expect(findCourseNameFields(), findsNWidgets(4));
  });

  // --- TEST 3: Update Raw Scores and Recalculate CGPA ---
  testWidgets('Inputting raw scores recalculates the CGPA correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(const UniPortalApp());
    await tester.pumpAndSettle();

    // Navigate to the Courses Manager (index 1)
    await tester.tap(find.byIcon(Icons.calculate));
    await tester.pumpAndSettle();

    // --- Action: Set Midterm and Final scores for 'Software Engineering' (first course) ---
    // Midterm (20% weight, max 50) -> Set score 50 (100% component score)
    await tester.enterText(
        findComponentScoreField('Midterm (20%)').first, '50');

    // Final (40% weight, max 100) -> Set score 100 (100% component score)
    await tester.enterText(findComponentScoreField('Final (40%)').first, '100');

    // Trigger update/rebuild
    await tester.pumpAndSettle();

    // Enter the remaining fields to push the first course to 4.0
    await tester.enterText(findComponentScoreField('Quiz (10%)').first, '10');
    await tester.enterText(
        findComponentScoreField('Assignment (15%)').first, '15');
    await tester.enterText(findComponentScoreField('Lab (15%)').first, '15');
    await tester.pumpAndSettle();

    // Wait for the Dashboard to update by navigating back
    await tester.tap(find.byIcon(Icons.dashboard));
    await tester.pumpAndSettle();

    // Expected CGPA calculation:
    // Course 1: 4.0 credits * 4.0 GP = 16.0 QPs
    // Course 2: 3.0 credits * 1.7 GP = 5.1 QPs (Default scores)
    // Course 3: 3.0 credits * 1.7 GP = 5.1 QPs (Default scores)
    // Total QPs: 26.2
    // Total Credits: 10.0
    // CGPA: 26.2 / 10.0 = 2.62

    // Verify the CGPA display updated to 2.62
    expect(findCgpaText('2.62'), findsOneWidget);
  });
}
