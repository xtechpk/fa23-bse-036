import 'package:flutter_test/flutter_test.dart';
import 'package:calculator_app/main.dart';

void main() {
  testWidgets('Calculator basic addition test', (WidgetTester tester) async {
    // Build our Calculator app
    await tester.pumpWidget(const CalculatorApp());

    // Verify the initial state is "0"
    expect(find.text('0'), findsOneWidget);

    // Tap 7 + 3 =
    await tester.tap(find.text('7'));
    await tester.pump();
    await tester.tap(find.text('+'));
    await tester.pump();
    await tester.tap(find.text('3'));
    await tester.pump();
    await tester.tap(find.text('='));
    await tester.pump();

    // Verify the result is 10
    expect(find.text('10'), findsOneWidget);
  });
}
