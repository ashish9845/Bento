import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:scan/features/tools/providers/tool_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Picked tool files survive controller recreation (the process-death path):
/// they persist on pick, hydrate on next launch, and drop deleted files.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('picked files persist and hydrate across instances', () async {
    SharedPreferences.setMockInitialValues({});
    final dir = await Directory.systemTemp.createTemp('bento_ctrl');
    final live = File('${dir.path}/a.pdf')..writeAsBytesSync([1]);
    const gone = '/tmp/bento_ctrl_gone.pdf';

    final c1 = ToolController(persistenceKey: 'ctrltest');
    await Future<void>.delayed(const Duration(milliseconds: 50));
    c1.setFiles([live, File(gone)]);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final c2 = ToolController(persistenceKey: 'ctrltest');
    await Future<void>.delayed(const Duration(milliseconds: 200));
    expect(c2.state.files.map((f) => f.path), [live.path]);

    c2.clearFiles();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    final c3 = ToolController(persistenceKey: 'ctrltest');
    await Future<void>.delayed(const Duration(milliseconds: 200));
    expect(c3.state.files, isEmpty);
    await dir.delete(recursive: true);
  });

  test('no persistence without a key', () async {
    SharedPreferences.setMockInitialValues({});
    final c = ToolController();
    c.setFiles([File('/tmp/x.pdf')]);
    expect(c.state.files.single.path, '/tmp/x.pdf');
  });
}
