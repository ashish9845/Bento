import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan/core/storage/open_file.dart';
import 'package:scan/features/tools/providers/tool_controller.dart';
import 'package:scan/features/tools/providers/tool_providers.dart';
import 'package:scan/features/tools/providers/tool_state.dart';
import 'package:scan/features/tools/widgets/file_picker_card.dart';
import 'package:scan/features/tools/widgets/tool_progress.dart';
import 'package:scan/features/tools/widgets/tool_scaffold.dart';

final signControllerProvider =
    StateNotifierProvider<ToolController, ToolState>((ref) {
  final repo = ref.watch(toolsRepositoryProvider);
  return ToolController(processFn: (inputs, ctrl) async {
    final sigBytes = ref.read(signatureProvider);
    if (sigBytes == null) {
      throw Exception('Draw and save your signature first');
    }
    final page = ref.read(signPageProvider);
    final size = ref.read(signSizeProvider);
    ctrl.setProgress(null, 'Stamping signature onto page ${page + 1}…');
    final out = await repo.signPdf(
      inputs.first,
      signaturePng: sigBytes,
      page: page,
      widthPts: _signWidth(size),
    );
    return [out];
  });
});

final signatureProvider = StateProvider<Uint8List?>((ref) => null);
final signPageProvider = StateProvider<int>((ref) => 0);
final signSizeProvider = StateProvider<String>((ref) => 'medium');

double _signWidth(String size) {
  switch (size) {
    case 'small':
      return 100;
    case 'large':
      return 180;
    default:
      return 140;
  }
}

class SignScreen extends ConsumerStatefulWidget {
  const SignScreen({super.key});
  @override
  ConsumerState<SignScreen> createState() => _SignScreenState();
}

class _SignScreenState extends ConsumerState<SignScreen> {
  final List<Offset> _points = [];

  /// While a stroke is in progress, page scrolling is locked so the
  /// signature pad — not the page — receives the drag.
  bool _drawing = false;

  Future<Uint8List> _rasterize() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 300, 150));
    canvas.drawRect(const Rect.fromLTWH(0, 0, 300, 150), Paint()..color = const Color(0xFFFFFFFF));
    final paint = Paint()
      ..color = const Color(0xFF000000)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < _points.length - 1; i++) {
      if (_points[i] != Offset.zero && _points[i + 1] != Offset.zero) {
        canvas.drawLine(_points[i], _points[i + 1], paint);
      }
    }
    final picture = recorder.endRecording();
    final img = await picture.toImage(300, 150);
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return bytes!.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signControllerProvider);
    final ctrl = ref.read(signControllerProvider.notifier);
    final hasSig = ref.watch(signatureProvider) != null;

    final page = ref.watch(signPageProvider);
    final size = ref.watch(signSizeProvider);
    final pageCountAsync = state.files.isEmpty
        ? null
        : ref.watch(pdfPageCountProvider(state.files.first.path));

    Future<void> pickFile() async {
      await ctrl.pickFiles(allowedExtensions: const ['pdf']);
      ref.read(signPageProvider.notifier).state = 0;
    }

    return ToolScaffold(
      title: 'Sign PDF',
      subtitle: 'Your signature is stamped onto the original pages — content is preserved.',
      physics: _drawing ? const NeverScrollableScrollPhysics() : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilePickerCard(
            files: state.files,
            allowedExtensions: const ['pdf'],
            label: 'PDF to sign',
            onPick: pickFile,
            onClear: ctrl.clearFiles,
          ),
          const SizedBox(height: 12),
          if (state.files.isNotEmpty)
            pageCountAsync?.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Could not read page count: $e'),
                  data: (count) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Placement', style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: 12),
                          Row(children: [
                            IconButton.filledTonal(
                              icon: const Icon(Icons.chevron_left_rounded),
                              onPressed: page <= 0
                                  ? null
                                  : () => ref.read(signPageProvider.notifier).state = page - 1,
                              tooltip: 'Previous page',
                            ),
                            Expanded(
                              child: Text('Page ${page + 1} of $count',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.titleSmall),
                            ),
                            IconButton.filledTonal(
                              icon: const Icon(Icons.chevron_right_rounded),
                              onPressed: page >= count - 1
                                  ? null
                                  : () => ref.read(signPageProvider.notifier).state = page + 1,
                              tooltip: 'Next page',
                            ),
                          ]),
                          const SizedBox(height: 12),
                          Text('Size', style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: 8),
                          SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(value: 'small', label: Text('Small')),
                              ButtonSegment(value: 'medium', label: Text('Balanced')),
                              ButtonSegment(value: 'large', label: Text('Large')),
                            ],
                            selected: {size},
                            onSelectionChanged: (s) =>
                                ref.read(signSizeProvider.notifier).state = s.first,
                          ),
                          const SizedBox(height: 4),
                          Text('Stamped bottom-right, aspect preserved',
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ),
                ) ??
                const SizedBox.shrink(),
          if (state.files.isNotEmpty) const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Signature', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).colorScheme.outline),
                      borderRadius: BorderRadius.circular(8),
                      // Paper white is intentional for signature ink visibility in both themes
                      color: const Color(0xFFFFFFFF),
                    ),
                    child: Listener(
                      onPointerDown: (_) => setState(() => _drawing = true),
                      onPointerUp: (_) => setState(() => _drawing = false),
                      onPointerCancel: (_) => setState(() => _drawing = false),
                      child: GestureDetector(
                        onPanUpdate: (d) => setState(() => _points.add(d.localPosition)),
                        onPanEnd: (_) => setState(() {
                          _points.add(Offset.zero);
                          _drawing = false;
                        }),
                        child: CustomPaint(painter: _SigPainter(_points), size: const Size(300, 150)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      OutlinedButton(
                          onPressed: () => setState(_points.clear),
                          child: const Text('Clear')),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () async {
                          if (_points.isEmpty) return;
                          final bytes = await _rasterize();
                          ref.read(signatureProvider.notifier).state = bytes;
                        },
                        child: const Text('Save signature'),
                      ),
                      const Spacer(),
                      if (hasSig) const Icon(Icons.check_circle, color: Colors.green),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (state.isProcessing) ToolProgress(label: state.message ?? 'Signing…'),
          if (state.hasError) ToolError(message: state.message ?? 'Failed', onRetry: ctrl.run),
          if (state.hasResult) ...[
            ToolSuccess(message: 'Signed!', onSave: ctrl.saveToDocuments, onShare: ctrl.shareResult),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => OpenFilex.open(state.resultFiles.first.path),
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text('Open signed PDF'),
            ),
          ],
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: state.files.isEmpty || !hasSig || state.isProcessing ? null : ctrl.run,
            icon: const Icon(Icons.draw_outlined),
            label: const Text('Apply signature'),
          ),
          if (state.files.isNotEmpty && !hasSig)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('Draw your signature and tap “Save signature” first',
                  textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
            ),
        ],
      ),
    );
  }
}

class _SigPainter extends CustomPainter {
  _SigPainter(this.points);
  final List<Offset> points;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF000000)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < points.length - 1; i++) {
      if (points[i] != Offset.zero && points[i + 1] != Offset.zero) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SigPainter old) => old.points != points;
}
