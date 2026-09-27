import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/storage/open_file.dart';
import '../../../shared/widgets/buttons/app_button.dart';
import '../../../shared/widgets/feedback/app_error_view.dart';
import '../bloc/mutation/merge_mutation_bloc.dart';
import '../bloc/mutation/merge_mutation_event.dart';
import '../bloc/mutation/merge_mutation_state.dart';

/// MergePage — strict Repository -> MutationBloc -> UI.
/// UI never imports Repository directly; Bloc is provided at route level.
class MergePage extends StatefulWidget {
  const new({super.key});
  @override
  State<MergePage> createState() => _MergePageState();
}

class _MergePageState extends State<MergePage> {
  List<String> _pickedPaths = [];

  Future<void> _pickFiles() async {
    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    final paths = picked
        .where((f) => f.path != null && f.path!.isNotEmpty)
        .map((f) => f.path!)
        .toList();
    if (paths.isNotEmpty) {
      setState(() => _pickedPaths = paths);
    }
  }

  Future<void> _mergeWithRename() async {
    if (_pickedPaths.length < 2) return;
    final now = DateTime.now();
    final defaultName =
        'Merged_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
    final controller = TextEditingController(text: defaultName);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Name your PDF'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'File name',
            hintText: 'Merged',
            suffixText: '.pdf',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
          onSubmitted: (v) => Navigator.pop(context, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Merge'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty || !mounted) return;
    context.read<MergeMutationBloc>().add(
      MergeMutationEvent.submitMerge(_pickedPaths, outputName: name),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Merge PDFs')),
      body: BlocListener<MergeMutationBloc, MergeMutationState>(
        listener: (context, state) {
          if (state.status == MergeMutationStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Merged: ${state.resultPath?.split('/').last ?? ''}',
                ),
              ),
            );
          } else if (state.status == MergeMutationStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Failed')),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.picture_as_pdf_rounded,
                        size: 32,
                        color: scheme.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _pickedPaths.isEmpty
                            ? 'No files picked'
                            : '${_pickedPaths.length} PDFs selected',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        label: 'Pick PDFs',
                        isOutlined: true,
                        onPressed: _pickFiles,
                      ),
                    ],
                  ),
                ),
              ),
              if (_pickedPaths.length >= 2) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Order — drag to rearrange',
                        style: Theme.of(context).textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => setState(() => _pickedPaths = []),
                      icon: const Icon(Icons.clear_all_rounded, size: 18),
                      label: const Text('Clear all'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                RepaintBoundary(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _pickedPaths.length,
                        onReorderItem: (oldIndex, newIndex) {
                          // onReorderItem already adjusts newIndex for the
                          // removed item — insert directly.
                          setState(() {
                            final item = _pickedPaths.removeAt(oldIndex);
                            _pickedPaths.insert(newIndex, item);
                          });
                        },
                        itemBuilder: (context, i) => ListTile(
                          key: ValueKey(_pickedPaths[i]),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: scheme.primaryContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${i + 1}',
                              style: TextStyle(
                                color: scheme.onPrimaryContainer,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          title: Text(
                            _pickedPaths[i].split('/').last,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.close_rounded, size: 18),
                                tooltip: 'Remove',
                                onPressed: () =>
                                    setState(() => _pickedPaths.removeAt(i)),
                              ),
                              const Icon(Icons.drag_handle_rounded),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              BlocBuilder<MergeMutationBloc, MergeMutationState>(
                builder: (context, state) {
                  final isLoading =
                      state.status == MergeMutationStatus.inProgress;
                  if (state.status == MergeMutationStatus.failure) {
                    return AppErrorView(
                      message: state.errorMessage ?? 'Failed',
                      onRetry: _mergeWithRename,
                    );
                  }
                  if (state.status == MergeMutationStatus.success &&
                      state.resultPath != null) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: scheme.primary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Saved: ${state.resultPath!.split('/').last}',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: AppButton(
                                label: 'Open PDF',
                                icon: Icons.open_in_new_rounded,
                                onPressed: () =>
                                    openDoc(context, state.resultPath!),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: AppButton(
                                label: 'Merge more',
                                isOutlined: true,
                                onPressed: () =>
                                    setState(() => _pickedPaths = []),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                  return AppButton(
                    label: 'Merge',
                    isLoading: isLoading,
                    onPressed: _pickedPaths.length < 2 || isLoading
                        ? null
                        : _mergeWithRename,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
