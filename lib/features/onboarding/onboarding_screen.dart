import 'package:flutter/material.dart';
import '../../core/design/tokens.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int index = 0;
  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SafiColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => index = i),
                children: [
                  _page(
                    icon: Icons.visibility_outlined,
                    title: 'هل يراك أحد؟',
                    subtitle: 'افحص هاتفك في 60 ثانية واعرف من يراقبه',
                    badge: 'ترحيب',
                  ),
                  _page(
                    icon: Icons.shield_outlined,
                    title: 'حدودنا واضحة',
                    subtitle: '',
                    custom: Column(
                      children: [
                        _limit(Icons.message_outlined, 'لا رسائل'),
                        _limit(Icons.key_outlined, 'لا كلمات مرور'),
                        _limit(Icons.videocam_off_outlined, 'لا كاميرا/ميكروفون'),
                        _limit(Icons.location_off_outlined, 'لا موقع'),
                      ],
                    ),
                    badge: 'الخصوصية',
                  ),
                  _page(
                    icon: Icons.notifications_active_outlined,
                    title: 'إذن واحد فقط',
                    subtitle: 'نحتاج إشعارات لتنبيهك عند ظهور تهديد جديد. لا نقرأ محتوى الإشعارات.',
                    badge: 'الأذونات',
                    action: Row(
                      children: [
                        Expanded(child: OutlinedButton(onPressed: () => Navigator.pushReplacementNamed(context, '/home'), child: const Text('لاحقاً'))),
                        const SizedBox(width: 12),
                        Expanded(child: ElevatedButton(onPressed: () => Navigator.pushReplacementNamed(context, '/home'), child: const Text('السماح'))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) => Container(
                      width: i == index ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: i == index ? SafiColors.primary : SafiColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )),
                  ),
                  const SizedBox(height: 20),
                  if (index < 2)
                    ElevatedButton(
                      onPressed: () {
                        _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                      },
                      child: const Text('التالي'),
                    ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => Navigator.pushNamed(context, '/privacy'),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, size: 14, color: SafiColors.textMuted),
                        SizedBox(width: 6),
                        Text('سياسة الخصوصية - ماذا لا نجمع', style: TextStyle(fontSize: 12, color: SafiColors.textMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _page({required IconData icon, required String title, required String subtitle, String badge = '', Widget? custom, Widget? action}) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: SafiColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: SafiColors.border)),
            child: Text(badge, style: const TextStyle(fontSize: 12, color: SafiColors.primary)),
          ),
          const SizedBox(height: 30),
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(color: SafiColors.surface, borderRadius: BorderRadius.circular(24)),
            child: Icon(icon, size: 44, color: SafiColors.primary),
          ),
          const SizedBox(height: 24),
          Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: SafiColors.textPrimary, fontFamily: 'Cairo')),
          const SizedBox(height: 12),
          if (subtitle.isNotEmpty) Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, color: SafiColors.textSecondary, height: 1.6)),
          if (custom != null) ...[const SizedBox(height: 20), custom],
          if (action != null) ...[const SizedBox(height: 30), action],
        ],
      ),
    );
  }

  Widget _limit(IconData icon, String text) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: SafiColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: SafiColors.border)),
      child: Row(
        children: [
          Icon(icon, size: 20, color: SafiColors.primary),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(color: SafiColors.textPrimary)),
          const Spacer(),
          const Icon(Icons.check_circle, size: 18, color: SafiColors.primary),
        ],
      ),
    );
  }
}
