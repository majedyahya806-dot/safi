import 'package:url_launcher/url_launcher.dart';

enum PlatformType { google, facebook, instagram, tiktok, whatsapp, youtube, twitter, telegram, snapchat, other }

class SocialSession {
  final PlatformType platform;
  final String nameAr;
  final String nameEn;
  final String icon;
  final String checkUrl;
  final String descriptionAr;
  final bool requiresLogin;

  SocialSession(this.platform, this.nameAr, this.nameEn, this.icon, this.checkUrl, this.descriptionAr, this.requiresLogin);

  static List<SocialSession> all = [
    SocialSession(PlatformType.google, 'جوجل', 'Google', 'G', 'https://myaccount.google.com/device-activity', 'اعرف من دخل حسابك ومن أي دولة', true),
    SocialSession(PlatformType.facebook, 'فيسبوك', 'Facebook', 'f', 'https://www.facebook.com/settings/security_login', 'الأجهزة التي سجلت دخول لحسابك', true),
    SocialSession(PlatformType.instagram, 'انستقرام', 'Instagram', 'IG', 'https://www.instagram.com/accounts/access_tool/current_follow_requests', 'جلسات انستقرام النشطة', true),
    SocialSession(PlatformType.tiktok, 'تيك توك', 'TikTok', 'TT', 'https://www.tiktok.com/setting/security', 'إدارة الأجهزة المتصلة', true),
    SocialSession(PlatformType.whatsapp, 'واتساب', 'WhatsApp', 'WA', 'https://web.whatsapp.com/ - افتح الإعدادات > الأجهزة المرتبطة', 'من يقرأ واتسابك على الكمبيوتر', false),
    SocialSession(PlatformType.youtube, 'يوتيوب', 'YouTube', 'YT', 'https://myaccount.google.com/device-activity - نفس جوجل', 'جلسات يوتيوب مرتبطة بجوجل', true),
    SocialSession(PlatformType.twitter, 'إكس / تويتر', 'X/Twitter', 'X', 'https://twitter.com/settings/sessions', 'الأجهزة المسجلة', true),
    SocialSession(PlatformType.telegram, 'تيليجرام', 'Telegram', 'TG', 'افتح تيليجرام > الإعدادات > الأجهزة', 'جلسات تيليجرام النشطة', false),
    SocialSession(PlatformType.snapchat, 'سناب شات', 'Snapchat', 'SC', 'https://accounts.snapchat.com/accounts/sessions', 'من دخل سنابك', true),
  ];

  Future<void> open() async {
    if (checkUrl.startsWith('http')) {
      final uri = Uri.parse(checkUrl);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class SessionAlert {
  final PlatformType platform;
  final String titleAr;
  final DateTime detectedAt;
  final String location;
  final String device;
  final String severity; // critical, high

  SessionAlert(this.platform, this.titleAr, this.detectedAt, this.location, this.device, this.severity);
}

class SessionMonitorService {
  // In real implementation, this would:
  // - Read AccountManager accounts (GET_ACCOUNTS) - allowed
  // - Monitor notifications for "new login" (without reading content, only package)
  // - Guide user to check sessions manually via deep links (privacy-preserving)
  // - We cannot directly access Google/Facebook sessions without OAuth, so we provide guided checks

  static List<SessionAlert> mockAlerts() {
    return [
      SessionAlert(PlatformType.google, 'دخول جديد من روسيا', DateTime.now().subtract(const Duration(hours: 2)), 'موسكو، روسيا - IP 185.220.x.x', 'Windows - Chrome', 'critical'),
      SessionAlert(PlatformType.facebook, 'جلسة نشطة من تركيا', DateTime.now().subtract(const Duration(days: 1)), 'اسطنبول، تركيا', 'iPhone', 'high'),
    ];
  }

  static Future<List<SocialSession>> getSessionsToCheck() async {
    return SocialSession.all;
  }
}
