import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/rendering.dart' show RenderRepaintBoundary;
import 'package:flutter/widgets.dart' hide Image;

import 'package:scroll_experiments/motion_blur.dart';

const pi_half = 1.570796326794897;

class ScrollableBlur extends StatefulWidget {
  const ScrollableBlur({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<ScrollableBlur> createState() => _ScrollableBlurState();
}

class _ScrollableBlurState extends State<ScrollableBlur> {
  final _boundaryKey = GlobalKey();

  Image? image;
  int lastTS = DateTime.now().millisecondsSinceEpoch;
  double lastPixels = 0;

  double delta = 0;
  double angle = pi_half;

  FragmentShader? shader;

  @override
  void initState() {
    super.initState();
    unawaited(loadShader());
  }

  Future<void> loadShader() async {
    final program = await FragmentProgram.fromAsset('shaders/motion_blur.frag');
    setState(() {
      shader = program.fragmentShader();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  bool captureLock = false;

  Future<void> captureImage() async {
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
      final velo = deltaPixels / (deltaT * 0.0001);
      delta = velo > 1.0 ? (deltaPixels / 800) : 0.0;
      angle = notification.metrics.axis == Axis.horizontal ? pi : pi_half;
    }

    lastTS = ts;
    lastPixels = pixels;

    Timer(
      const Duration(milliseconds: 60),
      afterScroll,
    );

    return false;
  }

  void afterScroll() {
    unawaited(captureImage());
    final ts = DateTime.now().millisecondsSinceEpoch;
    final deltaT = ts - lastTS;

    if (deltaT >= 60) {
      delta = 0.0;
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
            child: MotionBlur(
              image: image!,
              shader: shader!,
            ),
          )
      ],
    );
  }
}
