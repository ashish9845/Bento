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
import 'package:scan/features/tools/widgets/rename_dialog.dart';
import 'package:scan/features/tools/widgets/pdf_thumbnail_grid.dart';
import 'package:scan/features/tools/widgets/tool_progress.dart';
import 'package:scan/features/tools/widgets/tool_scaffold.dart';

class ExtractScreen extends StatefulWidget {
  const new({super.key, this.repository});

  /// Overridable for tests; defaults to the real FFI engine repository.
  final ToolsRepository? repository;

  @override
  State<ExtractScreen> createState() => _ExtractScreenState();
}

class _ExtractScreenState extends State<ExtractScreen> {
  late final ToolCubit _cubit;
  Set<int> _selected = {};
  Future<int>? _pageCountFuture;
  String? _pageCountPath;

  @override
  void initState() {
    super.initState();
    final repository =
        widget.repository ?? ToolsRepositoryImpl(PdfEngineDataSourceImpl());
    _cubit = ToolCubit(
      repository: repository,
      persistenceKey: 'extract',
      processFn: (inputs, ctrl) async {
        final selected = _selected.toList();
        if (selected.isEmpty) {
          throw Exception('Tap pages to select at least one');
        }
        ctrl.setProgress(null, 'Extracting ${selected.length} pages…');
        final out = await repository.extractPages(
          inputs.first,
          selected,
          outputName: ctrl.outputName,
        );
        return [out];
      },
    );
  }

  @override
  void dispose() {
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

  void _clearAll() {
    setState(() => _selected = {});
    _cubit.clearFiles();
  }

  Future<void> _pickFile() async {
    // Drop stale selection — page indices belong to the previous file.
    setState(() => _selected = {});
    await _cubit.pickFiles(allowedExtensions: const ['pdf']);
  }

  void _toggle(int i) {
    setState(() {
      if (_selected.contains(i)) {
        _selected = {..._selected}..remove(i);
      } else {
        _selected = {..._selected, i};
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<ToolCubit, ToolState>(
        listener: (context, state) => _onFilesChanged(state),
        builder: (context, state) {
          return ToolScaffold(
            title: 'Extract Pages',
            subtitle: 'Tap pages to select, then extract',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilePickerCard(
                  files: state.files,
                  fileSizes: state.fileSizes,
                  allowedExtensions: const ['pdf'],
                  label: 'PDF to extract from',
                  onPick: _pickFile,
                  onClear: _clearAll,
                ),
                const SizedBox(height: 12),
                if (state.files.isNotEmpty && _pageCountFuture != null)
                  FutureBuilder<int>(
                    future: _pageCountFuture,
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snap.hasError) {
                        return Text('Could not read page count: ${snap.error}');
                      }
                      return PdfThumbnailGrid(
                        pageCount: snap.data ?? 0,
                        selectedPages: _selected,
                        onTap: _toggle,
                      );
                    },
                  ),
                if (state.files.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${_selected.length} pages selected',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                const SizedBox(height: 12),
                if (state.isProcessing)
                  const ToolProgress(label: 'Extracting…'),
                if (state.hasError)
                  ToolError(
                    message: state.message ?? 'Failed',
                    onRetry: _cubit.run,
                  ),
                if (state.hasResult)
                  ToolSuccess(
                    message: 'Extracted ${_selected.length} pages',
                    onOpen: () =>
                        openDoc(context, state.resultFiles.first.path),
                    onShare: _cubit.shareResult,
                  ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed:
                      state.files.isEmpty ||
                          _selected.isEmpty ||
                          state.isProcessing
                      ? null
                      : () => runWithRename(
                          context: context,
                          ctrl: _cubit,
                          defaultName: defaultOutputName('Extracted'),
                        ),
                  icon: const Icon(Icons.filter_none),
                  label: const Text('Extract'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
