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
import 'package:scan/features/tools/widgets/tool_progress.dart';
import 'package:scan/features/tools/widgets/tool_scaffold.dart';

/// Advisory strength label — never blocks, just nudges toward passphrases.
String _strengthLabel(String password) {
  var score = 0;
  if (password.length >= 8) score++;
  if (password.length >= 12) score++;
  if (RegExp('[A-Z]').hasMatch(password) &&
      RegExp('[a-z]').hasMatch(password)) {
    score++;
  }
  if (RegExp('[0-9]').hasMatch(password)) score++;
  if (RegExp('[^A-Za-z0-9]').hasMatch(password)) score++;
  if (score <= 2) return 'Weak';
  if (score <= 3) return 'Medium';
  return 'Strong';
}

class ProtectScreen extends StatefulWidget {
  const new({super.key, this.repository});

  /// Overridable for tests; defaults to the real FFI engine repository.
  final ToolsRepository? repository;

  @override
  State<ProtectScreen> createState() => _ProtectScreenState();
}

class _ProtectScreenState extends State<ProtectScreen> {
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
      persistenceKey: 'protect',
      processFn: (inputs, ctrl) async {
        final password = _passwordCtrl.text;
        ctrl.setProgress(null, 'Encrypting with AES-256…');
        final out = await repository.protectPdf(
          inputs.first,
          userPassword: password,
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
          final password = _passwordCtrl.text;
          final canRun =
              state.files.isNotEmpty &&
              password.isNotEmpty &&
              !state.isProcessing;

          return ToolScaffold(
            title: 'Protect PDF',
            subtitle: 'Lock with a password — AES-256, fully offline.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilePickerCard(
                  files: state.files,
                  allowedExtensions: const ['pdf'],
                  label: 'PDF to protect',
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
                            key: const ValueKey('protect_password_field'),
                            controller: _passwordCtrl,
                            obscureText: !_showPassword,
                            decoration: InputDecoration(
                              labelText: 'Set Password',
                              hintText: 'Needed to open the file',
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
                          if (password.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Strength: ${_strengthLabel(password)} — 12+ characters with mixed case, numbers and symbols is ideal',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                          const SizedBox(height: 6),
                          Text(
                            'The file needs this password to open, with no restrictions once opened.',
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
                    label: state.message ?? 'Encrypting…',
                    progress: state.progress,
                  ),
                if (state.hasError)
                  ToolError(
                    message: state.message ?? 'Failed',
                    onRetry: _cubit.run,
                  ),
                if (state.hasResult)
                  ToolSuccess(
                    message: 'Protected! ${state.resultFiles.first.path}',
                    onOpen: () =>
                        openDoc(context, state.resultFiles.first.path),
                    onShare: _cubit.shareResult,
                  ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: canRun
                      ? () => runWithRename(
                          context: context,
                          ctrl: _cubit,
                          defaultName: defaultOutputName('Protected'),
                        )
                      : null,
                  icon: const Icon(Icons.lock_rounded),
                  label: const Text('Protect'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
