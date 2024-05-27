import 'dart:ui';

import 'package:flutter/material.dart' hide Image;

class ShaderWidget extends StatelessWidget {
  const ShaderWidget({
    super.key,
    required Image image,
    required FragmentShader shader,
  })  : _image = image,
        _shader = shader;

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
  const _ShaderPainter({
    required this.shader,
    required this.image,
  });
  final FragmentShader shader;
  final Image image;

  @override
  void paint(Canvas canvas, Size size) {
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    shader.setImageSampler(0, image);

    final paint = Paint()..shader = shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
