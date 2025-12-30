import 'package:flutter/material.dart';

class ThreeDButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color? color;

  const ThreeDButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.color,
  });

  @override
  State<ThreeDButton> createState() => _ThreeDButtonState();
}

class _ThreeDButtonState extends State<ThreeDButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).primaryColor;
    final shadowColor = HSLColor.fromColor(color).withLightness(0.4).toColor();

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: 54,
        margin: EdgeInsets.only(top: _isPressed ? 6 : 0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: shadowColor,
                    offset: const Offset(0, 6),
                    blurRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(0, 10),
                    blurRadius: 10,
                  ),
                ],
        ),
        child: Center(
          child: DefaultTextStyle(
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}