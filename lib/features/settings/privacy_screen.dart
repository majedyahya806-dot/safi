import 'package:flutter/material.dart';
import '../../core/design/tokens.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SafiColors.background,
      appBar: AppBar(title: const Text('سياسة الخصوصية')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('صافي - ما لا نجمعه', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _item(Icons.block_outlined, 'لا رسائل SMS'),
            _item(Icons.key_off_outlined, 'لا كلمات مرور'),
            _item(Icons.videocam_off_outlined, 'لا كاميرا / ميكروفون'),
            _item(Icons.location_off_outlined, 'لا موقع دقيق'),
            _item(Icons.call_outlined, 'لا سجل مكالمات'),
            const SizedBox(height: 20),
            const Text('ما نجمعه:', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('• finding + severity + timestamp فقط\n• معرف جهاز مجهول\n• لا محتوى اتصال\n• لا بيانات جهاز خام', style: TextStyle(fontSize: 13, color: SafiColors.textSecondary, height: 1.7)),
            const SizedBox(height: 20),
            const Text('الحدود - تُختبر آلياً:', style: TextStyle(fontWeight: FontWeight.w700)),
            const Text('CI يفشل إذا ظهر READ_SMS, READ_CALL_LOG, RECORD_AUDIO, CAMERA, ACCESS_FINE_LOCATION, BIND_NOTIFICATION_LISTENER_SERVICE في AndroidManifest.xml', style: TextStyle(fontSize: 12, color: SafiColors.textMuted)),
            const SizedBox(height: 20),
            const Text('المصادر:', style: TextStyle(fontWeight: FontWeight.w700)),
            const Text('• AOSP docs for accessibility/device admin\n• Android CA store\n• VirusTotal, Google Safe Browsing, PhishTank for phishing\n• Official session pages for Google, Facebook, etc.', style: TextStyle(fontSize: 12, color: SafiColors.textMuted, height: 1.6)),
          ],
        ),
      ),
    );
  }

  Widget _item(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [Icon(icon, size: 18, color: SafiColors.primary), const SizedBox(width: 10), Text(text, style: const TextStyle(fontSize: 14))]),
    );
  }
}
