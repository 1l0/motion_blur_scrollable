import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CustomRepaintBoundary extends RepaintBoundary {
  const CustomRepaintBoundary({super.key, super.child});

  @override
  RenderRepaintBoundary createRenderObject(BuildContext context) =>
      CustomRenderRepaintBoundary();
}

class CustomRenderRepaintBoundary extends RenderRepaintBoundary {
  CustomRenderRepaintBoundary({super.child});

  @override
  void paint(PaintingContext context, Offset offset) {
    final RenderBox? child = this.child;
    if (child == null) {
      return;
    }
    context.paintChild(child, offset);
  }
}
