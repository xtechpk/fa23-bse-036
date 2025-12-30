import 'package:flutter/material.dart';

class ThreeDButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final double height;
  const ThreeDButton({super.key, required this.onPressed, required this.child, this.height = 54});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 6,
          shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.25),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        child: child,
      ),
    );
  }
}
