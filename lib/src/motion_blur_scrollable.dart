import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart' hide Image;

class MotionBlurScrollable extends StatefulWidget {
  const MotionBlurScrollable({
    super.key,
    required this.child,
    this.tileMode,
  });

  final ScrollView child;
  final TileMode? tileMode;

  @override
  State<MotionBlurScrollable> createState() => _MotionBlurScrollableState();
}

class _MotionBlurScrollableState extends State<MotionBlurScrollable> {
  double delta = 0;
  bool horizontal = false;

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
    setState(() {
      delta = deltaPixels / 2.0;
      horizontal = scroll.metrics.axis == Axis.horizontal;
    });
    scrollEndTimer?.cancel();
    scrollEndTimer = Timer(const Duration(milliseconds: 50), () {
      setState(() {
        delta = 0;
      });
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollUpdateNotification>(
      onNotification: onScroll,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(
          sigmaX: horizontal ? delta : 0.0,
          sigmaY: horizontal ? 0.0 : delta,
          tileMode: widget.tileMode ?? TileMode.clamp,
        ),
        child: widget.child,
      ),
    );
  }
}
