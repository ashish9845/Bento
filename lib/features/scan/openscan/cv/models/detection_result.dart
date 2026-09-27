// Vendored from https://github.com/ethereal-developers/OpenScan
// (BSD-3-Clause, see third_party/openscan/LICENSE). Only import
// paths were adapted; logic is unchanged.

import 'quad.dart';

/// Result of running document-boundary detection on an image. Replaces the
/// old raw `List` / silently-empty-on-failure contract with an explicit
/// three-way outcome so the UI can never be left waiting forever.
abstract class DetectionResult {
  const new();
}

/// A convex document-shaped quadrilateral was found.
class DetectionSuccess extends DetectionResult {
  final Quad quad;
  final int imageWidth;
  final int imageHeight;

  const new(this.quad, this.imageWidth, this.imageHeight);
}

/// Detection ran without error, but no suitable quad was found.
class DetectionNotFound extends DetectionResult {
  final int imageWidth;
  final int imageHeight;

  const new(this.imageWidth, this.imageHeight);
}

/// Detection threw (corrupt image, decode failure, timeout, etc).
class DetectionFailure extends DetectionResult {
  final String message;

  const new(this.message);

  @override
  String toString() => 'DetectionFailure($message)';
}

/// Result of running the perspective crop.
abstract class CropResult {
  const new();
}

class CropSuccess extends CropResult {
  final String path;

  const new(this.path);

  @override
  String toString() => 'CropSuccess($path)';
}

class CropFailure extends CropResult {
  final String message;

  const new(this.message);

  @override
  String toString() => 'CropFailure($message)';
}
