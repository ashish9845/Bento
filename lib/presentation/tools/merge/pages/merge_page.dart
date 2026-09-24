import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/widgets/buttons/app_button.dart';
import '../../../shared/widgets/feedback/app_error_view.dart';
import '../bloc/mutation/merge_mutation_bloc.dart';
import '../bloc/mutation/merge_mutation_event.dart';
import '../bloc/mutation/merge_mutation_state.dart';

/// MergePage — strict Repository -> MutationBloc -> UI.
/// UI never imports Repository directly; Bloc is provided at route level.
class MergePage extends StatefulWidget {
  const MergePage({super.key});
  @override
  State<MergePage> createState() => _MergePageState();
}

class _MergePageState extends State<MergePage> {
  List<String> _pickedPaths = [];

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      setState(() => _pickedPaths = result.paths.whereType<String>().toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Merge PDFs')),
      body: BlocListener<MergeMutationBloc, MergeMutationState>(
        listener: (context, state) {
          if (state.status == MergeMutationStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Merged! Check Files.')));
            // Trigger Files query refresh if FilesPage is listening — via event bus or direct read if available.
          } else if (state.status == MergeMutationStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage ?? 'Failed')));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    Icon(Icons.picture_as_pdf_rounded, size: 32, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 8),
                    Text(_pickedPaths.isEmpty ? 'No files picked' : '${_pickedPaths.length} PDFs selected', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 12),
                    AppButton(label: 'Pick PDFs', isOutlined: true, onPressed: _pickFiles),
                    if (_pickedPaths.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ..._pickedPaths.map((p) => ListTile(dense: true, leading: const Icon(Icons.picture_as_pdf_outlined, size: 18), title: Text(p.split('/').last, overflow: TextOverflow.ellipsis))),
                    ],
                  ]),
                ),
              ),
              const SizedBox(height: 16),
              BlocBuilder<MergeMutationBloc, MergeMutationState>(
                builder: (context, state) {
                  final isLoading = state.status == MergeMutationStatus.inProgress;
                  if (state.status == MergeMutationStatus.failure) {
                    return AppErrorView(message: state.errorMessage ?? 'Failed', onRetry: () => context.read<MergeMutationBloc>().add(MergeMutationEvent.submitMerge(_pickedPaths)));
                  }
                  return AppButton(
                    label: 'Merge',
                    isLoading: isLoading,
                    onPressed: _pickedPaths.length < 2 || isLoading ? null : () => context.read<MergeMutationBloc>().add(MergeMutationEvent.submitMerge(_pickedPaths)),
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
