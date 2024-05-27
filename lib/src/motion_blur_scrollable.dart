import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/rendering.dart' show RenderRepaintBoundary;
import 'package:flutter/widgets.dart' hide Image;

import 'shader_widget.dart';

const _piHalf = 1.570796326794897;
const _assetKey =
    'packages/motion_blur_scrollable/assets/shaders/motion_blur.frag';

class MotionBlurScrollable extends StatefulWidget {
  const MotionBlurScrollable({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<MotionBlurScrollable> createState() => _MotionBlurScrollableState();
}

class _MotionBlurScrollableState extends State<MotionBlurScrollable> {
  final _boundaryKey = GlobalKey();

  Image? image;
  int lastTS = DateTime.now().millisecondsSinceEpoch;
  double lastPixels = 0;

  double delta = 0;
  double angle = _piHalf;

  FragmentShader? shader;

  @override
  void initState() {
    super.initState();
    unawaited(loadShader());
  }

  Future<void> loadShader() async {
    final program = await FragmentProgram.fromAsset(_assetKey);
    setState(() {
      shader = program.fragmentShader();
    });
  }

  bool captureLock = false;

  Future<void> captureImageAsync() async {
    if (captureLock) return;
    captureLock = true;
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final boundary = _boundaryKey.currentContext!.findRenderObject()!
        as RenderRepaintBoundary;
    final m = await boundary.toImage(pixelRatio: pixelRatio);
    captureLock = false;
    setState(() {
      image = m;
    });
  }

  void captureImage() {
    if (captureLock) return;
    captureLock = true;
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final boundary = _boundaryKey.currentContext!.findRenderObject()!
        as RenderRepaintBoundary;
    final m = boundary.toImageSync(pixelRatio: pixelRatio);
    captureLock = false;
    setState(() {
      image = m;
    });
  }

  bool onScroll(ScrollMetricsNotification notification) {
    if (notification.depth != 0) {
      return false;
    }

    final ts = DateTime.now().millisecondsSinceEpoch;
    final deltaT = ts - lastTS;

    if (deltaT < 12) return false;

    final pixels = notification.metrics.pixels;

    if (notification.metrics.atEdge) {
      delta = 0.0;
    } else {
      final deltaPixels = (pixels - lastPixels).abs();
      final velo = deltaPixels / (deltaT * 0.1);
      delta = velo > 1.0 ? (deltaPixels / 800) : 0.0;
      angle = notification.metrics.axis == Axis.horizontal ? pi : _piHalf;
    }

    lastTS = ts;
    lastPixels = pixels;

    captureImage();

    Timer(
      const Duration(milliseconds: 60),
      afterScroll,
    );

    return false;
  }

  void afterScroll() {
    // unawaited(captureImageAsync());
    final ts = DateTime.now().millisecondsSinceEpoch;
    final deltaT = ts - lastTS;

    if (deltaT >= 60) {
      delta = 0.0;
      setState(() {});
    }
  }

  void updateShader() {
    shader?.setFloat(2, delta);
    shader?.setFloat(3, angle);
  }

  @override
  Widget build(BuildContext context) {
    updateShader();

    return Stack(
      fit: StackFit.passthrough,
      children: [
        NotificationListener<ScrollMetricsNotification>(
          onNotification: onScroll,
          child: RepaintBoundary(
            key: _boundaryKey,
            child: widget.child,
          ),
        ),
        if (shader != null && image != null)
          IgnorePointer(
            child: ShaderWidget(
              image: image!,
              shader: shader!,
            ),
          )
      ],
    );
  }
}
