package sa.safi.android

import android.app.admin.DevicePolicyManager
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.os.Build
import android.provider.Settings
import android.view.inputmethod.InputMethodManager
import java.io.File
import java.security.KeyStore
import java.util.Date

class AuditChannel(private val activity: MainActivity) {

    fun scanPackages(): List<Map<String, Any>> {
        val pm = activity.packageManager
        val findings = mutableListOf<Map<String, Any>>()
        val packages = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            pm.getInstalledPackages(PackageManager.PackageInfoFlags.of(PackageManager.GET_PERMISSIONS.toLong()))
        } else {
            @Suppress("DEPRECATION")
            pm.getInstalledPackages(PackageManager.GET_PERMISSIONS)
        }

        for (pkg in packages) {
            val appInfo = pkg.applicationInfo
            val packageName = pkg.packageName
            if (packageName.startsWith("com.android") && (appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0) continue
            if (packageName == "sa.safi.android") continue

            val launchIntent = pm.getLaunchIntentForPackage(packageName)
            if (launchIntent == null && (appInfo.flags and ApplicationInfo.FLAG_SYSTEM) == 0) {
                findings.add(mapOf(
                    "id" to "${packageName}_hidden",
                    "ruleId" to "APP_HIDDEN_NO_LAUNCHER",
                    "packageName" to packageName,
                    "appName" to pm.getApplicationLabel(appInfo).toString(),
                    "version" to (pkg.versionName ?: "1.0"),
                    "installedAt" to Date(pkg.firstInstallTime).toString(),
                    "severity" to "critical",
                    "category" to "hiddenApp",
                    "evidence" to "No launcher activity"
                ))
            }

            val perms = pkg.requestedPermissions ?: emptyArray()
            val hasSms = perms.contains("android.permission.READ_SMS")
            val hasOverlay = perms.contains("android.permission.SYSTEM_ALERT_WINDOW")
            val hasAllFiles = perms.contains("android.permission.MANAGE_EXTERNAL_STORAGE")
            val hasInstall = perms.contains("android.permission.REQUEST_INSTALL_PACKAGES")
            val hasBgLocation = perms.contains("android.permission.ACCESS_BACKGROUND_LOCATION")

            if (hasSms && !packageName.contains("mms") && !packageName.contains("messenger") && !packageName.contains("sms")) {
                findings.add(makeFinding(packageName, appInfo, pkg, "PERM_SMS_READ_NO_MESSENGER", "critical", "permission", "READ_SMS without messenger role"))
            }
            if (hasOverlay) {
                if (!packageName.contains("com.google") && !packageName.contains("system")) {
                    findings.add(makeFinding(packageName, appInfo, pkg, "PERM_OVERLAY", "high", "permission", "SYSTEM_ALERT_WINDOW"))
                }
            }
            if (hasAllFiles && !isFileManager(packageName)) {
                findings.add(makeFinding(packageName, appInfo, pkg, "PERM_ALL_FILES_ACCESS", "high", "permission", "MANAGE_EXTERNAL_STORAGE"))
            }
            if (hasInstall && (appInfo.flags and ApplicationInfo.FLAG_SYSTEM) == 0) {
                findings.add(makeFinding(packageName, appInfo, pkg, "PERM_INSTALL_UNKNOWN", "high", "permission", "REQUEST_INSTALL_PACKAGES"))
            }
            if (hasBgLocation) {
                findings.add(makeFinding(packageName, appInfo, pkg, "PERM_BACKGROUND_LOCATION", "medium", "permission", "Background location"))
            }

            val dangerousCount = listOf(
                perms.contains("android.permission.CAMERA"),
                perms.contains("android.permission.RECORD_AUDIO"),
                perms.contains("android.permission.ACCESS_FINE_LOCATION"),
                perms.contains("android.permission.READ_SMS")
            ).count { it }
            if (dangerousCount >= 3) {
                findings.add(makeFinding(packageName, appInfo, pkg, "PERM_DANGEROUS_COMBO", "critical", "permission", "Camera+Mic+Location+SMS"))
            }

            try {
                val installer = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    pm.getInstallSourceInfo(packageName).installingPackageName
                } else {
                    @Suppress("DEPRECATION")
                    pm.getInstallerPackageName(packageName)
                }
                if (installer == null || (!installer.contains("com.android.vending") && !installer.contains("com.google.android.packageinstaller") && !installer.contains("com.sec.android"))) {
                    if ((appInfo.flags and ApplicationInfo.FLAG_SYSTEM) == 0) {
                        findings.add(makeFinding(packageName, appInfo, pkg, "APP_INSTALLED_OUTSIDE_STORE", "medium", "appSource", "Installer: $installer"))
                    }
                }
            } catch (_: Exception) {}

            if (System.currentTimeMillis() - pkg.firstInstallTime < 2 * 24 * 60 * 60 * 1000L) {
                if ((appInfo.flags and ApplicationInfo.FLAG_SYSTEM) == 0) {
                    findings.add(makeFinding(packageName, appInfo, pkg, "APP_NEWLY_INSTALLED", "medium", "appSource", "Installed <2 days"))
                }
            }
        }
        return findings
    }

    fun scanAccessibility(): List<Map<String, Any>> {
        val findings = mutableListOf<Map<String, Any>>()
        try {
            val enabledServices = Settings.Secure.getString(activity.contentResolver, Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES) ?: ""
            val services = enabledServices.split(":")
            for (svc in services) {
                if (svc.isEmpty()) continue
                if (!svc.contains("com.google") && !svc.contains("com.android") && !svc.contains("sa.safi")) {
                    findings.add(mapOf(
                        "id" to "acc_${svc.hashCode()}",
                        "ruleId" to "ACC_ENABLED_UNFAMILIAR",
                        "packageName" to svc.split("/")[0],
                        "appName" to svc,
                        "version" to "1.0",
                        "installedAt" to Date().toString(),
                        "severity" to "critical",
                        "category" to "watcher",
                        "evidence" to "Accessibility service enabled: $svc"
                    ))
                }
            }
        } catch (_: Exception) {}
        return findings
    }

    fun scanDeviceAdmins(): List<Map<String, Any>> {
        val findings = mutableListOf<Map<String, Any>>()
        try {
            val dpm = activity.getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
            val admins = dpm.activeAdmins ?: emptyList()
            for (admin in admins) {
                val pkg = admin.packageName
                if (!pkg.contains("com.google") && !pkg.contains("com.android") && pkg != "sa.safi.android") {
                    findings.add(mapOf(
                        "id" to "admin_${pkg}",
                        "ruleId" to "ADMIN_UNKNOWN_DEVICE_ADMIN",
                        "packageName" to pkg,
                        "appName" to pkg,
                        "version" to "1.0",
                        "installedAt" to Date().toString(),
                        "severity" to "high",
                        "category" to "deviceControl",
                        "evidence" to "Device admin active"
                    ))
                }
            }
            try {
                val deviceOwner = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR2) {
                    val method = dpm.javaClass.getMethod("getDeviceOwner")
                    method.invoke(dpm) as? String
                } else null
                if (deviceOwner != null && deviceOwner != "sa.safi.android") {
                    findings.add(mapOf(
                        "id" to "device_owner",
                        "ruleId" to "ADMIN_DEVICE_OWNER",
                        "packageName" to deviceOwner,
                        "appName" to deviceOwner,
                        "version" to "1.0",
                        "installedAt" to Date().toString(),
                        "severity" to "critical",
                        "category" to "deviceControl",
                        "evidence" to "Device owner set: $deviceOwner"
                    ))
                }
            } catch (_: Exception) {}
        } catch (_: Exception) {}
        return findings
    }

    fun scanNotificationListeners(): List<Map<String, Any>> {
        val findings = mutableListOf<Map<String, Any>>()
        try {
            val enabled = Settings.Secure.getString(activity.contentResolver, "enabled_notification_listeners") ?: ""
            val listeners = enabled.split(":")
            for (l in listeners) {
                if (l.isEmpty()) continue
                val pkg = l.split("/")[0]
                if (!pkg.contains("com.google") && !pkg.contains("com.android") && !pkg.contains("sa.safi")) {
                    findings.add(mapOf(
                        "id" to "notif_${pkg.hashCode()}",
                        "ruleId" to "LISTENER_NOTIFICATION_ACCESS",
                        "packageName" to pkg,
                        "appName" to pkg,
                        "version" to "1.0",
                        "installedAt" to Date().toString(),
                        "severity" to "critical",
                        "category" to "watcher",
                        "evidence" to "Notification listener: $l"
                    ))
                }
            }
        } catch (_: Exception) {}
        return findings
    }

    fun scanKeyboards(): List<Map<String, Any>> {
        val findings = mutableListOf<Map<String, Any>>()
        try {
            val imm = activity.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
            val methods = imm.enabledInputMethodList
            for (m in methods) {
                val pkg = m.packageName
                if (!pkg.contains("com.google.android.inputmethod") && !pkg.contains("com.android") && pkg != "sa.safi.android") {
                    findings.add(mapOf(
                        "id" to "ime_${pkg}",
                        "ruleId" to "INPUT_ALT_IME",
                        "packageName" to pkg,
                        "appName" to pkg,
                        "version" to "1.0",
                        "installedAt" to Date().toString(),
                        "severity" to "high",
                        "category" to "watcher",
                        "evidence" to "Third-party keyboard: $pkg"
                    ))
                }
            }
        } catch (_: Exception) {}
        return findings
    }

    fun scanCACerts(): List<Map<String, Any>> {
        val findings = mutableListOf<Map<String, Any>>()
        try {
            val ks = KeyStore.getInstance("AndroidCAStore")
            ks.load(null, null)
            val aliases = ks.aliases()
            var userCertCount = 0
            while (aliases.hasMoreElements()) {
                val alias = aliases.nextElement()
                if (alias.startsWith("user:")) userCertCount++
            }
            if (userCertCount > 0) {
                findings.add(mapOf(
                    "id" to "ca_user",
                    "ruleId" to "NET_USER_CA_INSTALLED",
                    "packageName" to "system",
                    "appName" to "User CA Certificates",
                    "version" to "1.0",
                    "installedAt" to Date().toString(),
                    "severity" to "critical",
                    "category" to "network",
                    "evidence" to "$userCertCount user CA certs installed - possible HTTPS interception"
                ))
            }
        } catch (e: Exception) {
            findings.add(mapOf(
                "id" to "ca_unreadable",
                "ruleId" to "CERT_STORE_UNREADABLE",
                "packageName" to "system",
                "appName" to "CA Store",
                "version" to "1.0",
                "installedAt" to Date().toString(),
                "severity" to "unknown",
                "category" to "network",
                "evidence" to "Cannot read CA store: ${e.message}"
            ))
        }
        return findings
    }

    fun scanRootAndBoot(): List<Map<String, Any>> {
        val findings = mutableListOf<Map<String, Any>>()
        val suPaths = listOf("/system/bin/su", "/system/xbin/su", "/sbin/su", "/data/local/xbin/su", "/data/local/bin/su", "/system/sd/xbin/su", "/system/bin/failsafe/su", "/data/local/su", "/su/bin/su")
        for (path in suPaths) {
            if (File(path).exists()) {
                findings.add(mapOf(
                    "id" to "root_su",
                    "ruleId" to "ROOT_SU_BINARIES",
                    "packageName" to "system",
                    "appName" to "Root binary",
                    "version" to "1.0",
                    "installedAt" to Date().toString(),
                    "severity" to "critical",
                    "category" to "environment",
                    "evidence" to "SU binary found at $path"
                ))
                break
            }
        }
        val rootApps = listOf("com.topjohnwu.magisk", "eu.chainfire.supersu", "com.koushikdutta.superuser", "com.noshufou.android.su", "com.thirdparty.superuser")
        val pm = activity.packageManager
        for (pkg in rootApps) {
            try {
                pm.getPackageInfo(pkg, 0)
                findings.add(mapOf(
                    "id" to "root_app_$pkg",
                    "ruleId" to "ROOT_PACKAGE_MANAGER_APP",
                    "packageName" to pkg,
                    "appName" to pkg,
                    "version" to "1.0",
                    "installedAt" to Date().toString(),
                    "severity" to "high",
                    "category" to "environment",
                    "evidence" to "Root manager app installed"
                ))
            } catch (_: Exception) {}
        }
        val hookApps = listOf("de.robv.android.xposed.installer", "org.meowcat.edxposed.manager", "com.saurik.substrate")
        for (pkg in hookApps) {
            try {
                pm.getPackageInfo(pkg, 0)
                findings.add(mapOf(
                    "id" to "hook_$pkg",
                    "ruleId" to "ROOT_HOOKING_FRAMEWORK",
                    "packageName" to pkg,
                    "appName" to pkg,
                    "version" to "1.0",
                    "installedAt" to Date().toString(),
                    "severity" to "critical",
                    "category" to "environment",
                    "evidence" to "Hooking framework"
                ))
            } catch (_: Exception) {}
        }
        if (Build.TAGS?.contains("test-keys") == true) {
            findings.add(mapOf(
                "id" to "debuggable",
                "ruleId" to "SYS_DEBUGGABLE_BUILD",
                "packageName" to "system",
                "appName" to "System Build",
                "version" to Build.DISPLAY,
                "installedAt" to Date().toString(),
                "severity" to "high",
                "category" to "environment",
                "evidence" to "Test-keys build"
            ))
        }
        try {
            val adbEnabled = Settings.Global.getInt(activity.contentResolver, Settings.Global.ADB_ENABLED, 0) == 1
            if (adbEnabled) {
                findings.add(mapOf(
                    "id" to "adb_enabled",
                    "ruleId" to "SYS_ADB_UNSECURE",
                    "packageName" to "system",
                    "appName" to "ADB Debugging",
                    "version" to "1.0",
                    "installedAt" to Date().toString(),
                    "severity" to "medium",
                    "category" to "environment",
                    "evidence" to "ADB debugging enabled"
                ))
            }
        } catch (_: Exception) {}

        if (Build.FINGERPRINT.contains("generic") || Build.MODEL.contains("Emulator") || Build.MANUFACTURER.contains("Genymotion")) {
            findings.add(mapOf(
                "id" to "emulator",
                "ruleId" to "ENV_EMULATOR",
                "packageName" to "system",
                "appName" to "Emulator",
                "version" to "1.0",
                "installedAt" to Date().toString(),
                "severity" to "unknown",
                "category" to "environment",
                "evidence" to "Running on emulator"
            ))
        }

        return findings
    }

    fun getInstalledApps(): List<Map<String, Any>> {
        val pm = activity.packageManager
        val packages = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            pm.getInstalledPackages(PackageManager.PackageInfoFlags.of(PackageManager.GET_PERMISSIONS.toLong()))
        } else {
            @Suppress("DEPRECATION")
            pm.getInstalledPackages(PackageManager.GET_PERMISSIONS)
        }
        return packages.map { pkg ->
            mapOf(
                "packageName" to pkg.packageName,
                "appName" to pm.getApplicationLabel(pkg.applicationInfo).toString(),
                "version" to (pkg.versionName ?: "1.0"),
                "isSystem" to ((pkg.applicationInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0),
                "firstInstall" to pkg.firstInstallTime
            )
        }
    }

    fun openSettings(action: String) {
        val intent = when (action) {
            "accessibility" -> Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
            "device_admin" -> Intent(Settings.ACTION_SECURITY_SETTINGS)
            "ca_certs" -> Intent(Settings.ACTION_SECURITY_SETTINGS)
            "notification" -> Intent("android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS")
            else -> Intent(Settings.ACTION_SETTINGS)
        }
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        try {
            activity.startActivity(intent)
        } catch (_: Exception) {
            activity.startActivity(Intent(Settings.ACTION_SETTINGS).apply { addFlags(Intent.FLAG_ACTIVITY_NEW_TASK) })
        }
    }

    private fun makeFinding(pkgName: String, appInfo: ApplicationInfo, pkgInfo: android.content.pm.PackageInfo, ruleId: String, severity: String, category: String, evidence: String): Map<String, Any> {
        return mapOf(
            "id" to "${pkgName}_$ruleId",
            "ruleId" to ruleId,
            "packageName" to pkgName,
            "appName" to activity.packageManager.getApplicationLabel(appInfo).toString(),
            "version" to (pkgInfo.versionName ?: "1.0"),
            "installedAt" to Date(pkgInfo.firstInstallTime).toString(),
            "severity" to severity,
            "category" to category,
            "evidence" to evidence
        )
    }

    private fun isFileManager(pkg: String): Boolean {
        return pkg.contains("file") || pkg.contains("explorer") || pkg.contains("manager") || pkg.contains("cabinet")
    }
}
