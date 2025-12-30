import 'package:flutter/material.dart';

enum ThreeDType { tilt, lift, none }

class ThreeDCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? color;
  final VoidCallback? onTap;
  final double depth;
  final ThreeDType type;

  const ThreeDCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.color,
    this.onTap,
    this.depth = 10,
    this.type = ThreeDType.tilt,
  });

  @override
  State<ThreeDCard> createState() => _ThreeDCardState();
}

class _ThreeDCardState extends State<ThreeDCard> with SingleTickerProviderStateMixin {
  double _x = 0;
  double _y = 0;
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    if (widget.type == ThreeDType.none) {
      return Container(
        padding: widget.padding,
        margin: widget.margin,
        decoration: BoxDecoration(
          color: widget.color ?? Theme.of(context).cardColor,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
        ),
        child: widget.child,
      );
    }

    final transform = Matrix4.identity();
    if (widget.type == ThreeDType.tilt) {
      transform..setEntry(3, 2, 0.001)..rotateX(_x / 100)..rotateY(_y / 100);
    } else if (widget.type == ThreeDType.lift && _isHovering) {
      transform.translate(0.0, -8.0, 0.0);
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() {
        _isHovering = false;
        _x = 0;
        _y = 0;
      }),
      onHover: (e) {
        if (widget.type == ThreeDType.tilt) {
          final size = context.size!;
          final center = Offset(size.width / 2, size.height / 2);
          final diff = e.localPosition - center;
          setState(() {
            _x = -diff.dy; // Invert Y for natural tilt
            _y = diff.dx;
          });
        }
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: TweenAnimationBuilder<Matrix4>(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          tween: Matrix4Tween(begin: Matrix4.identity(), end: transform),
          builder: (context, matrix, child) {
            return Transform(
              transform: matrix,
              alignment: Alignment.center,
              child: Container(
                padding: widget.padding,
                margin: widget.margin,
                decoration: BoxDecoration(
                  color: widget.color ?? Theme.of(context).cardColor,
                  borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: _isHovering ? 30 : 15,
                      offset: _isHovering ? const Offset(0, 20) : const Offset(0, 10),
                      spreadRadius: _isHovering ? 2 : 0,
                    ),
                    // 3D Highlight/Rim light
                    if (widget.type == ThreeDType.tilt)
                      BoxShadow(
                        color: Colors.white.withOpacity(0.1),
                        blurRadius: 0,
                        offset: const Offset(-1, -1),
                        spreadRadius: 0,
                      ),
                  ],
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      (widget.color ?? Theme.of(context).cardColor).withOpacity(0.9),
                      (widget.color ?? Theme.of(context).cardColor),
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
                child: widget.child,
              ),
            );
          },
        ),
      ),
    );
  }
}

class EntranceFader extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset offset;

  const EntranceFader({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 400),
    this.offset = const Offset(0, 30),
  });

  @override
  State<EntranceFader> createState() => _EntranceFaderState();
}

class _EntranceFaderState extends State<EntranceFader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _translate;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _translate = Tween<Offset>(begin: widget.offset, end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Opacity(opacity: _opacity.value, child: Transform.translate(offset: _translate.value, child: child)),
      child: widget.child,
    );
  }
}