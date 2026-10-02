import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// True circular-reveal theme switch (replaces the old solid-color ripple):
/// snapshot the current UI, switch the theme underneath, then punch a
/// growing circular hole through the snapshot starting at the tap point —
/// the new theme is gradually uncovered from one point outward. The overlay
/// removes itself and disposes the snapshot when done. Instant switch when
/// the OS requests reduced motion or the snapshot fails.

/// Root repaint boundary key (installed in main.dart around the app).
final GlobalKey<State<StatefulWidget>> themeRevealBoundaryKey = GlobalKey();

/// Captures the current UI as an image, or null when unavailable.
Future<ui.Image?> captureThemeSnapshot(BuildContext context) async {
  try {
    final ctx = themeRevealBoundaryKey.currentContext;
    if (ctx == null) return null;
    final boundary = ctx.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;
    return await boundary.toImage(
      pixelRatio: MediaQuery.devicePixelRatioOf(ctx),
    );
  } on Exception catch (_) {
    return null;
  }
}

/// Shows the reveal overlay and switches nothing itself — callers apply the
/// new palette first so it renders underneath, then call this with the
/// pre-switch snapshot.
void showThemeReveal(
  BuildContext context, {
  required Offset origin,
  required ui.Image snapshot,
}) {
  if (MediaQuery.disableAnimationsOf(context)) {
    snapshot.dispose();
    return;
  }
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => ThemeRevealOverlay(
      origin: origin,
      snapshot: snapshot,
      onDone: () {
        entry.remove();
        snapshot.dispose();
      },
    ),
  );
  Overlay.of(context).insert(entry);
}

/// Full-screen old-UI snapshot with a growing circular hole. Public for tests.
class ThemeRevealOverlay extends StatefulWidget {
  const new({
    required this.origin,
    required this.snapshot,
    required this.onDone,
    super.key,
  });

  final Offset origin;
  final ui.Image snapshot;
  final VoidCallback onDone;

  @override
  State<ThemeRevealOverlay> createState() => _ThemeRevealOverlayState();
}

class _ThemeRevealOverlayState extends State<ThemeRevealOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );

  @override
  void initState() {
    super.initState();
    unawaited(
      _ctrl.forward().then((_) {
        if (mounted) widget.onDone();
      }),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    // Radius reaching the farthest corner from the tap point.
    final maxRadius = [
      widget.origin,
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ].map((c) => (c - widget.origin).distance).reduce((a, b) => a > b ? a : b);
    // Steady gradual spread outward.
    final spread = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutCubic);
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) => CustomPaint(
          painter: _RevealPainter(
            origin: widget.origin,
            radius: maxRadius * spread.value,
            snapshot: widget.snapshot,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _RevealPainter extends CustomPainter {
  const new({
    required this.origin,
    required this.radius,
    required this.snapshot,
  });

  final Offset origin;
  final double radius;
  final ui.Image snapshot;

  @override
  void paint(Canvas canvas, Size size) {
    final full = Offset.zero & size;
    final src =
        Offset.zero &
        Size(snapshot.width.toDouble(), snapshot.height.toDouble());
    if (radius <= 0) {
      canvas.drawImageRect(
        snapshot,
        src,
        full,
        Paint()..filterQuality = FilterQuality.medium,
      );
      return;
    }
    final hole = Path()
      ..addOval(Rect.fromCircle(center: origin, radius: radius));
    canvas.save();
    canvas.clipPath(
      Path.combine(PathOperation.difference, Path()..addRect(full), hole),
    );
    canvas.drawImageRect(
      snapshot,
      src,
      full,
      Paint()..filterQuality = FilterQuality.medium,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_RevealPainter old) =>
      old.radius != radius || old.origin != origin || old.snapshot != snapshot;
}
