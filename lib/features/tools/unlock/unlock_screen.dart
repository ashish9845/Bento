import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan/core/storage/open_file.dart';
import 'package:scan/features/tools/providers/tool_controller.dart';
import 'package:scan/features/tools/providers/tool_providers.dart';
import 'package:scan/features/tools/providers/tool_state.dart';
import 'package:scan/features/tools/widgets/file_picker_card.dart';
import 'package:scan/features/tools/widgets/rename_dialog.dart';
import 'package:scan/features/tools/widgets/send_to_tool.dart';
import 'package:scan/features/tools/widgets/tool_progress.dart';
import 'package:scan/features/tools/widgets/tool_scaffold.dart';

final unlockControllerProvider =
    StateNotifierProvider<ToolController, ToolState>((ref) {
  final repo = ref.watch(toolsRepositoryProvider);
  return ToolController(persistenceKey: 'unlock', processFn: (inputs, ctrl) async {
    final password = ref.read(unlockPasswordProvider);
    ctrl.setProgress(null, 'Removing encryption…');
    final out = await repo.unlockPdf(inputs.first, password: password, outputName: ctrl.outputName);
    return [out];
  });
});

final unlockPasswordProvider = StateProvider<String>((ref) => '');

class UnlockScreen extends ConsumerStatefulWidget {
  const UnlockScreen({super.key});
  @override
  ConsumerState<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends ConsumerState<UnlockScreen> {
  late final TextEditingController _passwordCtrl;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _passwordCtrl = TextEditingController(text: ref.read(unlockPasswordProvider));
  }

  @override
  void dispose() {
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(unlockControllerProvider);
    final ctrl = ref.read(unlockControllerProvider.notifier);
    final password = ref.watch(unlockPasswordProvider);
    final canRun = state.files.isNotEmpty && password.isNotEmpty && !state.isProcessing;

    return ToolScaffold(
      title: 'Unlock PDF',
      subtitle: 'Remove password protection — fully offline.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilePickerCard(
            files: state.files,
            allowedExtensions: const ['pdf'],
            label: 'Protected PDF',
            onPick: () => ctrl.pickFiles(allowedExtensions: const ['pdf']),
            onClear: ctrl.clearFiles,
          ),
          const SizedBox(height: 12),
          if (state.files.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      key: const ValueKey('unlock_password_field'),
                      controller: _passwordCtrl,
                      obscureText: !_showPassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'The password that opens this file',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(_showPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                          tooltip: _showPassword ? 'Hide password' : 'Show password',
                          onPressed: () => setState(() => _showPassword = !_showPassword),
                        ),
                      ),
                      onChanged: (v) => ref.read(unlockPasswordProvider.notifier).state = v,
                    ),
                    const SizedBox(height: 6),
                    Text('Wrong passwords are reported, never retried silently. The unlocked copy has no security — re-protect it if needed.',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (state.isProcessing) ToolProgress(label: state.message ?? 'Unlocking…', progress: state.progress),
          if (state.hasError) ToolError(message: state.message ?? 'Failed', onRetry: ctrl.run),
          if (state.hasResult)
            ToolSuccess(
              message: 'Unlocked! ${state.resultFiles.first.path}',
              onOpen: () => openDoc(context, state.resultFiles.first.path),
              onShare: ctrl.shareResult,
              onSendTo: () => SendToToolSheet.show(context, state.resultFiles.first),
            ),
          const SizedBox(height: 12),
          FilledButton.icon(
              onPressed: canRun
                  ? () => runWithRename(
                      context: context, ctrl: ctrl, defaultName: defaultOutputName('Unlocked'))
                  : null,
              icon: const Icon(Icons.lock_open_rounded),
              label: const Text('Unlock')),
        ],
      ),
    );
  }
}
