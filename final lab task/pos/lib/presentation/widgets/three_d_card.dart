import 'package:flutter/material.dart';

class ThreeDCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final BorderRadius? borderRadius;
  const ThreeDCard({super.key, required this.child, this.padding = const EdgeInsets.all(12), this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: borderRadius ?? BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), offset: const Offset(6, 6), blurRadius: 18),
          BoxShadow(color: Colors.white.withOpacity(0.9), offset: const Offset(-6, -6), blurRadius: 18),
        ],
      ),
      child: child,
    );
  }
}
