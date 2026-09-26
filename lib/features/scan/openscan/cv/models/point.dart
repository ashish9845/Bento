// Vendored from https://github.com/ethereal-developers/OpenScan
// (BSD-3-Clause, see third_party/openscan/LICENSE). Only import
// paths were adapted; logic is unchanged.

/// A simple 2D point used by the pure-Dart CV pipeline. Kept independent of
/// dart:ui's Offset so this code can run in a plain (non-Flutter) isolate.
class Pt {
  final double x;
  final double y;

  const Pt(this.x, this.y);

  Pt scaled(double sx, double sy) => Pt(x * sx, y * sy);

  @override
  String toString() => 'Pt($x, $y)';
}
