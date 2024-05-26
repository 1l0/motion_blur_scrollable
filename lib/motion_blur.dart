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
    debugPrint('$_delta');
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
            return ShaderMask(
                blendMode: BlendMode.src,
                shaderCallback: (rect) {
                  return shader
                    ..setFloat(0, rect.size.width)
                    ..setFloat(1, rect.size.height)
                    ..setFloat(2, _delta)
                    ..setFloat(3, _angle)
                    ..setImageSampler(0, _image);
                });
          },
        );
      },
    );
  }
}
