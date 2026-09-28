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
import 'package:scan/features/tools/widgets/send_to_tool.dart';
import 'package:scan/features/tools/widgets/tool_progress.dart';
import 'package:scan/features/tools/widgets/tool_scaffold.dart';

class UnlockScreen extends StatefulWidget {
  const new({super.key, this.repository});

  /// Overridable for tests; defaults to the real FFI engine repository.
  final ToolsRepository? repository;

  @override
  State<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends State<UnlockScreen> {
  late final ToolCubit _cubit;
  late final TextEditingController _passwordCtrl;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    final repository =
        widget.repository ?? ToolsRepositoryImpl(PdfEngineDataSourceImpl());
    _passwordCtrl = TextEditingController();
    _cubit = ToolCubit(
      repository: repository,
      persistenceKey: 'unlock',
      processFn: (inputs, ctrl) async {
        final password = _passwordCtrl.text;
        ctrl.setProgress(null, 'Removing encryption…');
        final out = await repository.unlockPdf(
          inputs.first,
          password: password,
          outputName: ctrl.outputName,
        );
        return [out];
      },
    );
  }

  @override
  void dispose() {
    _passwordCtrl.dispose();
    unawaited(_cubit.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<ToolCubit, ToolState>(
        builder: (context, state) {
          final canRun =
              state.files.isNotEmpty &&
              _passwordCtrl.text.isNotEmpty &&
              !state.isProcessing;

          return ToolScaffold(
            title: 'Unlock PDF',
            subtitle: 'Remove password protection — fully offline.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilePickerCard(
                  files: state.files,
                  fileSizes: state.fileSizes,
                  allowedExtensions: const ['pdf'],
                  label: 'Protected PDF',
                  onPick: () =>
                      _cubit.pickFiles(allowedExtensions: const ['pdf']),
                  onClear: _cubit.clearFiles,
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
                                icon: Icon(
                                  _showPassword
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                ),
                                tooltip: _showPassword
                                    ? 'Hide password'
                                    : 'Show password',
                                onPressed: () => setState(
                                  () => _showPassword = !_showPassword,
                                ),
                              ),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Wrong passwords are reported, never retried silently. The unlocked copy has no security — re-protect it if needed.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (state.isProcessing)
                  ToolProgress(
                    label: state.message ?? 'Unlocking…',
                    progress: state.progress,
                  ),
                if (state.hasError)
                  ToolError(
                    message: state.message ?? 'Failed',
                    onRetry: _cubit.run,
                  ),
                if (state.hasResult)
                  ToolSuccess(
                    message: 'Unlocked! ${state.resultFiles.first.path}',
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
                  onPressed: canRun
                      ? () => runWithRename(
                          context: context,
                          ctrl: _cubit,
                          defaultName: defaultOutputName('Unlocked'),
                        )
                      : null,
                  icon: const Icon(Icons.lock_open_rounded),
                  label: const Text('Unlock'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
