import 'dart:math';

import 'package:flutter/material.dart';

class GradientProgressIndicator extends StatefulWidget {
  const GradientProgressIndicator({
    required this.child,
    required this.radius,
    required this.strokeWidth,
    required this.gradientStops,
    required this.gradientColors,
    this.backgroundColor = Colors.transparent,
    this.duration = 4,
  });

  final Widget child;
  final int duration;
  final double radius;
  final double strokeWidth;
  final List<double> gradientStops;
  final List<Color> gradientColors;
  final Color backgroundColor;

  @override
  _GradientProgressIndicatorState createState() =>
      _GradientProgressIndicatorState();
}

class _GradientProgressIndicatorState extends State<GradientProgressIndicator>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _animationRotationController;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.duration),
    );

    _animationRotationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.duration),
    );

    _animationController.addListener(() {
      if (_animationController.value >= 0.75) {
        if (_animationRotationController.value == 0) {
          _animationRotationController.repeat();
        }
      }
      setState(() {});
    });
    _animationRotationController.addListener(() => setState(() {}));

    _animationController.forward();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _animationRotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF3460AF),
              Color(0xFF113293),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: AnimatedBuilder(
                      animation: _animationRotationController,
                      builder: (_, child) {
                        return Transform.rotate(
                          angle: _animationRotationController.value * (pi * 2),
                          child: child,
                        );
                      },
                      child: _GradientCircularProgressIndicator(
                        gradientColors: widget.gradientColors,
                        radius: widget.radius,
                        strokeWidth: widget.strokeWidth,
                        backgroundColor: widget.backgroundColor,
                        value: Tween(begin: 0.0, end: 1.0)
                            .animate(
                              CurvedAnimation(
                                parent: _animationController,
                                curve: Curves.decelerate,
                              ),
                            )
                            .value,
                        gradientStops: widget.gradientStops,
                      ),
                    ),
                  ),
                  Center(
                    child: widget.child,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientCircularProgressIndicator extends StatelessWidget {
  _GradientCircularProgressIndicator({
    this.strokeWidth = 10.0,
    this.strokeRound = false,
    this.backgroundColor = Colors.transparent,
    required this.radius,
    required this.gradientStops,
    required this.gradientColors,
    required this.value,
  });

  final double strokeWidth;
  final bool strokeRound;
  final double value;
  final Color backgroundColor;
  final List<double> gradientStops;
  final double radius;
  final List<Color> gradientColors;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -pi / 2,
      child: CustomPaint(
        size: Size.fromRadius(radius),
        painter: _GradientCircularProgressPainter(
          strokeWidth: strokeWidth,
          strokeRound: strokeRound,
          backgroundColor: backgroundColor,
          gradientColors: gradientColors,
          value: value,
          radius: radius,
          gradientStops: gradientStops,
        ),
      ),
    );
  }
}

class _GradientCircularProgressPainter extends CustomPainter {
  _GradientCircularProgressPainter({
    required this.strokeWidth,
    required this.strokeRound,
    required this.value,
    this.backgroundColor = Colors.transparent,
    required this.gradientColors,
    required this.gradientStops,
    this.total = 2 * pi,
    this.radius,
  });

  final double strokeWidth;
  final bool strokeRound;
  final double value;
  final Color backgroundColor;
  final List<Color> gradientColors;
  final List<double> gradientStops;
  final double total;
  final double? radius;

  @override
  void paint(Canvas canvas, Size size) {
    Size paintSize = size;
    if (radius != null) {
      paintSize = Size.fromRadius(radius!);
    }

    double _value = value;
    _value = _value.clamp(.0, 0.97) * total;
    const double _start = 0.1;

    final double _offset = strokeWidth / 2;

    final Rect rect = Offset(_offset, _offset) &
        Size(paintSize.width - strokeWidth, paintSize.height - strokeWidth);

    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    if (backgroundColor != Colors.transparent) {
      paint.color = backgroundColor;
      canvas.drawArc(rect, _start, total, false, paint);
    }

    if (_value > 0) {
      paint.shader = SweepGradient(
              colors: gradientColors, endAngle: _value, stops: gradientStops)
          .createShader(rect);

      canvas.drawArc(rect, _start, _value, false, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
