import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() => runApp(const CalculatorApp());

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.dark,
        ),
      ),
      home: const CalculatorScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = "0";

  // This function is called when any button is pressed.
  void _onPressed(String value) {
    setState(() {
      if (value == "AC") {
        _display = "0";
      } else if (value == "⌫") {
        if (_display.length > 1) {
          _display = _display.substring(0, _display.length - 1);
        } else {
          _display = "0";
        }
      } else if (value == "=") {
        if (_display == "Error") return;
        try {
          // Replace display operators with ones the parser understands
          String expression =
              _display.replaceAll('×', '*').replaceAll('÷', '/');

          Parser p = Parser();
          Expression exp = p.parse(expression);
          ContextModel cm = ContextModel();
          double eval = exp.evaluate(EvaluationType.REAL, cm);

          // Format result to remove trailing .0 for whole numbers
          if (eval.truncateToDouble() == eval) {
            _display = eval.toInt().toString();
          } else {
            // Limit decimal places and remove unnecessary trailing zeros
            _display = eval
                .toStringAsFixed(4)
                .replaceAll(RegExp(r'0*$'), '')
                .replaceAll(RegExp(r'\.$'), '');
          }
        } catch (e) {
          _display = "Error";
        }
      } else if (value == "%") {
        if (_display == "Error") return;
        // Applies percentage to the last number in the expression
        final operators = RegExp(r'[+\-×÷]');
        var numbers = _display.split(operators);
        if (numbers.isNotEmpty && numbers.last.isNotEmpty) {
          try {
            var lastNumber = double.parse(numbers.last);
            var percentageValue = (lastNumber / 100).toString();
            _display =
                _display.substring(0, _display.length - numbers.last.length) +
                    percentageValue;
          } catch (e) {
            // Ignore if last segment is not a valid number
          }
        }
      } else if ("+-×÷".contains(value)) {
        if (_display == "Error") return;
        String lastChar = _display.substring(_display.length - 1);
        // Replace the last operator if it is one, otherwise append
        if ("+-×÷".contains(lastChar)) {
          _display = _display.substring(0, _display.length - 1) + value;
        } else {
          _display += value;
        }
      } else if (value == ".") {
        // Allow decimal point only if the last number segment doesn't have one
        final operators = RegExp(r'[+\-×÷]');
        var numbers = _display.split(operators);
        if (!numbers.last.contains('.')) {
          _display += ".";
        }
      } else {
        // Handle number input
        if (_display == "0" || _display == "Error") {
          _display = value;
        } else {
          _display += value;
        }
      }
    });
  }

  // A helper to build styled calculator buttons
  Widget _buildButton(String text,
      {Color? color,
      Color? textColor,
      int flex = 1,
      required double buttonSize,
      required double buttonPadding}) {
    double width = buttonSize * flex + (buttonPadding * 2 * (flex - 1));
    return Padding(
      padding: EdgeInsets.all(buttonPadding),
      child: SizedBox(
        width: width,
        height: buttonSize,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? const Color.fromRGBO(51, 51, 51, 1),
            foregroundColor: textColor ?? Colors.white,
            shape: flex > 1 ? const StadiumBorder() : const CircleBorder(),
            padding: EdgeInsets.zero,
          ),
          onPressed: () => _onPressed(text),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: buttonSize * 0.4,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Display Area
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                alignment: Alignment.bottomRight,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SelectableText(
                    _display,
                    style: const TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
            ),
            // Buttons Area
            Flexible(
              flex: 3,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double availWidth = constraints.maxWidth;
                  double availHeight = constraints.maxHeight;
                  double buttonPadding = 6.0;
                  // For 4 buttons row: total horizontal fixed = 12 (ends) + 36 (3 gaps of 12) = 48
                  double horizFixed4 = buttonPadding * 2 * 4;
                  double buttonW = (availWidth - horizFixed4) / 4;
                  double vertFixed = buttonPadding * 2 * 5;
                  double buttonH = (availHeight - vertFixed) / 5;
                  double buttonSize = buttonW < buttonH ? buttonW : buttonH;
                  // For last row with 3 items, but since we use same buttonSize, it will fit as flex adjusts
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildButton("AC",
                              color: Colors.grey,
                              textColor: Colors.black,
                              buttonSize: buttonSize,
                              buttonPadding: buttonPadding),
                          _buildButton("⌫",
                              color: Colors.grey,
                              textColor: Colors.black,
                              buttonSize: buttonSize,
                              buttonPadding: buttonPadding),
                          _buildButton("%",
                              color: Colors.grey,
                              textColor: Colors.black,
                              buttonSize: buttonSize,
                              buttonPadding: buttonPadding),
                          _buildButton("÷",
                              color: Colors.orange,
                              buttonSize: buttonSize,
                              buttonPadding: buttonPadding),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildButton("7",
                              buttonSize: buttonSize,
                              buttonPadding: buttonPadding),
                          _buildButton("8",
                              buttonSize: buttonSize,
                              buttonPadding: buttonPadding),
                          _buildButton("9",
                              buttonSize: buttonSize,
                              buttonPadding: buttonPadding),
                          _buildButton("×",
                              color: Colors.orange,
                              buttonSize: buttonSize,
                              buttonPadding: buttonPadding),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildButton("4",
                              buttonSize: buttonSize,
                              buttonPadding: buttonPadding),
                          _buildButton("5",
                              buttonSize: buttonSize,
                              buttonPadding: buttonPadding),
                          _buildButton("6",
                              buttonSize: buttonSize,
                              buttonPadding: buttonPadding),
                          _buildButton("-",
                              color: Colors.orange,
                              buttonSize: buttonSize,
                              buttonPadding: buttonPadding),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildButton("1",
                              buttonSize: buttonSize,
                              buttonPadding: buttonPadding),
                          _buildButton("2",
                              buttonSize: buttonSize,
                              buttonPadding: buttonPadding),
                          _buildButton("3",
                              buttonSize: buttonSize,
                              buttonPadding: buttonPadding),
                          _buildButton("+",
                              color: Colors.orange,
                              buttonSize: buttonSize,
                              buttonPadding: buttonPadding),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildButton("0",
                              flex: 2,
                              buttonSize: buttonSize,
                              buttonPadding: buttonPadding),
                          _buildButton(".",
                              buttonSize: buttonSize,
                              buttonPadding: buttonPadding),
                          _buildButton("=",
                              color: Colors.orange,
                              buttonSize: buttonSize,
                              buttonPadding: buttonPadding),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
