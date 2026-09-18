import 'dart:convert';
import 'package:http/http.dart' as http;

class PhishingCheckResult {
  final String url;
  final bool isPhishing;
  final double riskScore; // 0-100
  final String reasonAr;
  final String reasonEn;
  final List<String> evidence;
  final List<PhishingVerifier> verifiers;

  PhishingCheckResult({
    required this.url,
    required this.isPhishing,
    required this.riskScore,
    required this.reasonAr,
    required this.reasonEn,
    required this.evidence,
    required this.verifiers,
  });
}

class PhishingVerifier {
  final String name;
  final String url;
  final String descriptionAr;
  PhishingVerifier(this.name, this.url, this.descriptionAr);
}

class PhishingDetector {
  static final List<PhishingVerifier> globalVerifiers = [
    PhishingVerifier('VirusTotal', 'https://www.virustotal.com/gui/search/', 'يفحص الرابط بـ 90 محرك'),
    PhishingVerifier('URLScan.io', 'https://urlscan.io/search/#', 'لقطة حية للموقع وتحليل'),
    PhishingVerifier('Google Safe Browsing', 'https://transparencyreport.google.com/safe-browsing/search?url=', 'قاعدة جوجل للمواقع الخطرة'),
    PhishingVerifier('PhishTank', 'https://phishtank.org/phish_search.php?search=', 'مجتمع مكافحة التصيد'),
    PhishingVerifier('CheckPhish', 'https://checkphish.bolster.ai/', 'ذكاء اصطناعي لكشف التصيد'),
  ];

  static PhishingCheckResult check(String inputUrl) {
    String url = inputUrl.trim();
    if (!url.startsWith('http')) url = 'https://$url';
    Uri? uri;
    try {
      uri = Uri.parse(url);
    } catch (_) {
      return PhishingCheckResult(
        url: inputUrl,
        isPhishing: true,
        riskScore: 90,
        reasonAr: 'رابط غير صالح أو مشبوه',
        reasonEn: 'Invalid or suspicious URL',
        evidence: ['تنسيق رابط غير صحيح'],
        verifiers: globalVerifiers,
      );
    }

    double score = 0;
    List<String> evidence = [];

    // Heuristics
    if (uri.host.contains('@') || uri.toString().contains('@')) {
      score += 30;
      evidence.add('يحتوي على @ - خدعة شائعة');
    }
    if (uri.host.split('.').length > 3) {
      score += 15;
      evidence.add('نطاق فرعي طويل جداً');
    }
    if (RegExp(r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}').hasMatch(uri.host)) {
      score += 35;
      evidence.add('يستخدم IP بدل اسم نطاق');
    }
    if (uri.host.length > 40) {
      score += 10;
      evidence.add('اسم نطاق طويل مشبوه');
    }
    const suspiciousKeywords = ['login', 'verify', 'secure', 'account', 'update', 'confirm', 'bank', 'paypal', 'apple', 'google', 'facebook'];
    final lower = uri.toString().toLowerCase();
    for (var kw in suspiciousKeywords) {
      if (lower.contains(kw) && !uri.host.contains(kw)) {
        score += 12;
        evidence.add('يحتوي كلمة "$kw" مع نطاق مختلف');
        break;
      }
    }
    if (uri.scheme == 'http') {
      score += 20;
      evidence.add('بدون HTTPS - غير مشفر');
    }
    // punycode
    if (uri.host.startsWith('xn--')) {
      score += 25;
      evidence.add('يستخدم حروف مشابهة (Punycode)');
    }
    // TLD suspicious
    const riskyTlds = ['.tk', '.ml', '.ga', '.cf', '.gq', '.xyz', '.top', '.click'];
    for (var tld in riskyTlds) {
      if (uri.host.endsWith(tld)) {
        score += 15;
        evidence.add('نطاق مجاني مشبوه $tld');
        break;
      }
    }

    bool isPhish = score >= 40;
    return PhishingCheckResult(
      url: url,
      isPhishing: isPhish,
      riskScore: score.clamp(0, 100),
      reasonAr: isPhish ? 'هذا الرابط يظهر عليه علامات تصيد واحتيال' : 'لم نجد علامات تصيد واضحة لكن افحصه بالأدوات',
      reasonEn: isPhish ? 'Phishing indicators detected' : 'No clear phishing signs but verify',
      evidence: evidence.isEmpty ? ['لا علامات واضحة'] : evidence,
      verifiers: globalVerifiers,
    );
  }

  static String verifierLink(PhishingVerifier v, String url) {
    if (v.name == 'VirusTotal' || v.name == 'Google Safe Browsing' || v.name == 'PhishTank') {
      return '${v.url}${Uri.encodeComponent(url)}';
    }
    if (v.name == 'URLScan.io') {
      return '${v.url}${Uri.encodeComponent(url)}';
    }
    return v.url;
  }
}
