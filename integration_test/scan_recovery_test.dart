import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scan/features/scan/cubit/scan_cubit.dart';

/// Native scan-recovery channel round-trip (Android only): a stash written
/// into MainActivity's `scan_recovery` prefs file — exactly what
/// `MainActivity.onActivityResult` does when it gets the ML Kit result —
/// must be returned once by `consumeRecoveredScan` and then be gone.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('native stash is consumed once then cleared', (tester) async {
    if (!Platform.isAndroid) return;

    final support = await getApplicationSupportDirectory();
    final cache = await getTemporaryDirectory();
    final page = File('${cache.path}/recovery_probe.jpg')
      ..writeAsBytesSync([1, 2, 3]);

    final prefsFile = File(
      '${support.parent.path}/shared_prefs/scan_recovery.xml',
    );
    await prefsFile.parent.create(recursive: true);
    await prefsFile.writeAsString(
      "<?xml version='1.0' encoding='utf-8' standalone='yes' ?>\n"
      '<map>\n'
      '    <string name="pending_images">["${page.path}"]</string>\n'
      '</map>\n',
    );

    final gateway = MlKitScannerGatewayImpl();
    expect(await gateway.consumeRecoveredScan(), [page.path]);
    expect(await gateway.consumeRecoveredScan(), isEmpty);
  });
}
