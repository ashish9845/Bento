import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:scan/data/tools/datasources/pdf_engine_data_source.dart';
import 'package:scan/data/tools/repositories/tools_repository.dart';
import 'package:scan/data/tools/repositories/tools_repository_impl.dart';
import 'package:scan/features/tools/providers/tool_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

ToolsRepository _repo() => ToolsRepositoryImpl(PdfEngineDataSourceImpl());

/// Picked tool files survive cubit recreation (the process-death path):
/// they persist on pick, hydrate on next launch, and drop deleted files.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('picked files persist and hydrate across instances', () async {
    SharedPreferences.setMockInitialValues({});
    final dir = await Directory.systemTemp.createTemp('bento_ctrl');
    final live = File('${dir.path}/a.pdf')..writeAsBytesSync([1]);
    const gone = '/tmp/bento_ctrl_gone.pdf';

    final c1 = ToolCubit(repository: _repo(), persistenceKey: 'ctrltest');
    await Future<void>.delayed(const Duration(milliseconds: 50));
    c1.setFiles([live, File(gone)]);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final c2 = ToolCubit(repository: _repo(), persistenceKey: 'ctrltest');
    await Future<void>.delayed(const Duration(milliseconds: 200));
    expect(c2.state.files.map((f) => f.path), [live.path]);

    c2.clearFiles();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    final c3 = ToolCubit(repository: _repo(), persistenceKey: 'ctrltest');
    await Future<void>.delayed(const Duration(milliseconds: 200));
    expect(c3.state.files, isEmpty);
    await dir.delete(recursive: true);
  });

  test('no persistence without a key', () async {
    SharedPreferences.setMockInitialValues({});
    final c = ToolCubit(repository: _repo());
    c.setFiles([File('/tmp/x.pdf')]);
    expect(c.state.files.single.path, '/tmp/x.pdf');
  });
}
