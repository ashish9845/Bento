import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan/features/tools/providers/tool_controller.dart';
import 'package:scan/features/tools/providers/tool_state.dart';
import 'package:scan/features/tools/widgets/file_picker_card.dart';
import 'package:scan/features/tools/widgets/pdf_thumbnail_grid.dart';
import 'package:scan/features/tools/widgets/tool_progress.dart';
import 'package:scan/features/tools/widgets/tool_scaffold.dart';

final organizeControllerProvider = StateNotifierProvider<ToolController, ToolState>((ref) => ToolController());

class OrganizeScreen extends ConsumerStatefulWidget {
  const OrganizeScreen({super.key});
  @override
  ConsumerState<OrganizeScreen> createState() => _OrganizeScreenState();
}

class _OrganizeScreenState extends ConsumerState<OrganizeScreen> {
  final Set<int> _deleted = {};
  final Map<int, int> _rotations = {};

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(organizeControllerProvider);
    final ctrl = ref.read(organizeControllerProvider.notifier);
    return ToolScaffold(
      title: 'Organize Pages',
      subtitle: 'Rotate, delete, reorder — thumbnail grid',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilePickerCard(
            files: state.files,
            allowedExtensions: const ['pdf'],
            label: 'PDF to organize',
            onPick: () => ctrl.pickFiles(allowedExtensions: const ['pdf']),
            onClear: () {
              _deleted.clear();
              _rotations.clear();
              ctrl.clearFiles();
            },
          ),
          const SizedBox(height: 12),
          if (state.files.isNotEmpty)
            PdfThumbnailGrid(
              pageCount: 6,
              onDelete: (i) => setState(() => _deleted.add(i)),
              onRotate: (i) => setState(() => _rotations[i] = ((_rotations[i] ?? 0) + 90) % 360),
            ),
          if (_deleted.isNotEmpty || _rotations.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Pending: ${_deleted.length} deleted, ${_rotations.length} rotated',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          const SizedBox(height: 12),
          if (state.isProcessing) const ToolProgress(label: 'Organizing…'),
          if (state.hasError) ToolError(message: state.message ?? 'Failed', onRetry: ctrl.run),
          if (state.hasResult) ToolSuccess(message: 'Organized!', onSave: ctrl.saveToDocuments, onShare: ctrl.shareResult),
          const SizedBox(height: 12),
          FilledButton.icon(onPressed: state.files.isEmpty || state.isProcessing ? null : ctrl.run, icon: const Icon(Icons.view_carousel_outlined), label: const Text('Apply')),
        ],
      ),
    );
  }
}
