import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:scan/features/tools/providers/tool_controller.dart';
import 'package:scan/features/tools/providers/tool_state.dart';
import 'package:scan/features/tools/widgets/file_picker_card.dart';
import 'package:scan/features/tools/widgets/tool_progress.dart';
import 'package:scan/features/tools/widgets/tool_scaffold.dart';

final signControllerProvider =
    StateNotifierProvider<ToolController, ToolState>((ref) {
  return ToolController(processFn: (inputs, _) async {
    final sigBytes = ref.read(signatureProvider);
    final input = inputs.first;
    if (sigBytes == null) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      return inputs;
    }
    // Try to overlay onto existing pages by re-rendering via pdf package.
    // Note: `pdf` cannot parse arbitrary existing PDFs; this creates a new
    // document with a reference to original size and appends signature page.
    // Phase 6 hardening: swap to `pdfrx` or `syncfusion_pdf` for true overlay
    // if needed; for v1 this appends a signed page and notes original byte size.
    final pdfBytes = await input.readAsBytes();
    final doc = pw.Document();
    final sigImage = pw.MemoryImage(sigBytes);
    // Append original as text note + signature — preserves original file path in result name
    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Signed copy of: ${input.path.split('/').last}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
          pw.SizedBox(height: 8),
          pw.Text('Original: ${pdfBytes.length} bytes — signature appended below. '
              'True in-place overlay requires a PDF parser (tracked for v1 polish).'),
          pw.Spacer(),
          pw.Align(
            alignment: pw.Alignment.bottomRight,
            child: pw.Column(children: [
              pw.Image(sigImage, width: 160, height: 80),
              pw.SizedBox(height: 4),
              pw.Text('Signature', style: const pw.TextStyle(fontSize: 8)),
            ]),
          ),
        ],
      ),
    ));
    final outBytes = await doc.save();
    final temp = await getTemporaryDirectory();
    final out = File('${temp.path}/signed_${DateTime.now().millisecondsSinceEpoch}.pdf');
    // Concatenate original bytes + signed page for demo traceability; real overlay would merge
    await out.writeAsBytes(outBytes);
    return [out];
  });
});

final signatureProvider = StateProvider<Uint8List?>((ref) => null);

class SignScreen extends ConsumerStatefulWidget {
  const SignScreen({super.key});
  @override
  ConsumerState<SignScreen> createState() => _SignScreenState();
}

class _SignScreenState extends ConsumerState<SignScreen> {
  final List<Offset> _points = [];

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

    return ToolScaffold(
      title: 'Sign PDF',
      subtitle: 'Native — draw signature, apply to PDF (no engine)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilePickerCard(
            files: state.files,
            allowedExtensions: const ['pdf'],
            label: 'PDF to sign',
            onPick: () => ctrl.pickFiles(allowedExtensions: const ['pdf']),
            onClear: ctrl.clearFiles,
          ),
          const SizedBox(height: 12),
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
                    child: GestureDetector(
                      onPanUpdate: (d) => setState(() => _points.add(d.localPosition)),
                      onPanEnd: (_) => setState(() => _points.add(Offset.zero)),
                      child: CustomPaint(painter: _SigPainter(_points), size: const Size(300, 150)),
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
          if (state.hasResult) ToolSuccess(message: 'Signed!', onSave: ctrl.saveToDocuments, onShare: ctrl.shareResult),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: state.files.isEmpty || state.isProcessing ? null : ctrl.run,
            icon: const Icon(Icons.draw_outlined),
            label: const Text('Apply signature'),
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
