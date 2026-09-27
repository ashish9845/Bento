import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scan/core/storage/open_file.dart';

import '../../../shared/widgets/buttons/app_button.dart';
import '../../../shared/widgets/feedback/app_error_view.dart';
import '../bloc/mutation/image2pdf_mutation_bloc.dart';
import '../bloc/mutation/image2pdf_mutation_event.dart';
import '../bloc/mutation/image2pdf_mutation_state.dart';

class Image2PdfPage extends StatefulWidget {
  const new({super.key});
  @override
  State<Image2PdfPage> createState() => _Image2PdfPageState();
}

class _Image2PdfPageState extends State<Image2PdfPage> {
  List<String> _paths = [];

  Future<void> _pickImages() async {
    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
    );
    final paths = picked
        .where((f) => f.path != null && f.path!.isNotEmpty)
        .map((f) => f.path!)
        .toList();
    if (paths.isNotEmpty) {
      setState(() => _paths = paths);
    }
  }

  Future<void> _createWithRename() async {
    if (_paths.isEmpty) return;
    final now = DateTime.now();
    final defaultName =
        'Bento_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
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
            hintText: 'MyDocument',
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
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    if (!mounted) return;
    context.read<Image2PdfMutationBloc>().add(
      Image2PdfMutationEvent.submit(_paths, outputName: name),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image → PDF')),
      body: BlocListener<Image2PdfMutationBloc, Image2PdfMutationState>(
        listener: (context, state) {
          if (state.status == Image2PdfMutationStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'PDF created: ${state.resultPath?.split('/').last ?? ''}',
                ),
              ),
            );
          } else if (state.status == Image2PdfMutationStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Failed')),
            );
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
                  child: Column(
                    children: [
                      Icon(
                        Icons.image_rounded,
                        size: 32,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _paths.isEmpty
                            ? 'No images'
                            : '${_paths.length} images',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        label: 'Pick images',
                        isOutlined: true,
                        onPressed: _pickImages,
                      ),
                      if (_paths.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _paths
                              .map(
                                (p) => Chip(
                                  label: Text(
                                    p.split('/').last,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  avatar: const Icon(
                                    Icons.image_outlined,
                                    size: 16,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              BlocBuilder<Image2PdfMutationBloc, Image2PdfMutationState>(
                builder: (context, state) {
                  final isLoading =
                      state.status == Image2PdfMutationStatus.inProgress;
                  if (state.status == Image2PdfMutationStatus.failure) {
                    return AppErrorView(
                      message: state.errorMessage ?? 'Failed',
                      onRetry: _createWithRename,
                    );
                  }
                  if (state.status == Image2PdfMutationStatus.success &&
                      state.resultPath != null) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primaryContainer,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: Theme.of(context).colorScheme.primary,
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
                                label: 'Create another',
                                isOutlined: true,
                                onPressed: () => setState(() => _paths = []),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                  return AppButton(
                    label: 'Create PDF',
                    isLoading: isLoading,
                    onPressed: _paths.isEmpty || isLoading
                        ? null
                        : _createWithRename,
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
