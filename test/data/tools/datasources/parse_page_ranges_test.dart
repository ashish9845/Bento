import 'package:flutter_test/flutter_test.dart';
import 'package:scan/data/tools/datasources/pdf_engine_data_source.dart';

void main() {
  group('parsePageRanges', () {
    test('parses single pages and ranges (1-based)', () {
      expect(parsePageRanges('1-3, 5', 10), [
        [0, 1, 2],
        [4],
      ]);
    });

    test('supports end keyword', () {
      expect(parsePageRanges('4-end', 6), [
        [3, 4, 5],
      ]);
      expect(parsePageRanges('1-1, 2-end', 3), [
        [0],
        [1, 2],
      ]);
    });

    test('ignores whitespace and case', () {
      expect(parsePageRanges(' 1 - 2 , 3 ', 5), [
        [0, 1],
        [2],
      ]);
      expect(parsePageRanges('2-END', 4), [
        [1, 2, 3],
      ]);
    });

    test('throws FormatException on out-of-range pages', () {
      expect(() => parsePageRanges('0', 5), throwsFormatException);
      expect(() => parsePageRanges('6', 5), throwsFormatException);
      expect(() => parsePageRanges('3-2', 5), throwsFormatException);
      expect(() => parsePageRanges('2-99', 5), throwsFormatException);
    });

    test('throws FormatException on garbage input', () {
      expect(() => parsePageRanges('', 5), throwsFormatException);
      expect(() => parsePageRanges(',,,', 5), throwsFormatException);
      expect(() => parsePageRanges('abc', 5), throwsFormatException);
      expect(() => parsePageRanges('1-2-3', 5), throwsFormatException);
    });
  });
}
