enum Severity { critical, high, medium, unknown }

enum RuleCategory {
  watcher, // من يراقب
  permission, // صلاحيات بلا مبرر
  deviceControl, // تحكم بالجهاز
  network, // شبكة وشهادات
  environment, // بيئة ملوثة
  appSource, // مصادر التطبيقات
  phishing, // NEW: مواقع احتيالية
  session, // NEW: جلسات دخول غريبة
  hiddenApp, // NEW: تطبيقات مخفية
}

class DetectionRule {
  final String id;
  final RuleCategory category;
  final Severity severity;
  final double weight;
  final String titleAr;
  final String titleEn;
  final String whyAr;
  final String whyEn;
  final String fixAr;

  const DetectionRule({
    required this.id,
    required this.category,
    required this.severity,
    required this.weight,
    required this.titleAr,
    required this.titleEn,
    required this.whyAr,
    required this.whyEn,
    required this.fixAr,
  });
}

class SafiRules {
  static const List<DetectionRule> v1_3 = [
    // من يراقب - 6 قواعد
    DetectionRule(id: 'ACC_ENABLED_UNFAMILIAR', category: RuleCategory.watcher, severity: Severity.critical, weight: 25, titleAr: 'خدمة وصول مجهولة نشطة', titleEn: 'Unknown accessibility service', whyAr: 'تطبيق يقرأ كل ما يظهر على الشاشة', whyEn: 'App reads screen content', fixAr: 'افتح إعدادات إمكانية الوصول وعطّل الخدمة'),
    DetectionRule(id: 'ACC_CAN_RETRIEVE_WINDOW', category: RuleCategory.watcher, severity: Severity.critical, weight: 22, titleAr: 'خدمة وصول تقرأ النوافذ', titleEn: 'Accessibility can retrieve windows', whyAr: 'يمكنه قراءة محتوى التطبيقات الأخرى', whyEn: 'Can read other apps content', fixAr: 'راجع الأذونات في الإعدادات'),
    DetectionRule(id: 'ACC_CAN_PERFORM_GESTURES', category: RuleCategory.watcher, severity: Severity.critical, weight: 20, titleAr: 'خدمة وصول تتحكم باللمس', titleEn: 'Accessibility can perform gestures', whyAr: 'يمكنه النقر نيابة عنك', whyEn: 'Can tap on your behalf', fixAr: 'عطّل الخدمة فوراً'),
    DetectionRule(id: 'ACC_KEY_FILTERING', category: RuleCategory.watcher, severity: Severity.critical, weight: 24, titleAr: 'فلترة مفاتيح مشبوهة', titleEn: 'Key filtering detected', whyAr: 'قد يسجل ما تكتبه', whyEn: 'May log keystrokes', fixAr: 'احذف التطبيق أو عطّل الخدمة'),
    DetectionRule(id: 'LISTENER_NOTIFICATION_ACCESS', category: RuleCategory.watcher, severity: Severity.critical, weight: 23, titleAr: 'قارئ إشعارات غير معروف', titleEn: 'Unknown notification reader', whyAr: 'يقرأ كل إشعاراتك بما فيها رموز التحقق', whyEn: 'Reads all notifications including OTP', fixAr: 'افتح إعدادات الإشعارات وألغِ الوصول'),
    DetectionRule(id: 'INPUT_ALT_IME', category: RuleCategory.watcher, severity: Severity.high, weight: 18, titleAr: 'لوحة مفاتيح بديلة نشطة', titleEn: 'Alternative keyboard active', whyAr: 'لوحة مفاتيح غير النظام قد تسجل كتاباتك', whyEn: 'Third-party keyboard may log input', fixAr: 'بدّل إلى Gboard أو لوحة النظام'),

    // صلاحيات بلا مبرر
    DetectionRule(id: 'PERM_SMS_READ_NO_MESSENGER', category: RuleCategory.permission, severity: Severity.critical, weight: 20, titleAr: 'يقرأ الرسائل بلا مبرر', titleEn: 'Reads SMS without need', whyAr: 'تطبيق ليس رسائل يطلب قراءة SMS', whyEn: 'Non-messenger requests SMS', fixAr: 'اسحب إذن الرسائل'),
    DetectionRule(id: 'PERM_DANGEROUS_COMBO', category: RuleCategory.permission, severity: Severity.critical, weight: 19, titleAr: 'تركيبة أذونات خطيرة', titleEn: 'Dangerous permission combo', whyAr: 'يجمع كاميرا+ميكروفون+موقع+رسائل', whyEn: 'Camera+Mic+Location+SMS combo', fixAr: 'راجع الأذونات وألغِ غير الضروري'),
    DetectionRule(id: 'PERM_OVERLAY', category: RuleCategory.permission, severity: Severity.high, weight: 15, titleAr: 'يظهر فوق التطبيقات', titleEn: 'Draw over other apps', whyAr: 'يمكنه تزوير واجهات تسجيل دخول', whyEn: 'Can fake login screens', fixAr: 'ألغِ إذن الظهور فوق التطبيقات'),
    DetectionRule(id: 'PERM_ALL_FILES_ACCESS', category: RuleCategory.permission, severity: Severity.high, weight: 14, titleAr: 'وصول لكل الملفات', titleEn: 'All files access', whyAr: 'يصل لكل صورك وملفاتك', whyEn: 'Access to all files', fixAr: 'اسحب إذن إدارة الملفات'),
    DetectionRule(id: 'PERM_INSTALL_UNKNOWN', category: RuleCategory.permission, severity: Severity.high, weight: 13, titleAr: 'يثبت تطبيقات مجهولة', titleEn: 'Install unknown apps', whyAr: 'يمكنه تثبيت برمجيات تجسس', whyEn: 'Can install spyware', fixAr: 'ألغِ إذن التثبيت'),
    DetectionRule(id: 'PERM_BACKGROUND_LOCATION', category: RuleCategory.permission, severity: Severity.medium, weight: 10, titleAr: 'موقع في الخلفية', titleEn: 'Background location', whyAr: 'يتتبعك حتى والتطبيق مغلق', whyEn: 'Tracks you in background', fixAr: 'اجعل الموقع عند الاستخدام فقط'),

    // تحكم بالجهاز
    DetectionRule(id: 'ADMIN_UNKNOWN_DEVICE_ADMIN', category: RuleCategory.deviceControl, severity: Severity.high, weight: 18, titleAr: 'مسؤول جهاز مجهول', titleEn: 'Unknown device admin', whyAr: 'يمنع حذفه ويتحكم بالجهاز', whyEn: 'Prevents uninstall, controls device', fixAr: 'افتح الأمان > مسؤولو الجهاز وعطّله'),
    DetectionRule(id: 'ADMIN_DEVICE_OWNER', category: RuleCategory.deviceControl, severity: Severity.critical, weight: 25, titleAr: 'مالك الجهاز خارجي', titleEn: 'Device owner set', whyAr: 'تحكم كامل كأنه شركة', whyEn: 'Full corporate control', fixAr: 'يلزم فورمات إذا لم تعرفه'),
    DetectionRule(id: 'ADMIN_PROFILE_OWNER', category: RuleCategory.deviceControl, severity: Severity.high, weight: 16, titleAr: 'ملف عمل مشبوه', titleEn: 'Suspicious work profile', whyAr: 'قد يخفي تطبيقات تجسس', whyEn: 'May hide spy apps', fixAr: 'احذف ملف العمل'),
    DetectionRule(id: 'SYS_BATTERY_EXEMPT_UNKNOWN', category: RuleCategory.deviceControl, severity: Severity.medium, weight: 8, titleAr: 'مستثنى من توفير البطارية', titleEn: 'Battery optimization exempt', whyAr: 'يعمل دائماً في الخلفية', whyEn: 'Always runs background', fixAr: 'أعد تفعيل تحسين البطارية'),

    // شبكة وشهادات
    DetectionRule(id: 'NET_USER_CA_INSTALLED', category: RuleCategory.network, severity: Severity.critical, weight: 22, titleAr: 'شهادة تجسس على الشبكة', titleEn: 'User CA certificate', whyAr: 'يفك تشفير HTTPS ويرى كلمات مرورك', whyEn: 'Decrypts HTTPS traffic', fixAr: 'احذف الشهادة من الإعدادات > التشفير'),
    DetectionRule(id: 'NET_VPN_UNSPECIFIED', category: RuleCategory.network, severity: Severity.medium, weight: 9, titleAr: 'VPN غير معروف نشط', titleEn: 'Unknown VPN active', whyAr: 'كل إنترنتك يمر عبره', whyEn: 'All traffic routed', fixAr: 'افحص تطبيق VPN'),
    DetectionRule(id: 'NET_INTERCEPT_TOOLING', category: RuleCategory.network, severity: Severity.high, weight: 17, titleAr: 'أدوات اعتراض شبكة', titleEn: 'Network interception tooling', whyAr: 'أدوات مثل Packet capture', whyEn: 'Packet capture tools', fixAr: 'احذفها إن لم تثبتها أنت'),
    DetectionRule(id: 'CERT_STORE_UNREADABLE', category: RuleCategory.network, severity: Severity.unknown, weight: 5, titleAr: 'تعذر فحص الشهادات', titleEn: 'Cert store unreadable', whyAr: 'لا يمكن التأكد من أمان الشبكة', whyEn: 'Cannot verify network security', fixAr: 'أعد تشغيل الجهاز'),

    // بيئة ملوثة
    DetectionRule(id: 'ROOT_SU_BINARIES', category: RuleCategory.environment, severity: Severity.critical, weight: 20, titleAr: 'الجهاز معمول له روت', titleEn: 'Device is rooted', whyAr: 'أي تطبيق يأخذ صلاحيات كاملة', whyEn: 'Any app can get root', fixAr: 'ألغِ الروت أو استخدم جهاز آخر للحساس'),
    DetectionRule(id: 'ROOT_HOOKING_FRAMEWORK', category: RuleCategory.environment, severity: Severity.critical, weight: 23, titleAr: 'إطار اختراق Xposed/Frida', titleEn: 'Hooking framework', whyAr: 'يعدل سلوك التطبيقات', whyEn: 'Modifies app behavior', fixAr: 'احذف Magisk/Xposed'),
    DetectionRule(id: 'ROOT_PACKAGE_MANAGER_APP', category: RuleCategory.environment, severity: Severity.high, weight: 16, titleAr: 'مدير روت مثبت', titleEn: 'Root manager app', whyAr: 'SuperSU/Magisk موجود', whyEn: 'SuperSU/Magisk present', fixAr: 'ألغِ الروت'),
    DetectionRule(id: 'BOOT_VERITY_DISABLED', category: RuleCategory.environment, severity: Severity.high, weight: 14, titleAr: 'التحقق عند الإقلاع معطل', titleEn: 'Boot verification disabled', whyAr: 'النظام قد يكون معدل', whyEn: 'System may be tampered', fixAr: 'أعد قفل البوتلودر'),
    DetectionRule(id: 'SYS_SELINUX_PERMISSIVE', category: RuleCategory.environment, severity: Severity.high, weight: 13, titleAr: 'SELinux متساهل', titleEn: 'SELinux permissive', whyAr: 'حماية النظام ضعيفة', whyEn: 'System protection weak', fixAr: 'يتطلب روم رسمي'),
    DetectionRule(id: 'SYS_ADB_UNSECURE', category: RuleCategory.environment, severity: Severity.medium, weight: 8, titleAr: 'تصحيح USB مفتوح', titleEn: 'ADB debugging open', whyAr: 'أي كمبيوتر يتحكم بجهازك', whyEn: 'PC can control device', fixAr: 'أغلق خيارات المطور'),
    DetectionRule(id: 'SYS_ADB_ROOT', category: RuleCategory.environment, severity: Severity.high, weight: 15, titleAr: 'ADB بصلاحيات روت', titleEn: 'ADB root enabled', whyAr: 'تحكم كامل عبر USB', whyEn: 'Full control via USB', fixAr: 'أغلق ADB root'),
    DetectionRule(id: 'SYS_DEBUGGABLE_BUILD', category: RuleCategory.environment, severity: Severity.high, weight: 12, titleAr: 'نسخة نظام قابلة للتصحيح', titleEn: 'Debuggable build', whyAr: 'روم غير آمن', whyEn: 'Insecure ROM', fixAr: 'ثبت روم رسمي'),
    DetectionRule(id: 'ENV_EMULATOR', category: RuleCategory.environment, severity: Severity.unknown, weight: 3, titleAr: 'يعمل على محاكي', titleEn: 'Running on emulator', whyAr: 'ليس هاتف حقيقي', whyEn: 'Not real device', fixAr: 'تجاهل إذا تختبر'),

    // مصادر التطبيقات
    DetectionRule(id: 'APP_INSTALLED_OUTSIDE_STORE', category: RuleCategory.appSource, severity: Severity.medium, weight: 9, titleAr: 'مثبت من خارج المتجر', titleEn: 'Installed outside store', whyAr: 'لم يمر بفحص Google Play', whyEn: 'Not Play Protect verified', fixAr: 'احذفه وثبته من المتجر'),
    DetectionRule(id: 'APP_SIDELOADED_FROM_MESSAGE', category: RuleCategory.appSource, severity: Severity.high, weight: 14, titleAr: 'مثبت من رسالة/واتساب', titleEn: 'Sideloaded from message', whyAr: 'طريقة شائعة لنشر التجسس', whyEn: 'Common spyware vector', fixAr: 'احذفه فوراً'),
    DetectionRule(id: 'APP_KNOWN_TRACKER_SIGNATURE', category: RuleCategory.appSource, severity: Severity.high, weight: 18, titleAr: 'توقيع متتبع معروف', titleEn: 'Known tracker signature', whyAr: 'مكتبة تجسس معروفة', whyEn: 'Known spy library', fixAr: 'احذف التطبيق'),
    DetectionRule(id: 'APP_NEWLY_INSTALLED', category: RuleCategory.appSource, severity: Severity.medium, weight: 6, titleAr: 'مثبت حديثاً', titleEn: 'Newly installed', whyAr: 'راجع إن كنت تعرفه', whyEn: 'Check if you know it', fixAr: 'راجع الأذونات'),
    DetectionRule(id: 'UPDATE_OUTDATED_APP', category: RuleCategory.appSource, severity: Severity.medium, weight: 7, titleAr: 'تطبيق قديم جداً', titleEn: 'Very outdated app', whyAr: 'به ثغرات معروفة', whyEn: 'Has known vulnerabilities', fixAr: 'حدّثه'),
    DetectionRule(id: 'UPDATE_DOWNGRADED', category: RuleCategory.appSource, severity: Severity.high, weight: 12, titleAr: 'تم تنزيل إصداره', titleEn: 'Downgraded app', whyAr: 'قد يكون تم استبداله بنسخة مخترقة', whyEn: 'May be replaced with hacked version', fixAr: 'حدّث من المتجر'),

    // NEW: كشف التطبيقات المخفية
    DetectionRule(id: 'APP_HIDDEN_NO_LAUNCHER', category: RuleCategory.hiddenApp, severity: Severity.critical, weight: 21, titleAr: 'تطبيق مخفي بلا أيقونة', titleEn: 'Hidden app no icon', whyAr: 'تطبيقات التجسس تخفي أيقونتها', whyEn: 'Spyware hides icon', fixAr: 'افتح الإعدادات > التطبيقات واحذفه'),
    DetectionRule(id: 'APP_HIDDEN_SYSTEM_FAKE', category: RuleCategory.hiddenApp, severity: Severity.high, weight: 16, titleAr: 'يتظاهر كتطبيق نظام', titleEn: 'Fake system app', whyAr: 'اسمه System Update لكنه ليس نظام', whyEn: 'Named System Update but not system', fixAr: 'احذفه - النظام لا يُحذف'),

    // NEW: جلسات دخول غريبة
    DetectionRule(id: 'SESSION_GOOGLE_NEW_DEVICE', category: RuleCategory.session, severity: Severity.critical, weight: 24, titleAr: 'دخول غريب على حساب Google', titleEn: 'New login on Google account', whyAr: 'جهاز من دولة أخرى سجل دخول', whyEn: 'Device from other country logged in', fixAr: 'افتح myaccount.google.com وأمّن حسابك'),
    DetectionRule(id: 'SESSION_SOCIAL_NEW_LOGIN', category: RuleCategory.session, severity: Severity.high, weight: 18, titleAr: 'جلسة جديدة على فيسبوك/انستا/تيكتوك', titleEn: 'New social media session', whyAr: 'حسابك مفتوح في مكان آخر', whyEn: 'Account open elsewhere', fixAr: 'راجع الأجهزة النشطة وأغلق الغريب'),

    // NEW: مواقع احتيالية
    DetectionRule(id: 'PHISHING_URL_DETECTED', category: RuleCategory.phishing, severity: Severity.critical, weight: 23, titleAr: 'موقع احتيالي يحاول سرقة بياناتك', titleEn: 'Phishing site detected', whyAr: 'هذا الموقع يقلد موقع حقيقي لسرقة كلمة المرور', whyEn: 'Mimics real site to steal password', fixAr: 'لا تدخل بياناتك - افحصه عبر VirusTotal'),
  ];

  static DetectionRule? byId(String id) {
    try {
      return v1_3.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }
}
