import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/rendering.dart' show RenderRepaintBoundary;
import 'package:flutter/widgets.dart' hide Image;

import 'shader_widget.dart';

const _piHalf = 1.570796326794897;
const _assetKey = 'packages/motion_blur_scrollable/shaders/motion_blur.frag';

class MotionBlurScrollable extends StatefulWidget {
  const MotionBlurScrollable({
    super.key,
    required this.child,
  });

  final ScrollView child;

  @override
  State<MotionBlurScrollable> createState() => _MotionBlurScrollableState();
}

class _MotionBlurScrollableState extends State<MotionBlurScrollable> {
  final boundaryKey = GlobalKey();

  Image? image;
  FragmentShader? shader;
  double delta = 0;
  double angle = _piHalf;

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

  void captureImage() {
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final boundary = boundaryKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    final m = boundary?.toImageSync(pixelRatio: pixelRatio);
    setState(() {
      image = m;
    });
  }

  /// A timer is needed due to an unresolved bug that [ScrollEndNotification]
  /// would be emitted on every scroll update.
  /// https://github.com/flutter/flutter/issues/44732#issuecomment-862405208
  Timer? scrollEndTimer;

  bool onScroll(ScrollUpdateNotification scroll) {
    if (scroll.depth != 0) {
      return false;
    }
    if (scroll.scrollDelta == null) {
      return false;
    }
    final deltaPixels = scroll.scrollDelta!.abs();
    delta = deltaPixels / 1000;
    angle = scroll.metrics.axis == Axis.horizontal ? pi : _piHalf;
    scrollEndTimer?.cancel();
    scrollEndTimer = Timer(const Duration(milliseconds: 50), () {
      delta = 0;
      setState(() {});
    });
    captureImage();
    return true;
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
        NotificationListener<ScrollUpdateNotification>(
          onNotification: onScroll,
          child: RepaintBoundary(
            key: boundaryKey,
            child: widget.child,
          ),
        ),
        if (shader != null && image != null && delta > 0)
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
