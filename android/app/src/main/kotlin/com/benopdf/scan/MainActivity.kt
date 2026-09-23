package com.benopdf.scan

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "com.benopdf.scan/scanner"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                if (call.method == "scanDocument") {
                    // TODO Phase 4: wire GmsDocumentScanner when adding
                    // com.google.android.gms:play-services-mlkit-document-scanner
                    // dependency in android/app/build.gradle.kts
                    // See docs/engine-mapping.md — fallback returns [] until plugin evaluated
                    result.success(emptyList<String>())
                } else {
                    result.notImplemented()
                }
            }
    }
}
