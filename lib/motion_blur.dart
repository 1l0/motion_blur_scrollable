import 'dart:ui';

import 'package:flutter/material.dart' hide Image;

class MotionBlur extends StatelessWidget {
  const MotionBlur({
    super.key,
    this.errorBuilder,
    required Image image,
    required double delta,
    required double angle,
  })  : _image = image,
        _delta = delta,
        _angle = angle;

  final Widget Function(BuildContext, Object error, StackTrace)? errorBuilder;

  final Image _image;

  final double _delta;

  final double _angle;

  Future<FragmentShader> _shader() async {
    final program = await FragmentProgram.fromAsset('shaders/motion_blur.frag');
    return program.fragmentShader();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FragmentShader>(
      future: _shader(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          final error = snapshot.error!;
          if (errorBuilder != null) {
            return errorBuilder!(context, error, snapshot.stackTrace!);
          }
          return ErrorWidget(error);
        }
        if (!snapshot.hasData) {
          return const SizedBox();
        }
        final shader = snapshot.data!;

        return LayoutBuilder(
          builder: (context, constraints) {
            return CustomPaint(
              size: constraints.biggest,
              painter: _ShaderPainter(
                shader: shader,
                image: _image,
                delta: _delta,
                angle: _angle,
              ),
            );
          },
        );
      },
    );
  }
}

class _ShaderPainter extends CustomPainter {
  _ShaderPainter({
    required this.shader,
    required this.image,
    required this.delta,
    required this.angle,
  });
  final FragmentShader shader;
  final Image image;
  final double delta;
  final double angle;

  @override
  void paint(Canvas canvas, Size size) {
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    shader.setFloat(2, delta);
    shader.setFloat(3, angle);
    shader.setImageSampler(0, image);

    final paint = Paint()..shader = shader;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
