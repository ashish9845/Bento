import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:scan/data/tools/datasources/pdf_engine_data_source.dart';

img.Image _solid(int w, int h, img.Color color) {
  final image = img.Image(width: w, height: h);
  img.fill(image, color: color);
  return image;
}

void main() {
  group('letterboxToA4', () {
    test('wide panorama gains white bands top/bottom, ratio kept', () {
      final out = letterboxToA4(
        _solid(800, 200, img.ColorRgb8(255, 0, 0)),
      );
      expect(out.width, 800);
      expect(out.width / out.height, closeTo(a4Aspect, 0.005));
      expect(out.height, greaterThan(200));
      // Content row untouched (red), first row is padding (white).
      expect(out.getPixel(400, out.height ~/ 2), equals(img.ColorRgb8(255, 0, 0)));
      expect(out.getPixel(0, 0), equals(img.ColorRgb8(255, 255, 255)));
    });

    test('tall photo gains white bands left/right, ratio kept', () {
      final out = letterboxToA4(
        _solid(200, 800, img.ColorRgb8(0, 0, 255)),
      );
      expect(out.height, 800);
      expect(out.width / out.height, closeTo(a4Aspect, 0.005));
      expect(out.width, greaterThan(200));
      expect(out.getPixel(out.width ~/ 2, 400), equals(img.ColorRgb8(0, 0, 255)));
      expect(out.getPixel(0, 0), equals(img.ColorRgb8(255, 255, 255)));
    });

    test('near-A4 image passes through untouched', () {
      const wide = 595 * 2;
      const tall = 842 * 2;
      final out = letterboxToA4(_solid(wide, tall, img.ColorRgb8(0, 255, 0)));
      expect(out.width, wide);
      expect(out.height, tall);
    });

    test('huge photo is downscaled to the long-edge cap first', () {
      final out = letterboxToA4(
        _solid(6000, 4000, img.ColorRgb8(255, 255, 0)),
      );
      // Content scaled to a 3000px long edge; padding then extends the
      // canvas to A4 (padding may exceed the cap — only content is capped).
      expect(out.width, 3000);
      expect(out.width / out.height, closeTo(a4Aspect, 0.005));
    });
  });
}
