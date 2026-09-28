package com.benopdf.scan

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder

/// Keeps Bento's process out of the cached-app bucket while the ML Kit
/// scanner (an external Play Services activity) owns the foreground.
///
/// Without this, aggressive OEM killers (notably MIUI) freeze and kill
/// Bento mid-scan, so the plugin's pending MethodChannel result dies with
/// the process. A foreground service raises the process priority; on
/// Android 14+ this is a `shortService` (max ~3 minutes, no extra runtime
/// permission) which is exactly the "brief user-initiated task that must
/// not be interrupted" case. MainActivity.onActivityResult still stashes
/// the result as the fallback when a kill happens anyway.
class ScanGuardService : Service() {
    companion object {
        private const val CHANNEL_ID = "scan_guard"
        private const val NOTIFICATION_ID = 0x5CA9
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        createChannel()
        val notification = buildNotification()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_SHORT_SERVICE,
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
        return START_NOT_STICKY
    }

    /// Android 14+ caps shortService at ~3 minutes; stop cleanly instead of
    /// letting the system declare an ANR. Scanning itself continues (the ML
    /// Kit activity is a separate process) — only the guard is dropped.
    override fun onTimeout(startId: Int) {
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    private fun buildNotification(): Notification {
        val builder =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                Notification.Builder(this, CHANNEL_ID)
            } else {
                @Suppress("DEPRECATION")
                Notification.Builder(this)
            }
        return builder
            .setContentTitle("Scanning document")
            .setContentText("Keeping the scan session alive")
            .setSmallIcon(R.drawable.ic_stat_scan)
            .setOngoing(true)
            .setCategory(Notification.CATEGORY_SERVICE)
            .build()
    }

    private fun createChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = getSystemService(NotificationManager::class.java) ?: return
        manager.createNotificationChannel(
            NotificationChannel(
                CHANNEL_ID,
                "Scanning",
                NotificationManager.IMPORTANCE_LOW,
            ).apply {
                description = "Shown while the document scanner is open"
                setShowBadge(false)
            },
        )
    }
}
