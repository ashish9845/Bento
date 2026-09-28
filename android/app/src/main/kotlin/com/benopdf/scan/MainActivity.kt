package com.benopdf.scan

import android.content.Intent
import android.content.SharedPreferences
import android.os.Build
import android.util.Log
import com.google.mlkit.vision.documentscanner.GmsDocumentScanningResult
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray

class MainActivity : FlutterActivity() {
    companion object {
        private const val FOLDERS_CHANNEL = "com.benopdf.scan/folders"
        private const val SCAN_RECOVERY_CHANNEL = "com.benopdf.scan/scan_recovery"

        /// Request code the ML Kit document scanner plugin starts its
        /// activity with (google_mlkit_document_scanner DocumentScanner.kt).
        private const val SCAN_REQUEST_CODE = 0x362738

        /// Dedicated prefs file (separate from Flutter's) so a recovery
        /// record survives the app process being killed mid-scan.
        private const val RECOVERY_PREFS = "scan_recovery"
        private const val RECOVERY_KEY = "pending_images"
        private const val TAG = "BentoScanRecovery"

        /// Well-known file manager packages, checked in order. The system
        /// default manager is one of these on virtually every OEM skin, so
        /// launching the first installed one opens "the phone's file manager"
        /// when no app handles a direct folder-view intent.
        private val FILE_MANAGER_PACKAGES = listOf(
            "com.android.documentsui",
            "com.google.android.documentsui",
            "com.miui.fileexplorer",
            "com.sec.android.app.myfiles",
            "com.oneplus.filemanager",
            "com.coloros.filemanager",
            "com.vivo.filemanager",
            "com.asus.filemanager",
            "com.motorola.filemanager",
            "com.lge.filemanager",
            "com.huawei.filemanager",
            "com.zte.filemanager",
        )
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            FOLDERS_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "launchFileManager" -> result.success(launchFileManager())
                else -> result.notImplemented()
            }
        }
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SCAN_RECOVERY_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "consumeRecoveredScan" -> result.success(consumeRecoveredScan())
                "clearRecoveredScan" -> {
                    clearRecoveredScan()
                    result.success(null)
                }
                "beginScanSession" -> {
                    startScanGuard()
                    result.success(null)
                }
                "endScanSession" -> {
                    stopScanGuard()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    /// Raise the process priority while the ML Kit scanner is in front so
    /// OEM killers (notably MIUI) stop treating Bento as a cached app and
    /// killing it mid-scan. Best effort — a failed guard never blocks the
    /// scan; the stash-based recovery is the fallback.
    private fun startScanGuard() {
        try {
            val intent = Intent(this, ScanGuardService::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                startForegroundService(intent)
            } else {
                startService(intent)
            }
        } catch (e: Exception) {
            Log.w(TAG, "could not start scan guard service", e)
        }
    }

    private fun stopScanGuard() {
        try {
            stopService(Intent(this, ScanGuardService::class.java))
        } catch (e: Exception) {
            Log.w(TAG, "could not stop scan guard service", e)
        }
    }

    /// The ML Kit scanner runs in Play Services' process. If Android kills
    /// Bento while that UI is in front, the plugin's pending MethodChannel
    /// result dies with the process and the scanned image paths are dropped
    /// even though the files remain in the app cache. Stash them before the
    /// plugin sees the result; Dart reads (and clears) the stash when the
    /// Scan screen opens after a restart. Normal scans clear it immediately.
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode != SCAN_REQUEST_CODE) {
            super.onActivityResult(requestCode, resultCode, data)
            return
        }
        if (resultCode == RESULT_OK && data != null) {
            stashScanResult(data)
        }
        try {
            super.onActivityResult(requestCode, resultCode, data)
        } catch (e: Exception) {
            // Never let plugin result delivery crash the app; the stash
            // above is what recovery works from.
            Log.w(TAG, "scanner result delivery failed", e)
        }
    }

    private fun stashScanResult(data: Intent) {
        try {
            val result = GmsDocumentScanningResult.fromActivityResultIntent(data) ?: return
            val images = result.pages.orEmpty().mapNotNull { it.imageUri.path }
            if (images.isEmpty()) return
            recoveryPrefs()
                .edit()
                .putString(RECOVERY_KEY, JSONArray(images).toString())
                .commit()
        } catch (e: Exception) {
            Log.w(TAG, "could not stash scan result", e)
        }
    }

    private fun consumeRecoveredScan(): List<String> {
        val json = recoveryPrefs().getString(RECOVERY_KEY, null) ?: return emptyList()
        clearRecoveredScan()
        return try {
            val array = JSONArray(json)
            List(array.length()) { array.getString(it) }
        } catch (e: Exception) {
            Log.w(TAG, "could not read stashed scan result", e)
            emptyList()
        }
    }

    private fun clearRecoveredScan() {
        recoveryPrefs().edit().remove(RECOVERY_KEY).apply()
    }

    private fun recoveryPrefs(): SharedPreferences =
        getSharedPreferences(RECOVERY_PREFS, MODE_PRIVATE)

    /// Opens the default file manager app (first installed known package).
    /// Returns true when an app was launched. Package visibility for these
    /// packages is declared in `<queries>` (no extra permission needed).
    private fun launchFileManager(): Boolean {
        for (pkg in FILE_MANAGER_PACKAGES) {
            try {
                val intent =
                    packageManager.getLaunchIntentForPackage(pkg) ?: continue
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(intent)
                return true
            } catch (_: Exception) {
                // Try the next candidate.
            }
        }
        return false
    }
}
