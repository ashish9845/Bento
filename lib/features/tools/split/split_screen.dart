import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scan/core/storage/open_file.dart';
import 'package:scan/data/tools/datasources/pdf_engine_data_source.dart';
import 'package:scan/data/tools/repositories/tools_repository.dart';
import 'package:scan/data/tools/repositories/tools_repository_impl.dart';
import 'package:scan/features/tools/providers/tool_cubit.dart';
import 'package:scan/features/tools/providers/tool_state.dart';
import 'package:scan/features/tools/widgets/file_picker_card.dart';
import 'package:scan/features/tools/widgets/pdf_thumbnail_grid.dart';
import 'package:scan/features/tools/widgets/rename_dialog.dart';
import 'package:scan/features/tools/widgets/tool_progress.dart';
import 'package:scan/features/tools/widgets/tool_scaffold.dart';

class SplitScreen extends StatefulWidget {
  const new({super.key, this.repository});

  /// Overridable for tests; defaults to the real FFI engine repository.
  final ToolsRepository? repository;

  @override
  State<SplitScreen> createState() => _SplitScreenState();
}

class _SplitScreenState extends State<SplitScreen> {
  late final ToolCubit _cubit;
  late final TextEditingController _rangesCtrl;
  Future<int>? _pageCountFuture;
  String? _pageCountPath;

  @override
  void initState() {
    super.initState();
    final repository =
        widget.repository ?? ToolsRepositoryImpl(PdfEngineDataSourceImpl());
    _rangesCtrl = TextEditingController(text: '1-1, 2-end');
    _cubit = ToolCubit(
      repository: repository,
      persistenceKey: 'split',
      processFn: (inputs, ctrl) {
        final ranges = _rangesCtrl.text.trim();
        ctrl.setProgress(null, 'Splitting by "$ranges"…');
        return repository.splitPdf(
          inputs.first,
          ranges.isEmpty ? '1-end' : ranges,
          baseName: ctrl.outputName,
        );
      },
    );
  }

  @override
  void dispose() {
    _rangesCtrl.dispose();
    unawaited(_cubit.close());
    super.dispose();
  }

  void _onFilesChanged(ToolState state) {
    final path = state.files.isEmpty ? null : state.files.first.path;
    if (path != _pageCountPath) {
      setState(() {
        _pageCountPath = path;
        _pageCountFuture = path == null ? null : _cubit.pageCount(File(path));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<ToolCubit, ToolState>(
        listener: (context, state) => _onFilesChanged(state),
        builder: (context, state) {
          return ToolScaffold(
            title: 'Split PDF',
            subtitle: 'Split by ranges, e.g. 1-2, 3, 4-end',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilePickerCard(
                  files: state.files,
                  fileSizes: state.fileSizes,
                  allowedExtensions: const ['pdf'],
                  label: 'PDF to split',
                  onPick: () =>
                      _cubit.pickFiles(allowedExtensions: const ['pdf']),
                  onClear: _cubit.clearFiles,
                ),
                const SizedBox(height: 12),
                if (state.files.isNotEmpty) ...[
                  TextField(
                    key: const ValueKey('split_ranges_field'),
                    controller: _rangesCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Ranges',
                      hintText: '1-1, 2-end',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_pageCountFuture != null)
                    FutureBuilder<int>(
                      future: _pageCountFuture,
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snap.hasError) {
                          return Text(
                            'Could not read page count: ${snap.error}',
                          );
                        }
                        final count = snap.data ?? 0;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$count pages',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 8),
                            PdfThumbnailGrid(pageCount: count),
                          ],
                        );
                      },
                    ),
                ],
                const SizedBox(height: 12),
                if (state.isProcessing)
                  ToolProgress(label: state.message ?? 'Splitting…'),
                if (state.hasError)
                  ToolError(
                    message: state.message ?? 'Failed',
                    onRetry: _cubit.run,
                  ),
                if (state.hasResult) ...[
                  ToolSuccess(
                    message:
                        'Split into ${state.resultFiles.length} verified file(s)',
                    onShare: _cubit.shareResult,
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Column(
                      children: [
                        for (var i = 0; i < state.resultFiles.length; i++)
                          ListTile(
                            dense: true,
                            leading: const Icon(Icons.picture_as_pdf_outlined),
                            title: Text(
                              state.resultFiles[i].path.split('/').last,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.open_in_new_rounded),
                              tooltip: 'Open PDF',
                              onPressed: () =>
                                  openDoc(context, state.resultFiles[i].path),
                            ),
                            onTap: () =>
                                openDoc(context, state.resultFiles[i].path),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 2,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: state.files.isEmpty || state.isProcessing
                      ? null
                      : () => runWithRename(
                          context: context,
                          ctrl: _cubit,
                          defaultName: defaultOutputName('Split'),
                        ),
                  icon: const Icon(Icons.content_cut),
                  label: const Text('Split'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
