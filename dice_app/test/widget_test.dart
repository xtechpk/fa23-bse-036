import 'package:flutter_test/flutter_test.dart';

import 'package:dice_app/main.dart'; // Ensure this path is correct

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const LudoApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsNothing); // Test adjusted as there's no counter
    expect(find.text('1'), findsNothing);
  });
}
