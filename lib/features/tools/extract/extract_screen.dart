import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan/features/tools/providers/tool_controller.dart';
import 'package:scan/features/tools/providers/tool_state.dart';
import 'package:scan/features/tools/widgets/file_picker_card.dart';
import 'package:scan/features/tools/widgets/pdf_thumbnail_grid.dart';
import 'package:scan/features/tools/widgets/tool_progress.dart';
import 'package:scan/features/tools/widgets/tool_scaffold.dart';

final extractControllerProvider = StateNotifierProvider<ToolController, ToolState>((ref) => ToolController());

class ExtractScreen extends ConsumerStatefulWidget {
  const ExtractScreen({super.key});
  @override
  ConsumerState<ExtractScreen> createState() => _ExtractScreenState();
}

class _ExtractScreenState extends ConsumerState<ExtractScreen> {
  final Set<int> _selected = {0,1};

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(extractControllerProvider);
    final ctrl = ref.read(extractControllerProvider.notifier);
    return ToolScaffold(
      title: 'Extract Pages',
      subtitle: 'Tap pages to select, then extract',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilePickerCard(
            files: state.files,
            allowedExtensions: const ['pdf'],
            label: 'PDF to extract from',
            onPick: () => ctrl.pickFiles(allowedExtensions: const ['pdf']),
            onClear: ctrl.clearFiles,
          ),
          const SizedBox(height: 12),
          if (state.files.isNotEmpty)
            PdfThumbnailGrid(pageCount: 6, selectedPages: _selected, onDelete: (i) => setState(() => _selected.contains(i) ? _selected.remove(i) : _selected.add(i))),
          if (state.files.isNotEmpty)
            Padding(padding: const EdgeInsets.only(top: 8), child: Text('${_selected.length} pages selected', style: Theme.of(context).textTheme.bodySmall)),
          const SizedBox(height: 12),
          if (state.isProcessing) const ToolProgress(label: 'Extracting…'),
          if (state.hasError) ToolError(message: state.message ?? 'Failed', onRetry: ctrl.run),
          if (state.hasResult) ToolSuccess(message: 'Extracted ${_selected.length} pages', onSave: ctrl.saveToDocuments, onShare: ctrl.shareResult),
          const SizedBox(height: 12),
          FilledButton.icon(onPressed: state.files.isEmpty || state.isProcessing ? null : ctrl.run, icon: const Icon(Icons.filter_none), label: const Text('Extract')),
        ],
      ),
    );
  }
}
