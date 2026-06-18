import 'dart:math';
import 'package:flutter/material.dart';

class ShakeWidget extends StatefulWidget {
  final Widget child;
  final int trigger;
  final double shakeOffset;
  final Duration duration;

  const ShakeWidget({
    super.key,
    required this.child,
    required this.trigger,
    this.shakeOffset = 8.0,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void didUpdateWidget(covariant ShakeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger != oldWidget.trigger && widget.trigger > 0) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _getTranslation(double value) {
    // A sine wave that decays over time
    return sin(value * pi * 4) * widget.shakeOffset * (1.0 - value);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_getTranslation(_controller.value), 0),
          child: child,
        );
      },
    );
  }
}
