import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf_manipulator/pdf_manipulator.dart';
import 'package:scan/core/storage/open_file.dart';
import 'package:scan/data/tools/datasources/pdf_engine_data_source.dart';
import 'package:scan/data/tools/repositories/tools_repository.dart';
import 'package:scan/data/tools/repositories/tools_repository_impl.dart';
import 'package:scan/features/tools/providers/tool_cubit.dart';
import 'package:scan/features/tools/providers/tool_state.dart';
import 'package:scan/features/tools/widgets/file_picker_card.dart';
import 'package:scan/features/tools/widgets/rename_dialog.dart';
import 'package:scan/features/tools/widgets/send_to_tool.dart';
import 'package:scan/features/tools/widgets/tool_progress.dart';
import 'package:scan/features/tools/widgets/tool_scaffold.dart';

PdfImagePolicy _qualityPolicy(String quality) {
  switch (quality) {
    case 'low':
      return PdfImagePolicy.screen; // 72 ppi — smallest files
    case 'high':
      return PdfImagePolicy.lossless; // re-pack streams, no quality loss
    default:
      return PdfImagePolicy.ebook; // 150 ppi — balanced
  }
}

String _qualityLabel(String quality) {
  switch (quality) {
    case 'low':
      return 'high compression';
    case 'high':
      return 'high quality';
    default:
      return 'balanced';
  }
}

class CompressScreen extends StatefulWidget {
  const new({super.key, this.repository});

  /// Overridable for tests; defaults to the real FFI engine repository.
  final ToolsRepository? repository;

  @override
  State<CompressScreen> createState() => _CompressScreenState();
}

class _CompressScreenState extends State<CompressScreen> {
  late final ToolCubit _cubit;
  String _quality = 'medium';

  @override
  void initState() {
    super.initState();
    final repository =
        widget.repository ?? ToolsRepositoryImpl(PdfEngineDataSourceImpl());
    _cubit = ToolCubit(
      repository: repository,
      persistenceKey: 'compress',
      processFn: (inputs, ctrl) async {
        ctrl.setProgress(null, 'Compressing (${_qualityLabel(_quality)})…');
        final out = await repository.compressPdf(
          inputs.first,
          _qualityPolicy(_quality),
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<ToolCubit, ToolState>(
        builder: (context, state) {
          return ToolScaffold(
            title: 'Compress PDF',
            subtitle: 'Shrink file size with the native engine — best for scanned & image PDFs.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilePickerCard(
                  files: state.files,
                  fileSizes: state.fileSizes,
                  allowedExtensions: const ['pdf'],
                  label: 'PDF to compress',
                  onPick: () =>
                      _cubit.pickFiles(allowedExtensions: const ['pdf']),
                  onClear: _cubit.clearFiles,
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quality',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(value: 'low', label: Text('Low')),
                            ButtonSegment(
                              value: 'medium',
                              label: Text('Medium'),
                            ),
                            ButtonSegment(value: 'high', label: Text('High')),
                          ],
                          selected: {_quality},
                          showSelectedIcon: false,
                          onSelectionChanged: (s) =>
                              setState(() => _quality = s.first),
                          style: SegmentedButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Lower size = smaller file',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (state.isProcessing)
                  ToolProgress(
                    label: state.message ?? 'Compressing…',
                    progress: state.progress,
                  ),
                if (state.hasError)
                  ToolError(
                    message: state.message ?? 'Failed',
                    onRetry: _cubit.run,
                  ),
                if (state.hasResult)
                  ToolSuccess(
                    message: 'Compressed! ${state.resultFiles.first.path}',
                    onOpen: () =>
                        openDoc(context, state.resultFiles.first.path),
                    onShare: _cubit.shareResult,
                    onSendTo: () => SendToToolSheet.show(
                      context,
                      state.resultFiles.first.path,
                    ),
                  ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: state.files.isEmpty || state.isProcessing
                      ? null
                      : () => runWithRename(
                          context: context,
                          ctrl: _cubit,
                          defaultName: defaultOutputName('Compressed'),
                        ),
                  icon: const Icon(Icons.compress),
                  label: const Text('Compress'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
