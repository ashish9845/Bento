import 'dart:async';

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
import 'package:scan/features/tools/widgets/tool_progress.dart';
import 'package:scan/features/tools/widgets/tool_scaffold.dart';

class Pdf2ImageScreen extends StatefulWidget {
  const new({super.key, this.repository});

  /// Overridable for tests; defaults to the real FFI engine repository.
  final ToolsRepository? repository;

  @override
  State<Pdf2ImageScreen> createState() => _Pdf2ImageScreenState();
}

class _Pdf2ImageScreenState extends State<Pdf2ImageScreen> {
  late final ToolCubit _cubit;

  @override
  void initState() {
    super.initState();
    final repository =
        widget.repository ?? ToolsRepositoryImpl(PdfEngineDataSourceImpl());
    _cubit = ToolCubit(
      repository: repository,
      persistenceKey: 'pdf2image',
      processFn: (inputs, ctrl) {
        ctrl.setProgress(null, 'Exporting pages as images…');
        return repository.renderPages(
          inputs.first,
          outputName: ctrl.outputName,
        );
      },
    );
  }

  @override
  void dispose() {
    unawaited(_cubit.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<ToolCubit, ToolState>(
        builder: (context, state) {
          return ToolScaffold(
            title: 'PDF → Image',
            subtitle: 'Export pages as images',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilePickerCard(
                  files: state.files,
                  fileSizes: state.fileSizes,
                  allowedExtensions: const ['pdf'],
                  label: 'PDF to export',
                  onPick: () =>
                      _cubit.pickFiles(allowedExtensions: const ['pdf']),
                  onClear: _cubit.clearFiles,
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.image_outlined),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'PNG images, saved in a folder named after the PDF',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (state.isProcessing)
                  ToolProgress(label: state.message ?? 'Exporting…'),
                if (state.hasError)
                  ToolError(
                    message: state.message ?? 'Failed',
                    onRetry: _cubit.run,
                  ),
                if (state.hasResult)
                  ToolSuccess(
                    message:
                        'Exported ${state.resultFiles.length} image(s) to ${state.resultFiles.first.parent.path.split('/').last}/',
                    onOpenFolder: () => openFolder(
                      context,
                      state.resultFiles.first.parent.path,
                    ),
                    onShare: _cubit.shareResult,
                  ),
                if (!state.hasResult) ...[
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: state.files.isEmpty || state.isProcessing
                        ? null
                        : () {
                            final stem = state.files.first.path
                                .split('/')
                                .last
                                .replaceAll(
                                  RegExp(r'\.pdf$', caseSensitive: false),
                                  '',
                                );
                            final fallback = stem.isEmpty ? 'Images' : stem;
                            unawaited(
                              runWithRename(
                                context: context,
                                ctrl: _cubit,
                                defaultName: fallback,
                                title: 'Name the image folder',
                              ),
                            );
                          },
                    icon: const Icon(Icons.image),
                    label: const Text('Export'),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
