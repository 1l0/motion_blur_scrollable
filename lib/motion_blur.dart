import 'dart:ui';

import 'package:flutter/material.dart' hide Image;

class MotionBlur extends StatelessWidget {
  const MotionBlur({
    super.key,
    this.errorBuilder,
    required Image image,
    required FragmentShader shader,
  })  : _image = image,
        _shader = shader;

  final Widget Function(BuildContext, Object error, StackTrace)? errorBuilder;

  final Image _image;
  final FragmentShader _shader;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: constraints.biggest,
          painter: _ShaderPainter(
            shader: _shader,
            image: _image,
          ),
        );
      },
    );
  }
}

class _ShaderPainter extends CustomPainter {
  _ShaderPainter({
    required this.shader,
    required this.image,
  });
  final FragmentShader shader;
  final Image image;

  @override
  void paint(Canvas canvas, Size size) {
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    // shader.setFloat(2, delta);
    // shader.setFloat(3, angle);
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
