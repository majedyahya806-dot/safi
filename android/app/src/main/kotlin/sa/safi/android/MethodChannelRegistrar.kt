package sa.safi.android

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

object MethodChannelRegistrar {
    fun register(engine: FlutterEngine, activity: MainActivity) {
        val channel = MethodChannel(engine.dartExecutor.binaryMessenger, "sa.safi.audit")
        val audit = AuditChannel(activity)
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "scanPackages" -> {
                    try {
                        val findings = audit.scanPackages()
                        result.success(findings)
                    } catch (e: Exception) {
                        result.error("SCAN_FAILED", e.message, null)
                    }
                }
                "scanAccessibility" -> result.success(audit.scanAccessibility())
                "scanDeviceAdmins" -> result.success(audit.scanDeviceAdmins())
                "scanNotificationListeners" -> result.success(audit.scanNotificationListeners())
                "scanKeyboards" -> result.success(audit.scanKeyboards())
                "scanCACerts" -> result.success(audit.scanCACerts())
                "scanRootAndBoot" -> result.success(audit.scanRootAndBoot())
                "getInstalledApps" -> result.success(audit.getInstalledApps())
                "openSettings" -> {
                    val action = call.argument<String>("action") ?: "settings"
                    audit.openSettings(action)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }
}
