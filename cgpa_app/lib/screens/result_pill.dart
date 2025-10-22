import 'package:flutter/material.dart';

/// Small widget that displays a title and a large value in a colored style.
class ResultPill extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const ResultPill(
      {super.key,
      required this.title,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 36,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
