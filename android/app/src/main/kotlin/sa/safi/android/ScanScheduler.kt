package sa.safi.android

import android.content.Context
import androidx.work.Worker
import androidx.work.WorkerParameters
import android.provider.Settings

class ScanScheduler(appContext: Context, params: WorkerParameters) : Worker(appContext, params) {
    override fun doWork(): Result {
        try {
            val cr = applicationContext.contentResolver
            val enabledAcc = Settings.Secure.getString(cr, Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES) ?: ""
            val enabledNotif = Settings.Secure.getString(cr, "enabled_notification_listeners") ?: ""
        } catch (_: Exception) {}
        return Result.success()
    }
}
