import 'package:flutter/material.dart';
import '../../core/design/tokens.dart';
import '../../core/security/scoring.dart';
import '../../app.dart';
import '../../core/sessions/session_monitor.dart';
import '../../core/phishing/phishing_detector.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final findings = AppState.lastFindings;
    final score = AppState.lastScore;
    final counts = TrustScoreCalculator.counts(findings);
    final lastScan = AppState.lastScanTime;

    return Scaffold(
      backgroundColor: SafiColors.background,
      appBar: AppBar(
        title: const Text('صافي'),
        actions: [
          IconButton(icon: const Icon(Icons.history), onPressed: () => Navigator.pushNamed(context, '/history')),
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () => Navigator.pushNamed(context, '/settings')),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Trust Score Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: SafiColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: SafiColors.border)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('درجة الثقة', style: TextStyle(color: SafiColors.textSecondary, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text('$score', style: TextStyle(fontSize: 44, fontWeight: FontWeight.w700, color: score > 70 ? SafiColors.primary : score > 40 ? SafiColors.high : SafiColors.critical, fontFamily: 'Inter')),
                          Text(TrustScoreCalculator.level(score), style: TextStyle(color: score > 70 ? SafiColors.primary : score > 40 ? SafiColors.high : SafiColors.critical, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      SizedBox(
                        width: 90,
                        height: 90,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(value: score / 100, strokeWidth: 8, backgroundColor: SafiColors.surfaceElevated, color: score > 70 ? SafiColors.primary : score > 40 ? SafiColors.high : SafiColors.critical),
                            Text('$score%', style: const TextStyle(fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _countChip('حرج ${counts['critical']}', SafiColors.critical),
                      const SizedBox(width: 8),
                      _countChip('مرتفع ${counts['high']}', SafiColors.high),
                      const SizedBox(width: 8),
                      _countChip('متوسط ${counts['medium']}', SafiColors.medium),
                      const SizedBox(width: 8),
                      _countChip('غير محسوم ${counts['unknown']}', SafiColors.unknown),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (lastScan != null)
                    Text('آخر فحص: ${_formatTime(lastScan)} • ما تغيّر: ${findings.length > 0 ? '+${findings.length}' : '0'}', style: const TextStyle(fontSize: 12, color: SafiColors.textMuted)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Primary Action
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/scan'),
              icon: const Icon(Icons.shield_moon_outlined),
              label: const Text('افحص هاتفك الآن - 60 ثانية'),
            ),
            const SizedBox(height: 16),

            // Most critical threat
            if (findings.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: SafiColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: SafiColors.critical.withOpacity(0.3))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [Icon(Icons.warning_amber_rounded, color: SafiColors.critical, size: 18), SizedBox(width: 6), Text('أهم تهديد', style: TextStyle(color: SafiColors.critical, fontWeight: FontWeight.w700, fontSize: 13))]),
                    const SizedBox(height: 8),
                    Text(findings.first.appName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    Text(findings.first.ruleId, style: const TextStyle(color: SafiColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/results'),
                      style: ElevatedButton.styleFrom(backgroundColor: SafiColors.critical, minimumSize: const Size(double.infinity, 44)),
                      child: const Text('إصلاح الآن'),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),
            _sectionTitle('فحص سريع للروابط المشبوهة'),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: SafiColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: SafiColors.border)),
              child: Row(
                children: [
                  Expanded(child: TextField(controller: _urlController, decoration: const InputDecoration(hintText: 'الصق رابط مشبوه هنا...', border: InputBorder.none, isDense: true), style: const TextStyle(fontSize: 14))),
                  ElevatedButton(onPressed: _checkPhishing, style: ElevatedButton.styleFrom(minimumSize: const Size(80, 40)), child: const Text('افحص')),
                ],
              ),
            ),

            const SizedBox(height: 20),
            _sectionTitle('فحص جلسات حساباتك'),
            Container(
              decoration: BoxDecoration(color: SafiColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: SafiColors.border)),
              child: Column(
                children: SessionMonitorService.mockAlerts().map((alert) => ListTile(
                  leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: SafiColors.critical.withOpacity(0.15), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.person_pin_circle_outlined, color: SafiColors.critical)),
                  title: Text(alert.titleAr, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: Text('${alert.location} • ${alert.device}', style: const TextStyle(fontSize: 11, color: SafiColors.textMuted)),
                  trailing: const Icon(Icons.chevron_left, size: 18),
                  onTap: () => _showSessionSheet(),
                )).toList(),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(onPressed: _showSessionSheet, icon: const Icon(Icons.manage_accounts_outlined, size: 18), label: const Text('افحص كل حساباتك')),

            const SizedBox(height: 20),
            _sectionTitle('الحارس'),
            ListTile(
              tileColor: SafiColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: SafiColors.border)),
              leading: const Icon(Icons.shield_outlined, color: SafiColors.primary),
              title: const Text('الحارس غير مفعّل', style: TextStyle(fontSize: 14)),
              subtitle: const Text('نبهني عند ظهور تهديد جديد', style: TextStyle(fontSize: 12, color: SafiColors.textMuted)),
              trailing: Switch(value: false, onChanged: (v) => Navigator.pushNamed(context, '/guardian')),
              onTap: () => Navigator.pushNamed(context, '/guardian'),
            ),

            const SizedBox(height: 12),
            ListTile(
              tileColor: SafiColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: SafiColors.border)),
              leading: const Icon(Icons.account_circle_outlined, color: SafiColors.secondary),
              title: Text(AppState.isLoggedIn ? '${AppState.firstName} ${AppState.lastName}' : 'سجّل دخولك', style: const TextStyle(fontSize: 14)),
              subtitle: Text(AppState.isLoggedIn ? 'الحساب مفعّل' : 'للمزامنة والتقارير', style: const TextStyle(fontSize: 12, color: SafiColors.textMuted)),
              trailing: const Icon(Icons.chevron_left),
              onTap: () => Navigator.pushNamed(context, AppState.isLoggedIn ? '/account' : '/auth'),
            ),

            const SizedBox(height: 20),
            _sectionTitle('مساعد صافي الذكي'),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: SafiColors.surfaceElevated, borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  const CircleAvatar(backgroundColor: SafiColors.primary, radius: 20, child: Text('؟', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700))),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('اسألني عن أي تنبيه، إذن، أو خطر - أشرح لك ببساطة', style: TextStyle(fontSize: 13, color: SafiColors.textSecondary))),
                  IconButton(icon: const Icon(Icons.chat_bubble_outline, color: SafiColors.primary), onPressed: () => _showBot()),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: SafiColors.surface,
        selectedItemColor: SafiColors.primary,
        unselectedItemColor: SafiColors.textMuted,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined), label: 'النتائج'),
          BottomNavigationBarItem(icon: Icon(Icons.history_outlined), label: 'السجل'),
          BottomNavigationBarItem(icon: Icon(Icons.shield_outlined), label: 'الحارس'),
        ],
        onTap: (i) {
          if (i == 1) Navigator.pushNamed(context, '/results');
          if (i == 2) Navigator.pushNamed(context, '/history');
          if (i == 3) Navigator.pushNamed(context, '/guardian');
        },
      ),
    );
  }

  Widget _countChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w700)),
    );
  }

  Widget _sectionTitle(String t) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(t, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)));

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'قبل ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'قبل ${diff.inHours} ساعة';
    return '${dt.day}/${dt.month}';
  }

  void _checkPhishing() {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;
    final result = PhishingDetector.check(url);
    showModalBottomSheet(context: context, backgroundColor: SafiColors.surface, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (_) => _phishingSheet(result));
  }

  Widget _phishingSheet(result) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(result.isPhishing ? Icons.dangerous_outlined : Icons.verified_user_outlined, color: result.isPhishing ? SafiColors.critical : SafiColors.primary), const SizedBox(width: 8), Text(result.isPhishing ? 'موقع احتيالي محتمل!' : 'يبدو سليماً مبدئياً', style: TextStyle(fontWeight: FontWeight.w700, color: result.isPhishing ? SafiColors.critical : SafiColors.primary))]),
          const SizedBox(height: 12),
          Text('درجة الخطر: ${result.riskScore.toInt()}%', style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 8),
          ...result.evidence.map((e) => Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Row(children: [const Text('• ', style: TextStyle(color: SafiColors.textMuted)), Expanded(child: Text(e, style: const TextStyle(fontSize: 12, color: SafiColors.textSecondary)))]))),
          const SizedBox(height: 16),
          const Text('تحقق عبر أفضل المواقع العالمية:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ...PhishingDetector.globalVerifiers.map((v) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(v.name, style: const TextStyle(fontSize: 13)),
                subtitle: Text(v.descriptionAr, style: const TextStyle(fontSize: 11, color: SafiColors.textMuted)),
                trailing: const Icon(Icons.open_in_new, size: 16),
                onTap: () {
                  // open verifier
                },
              )),
          const SizedBox(height: 10),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('فهمت')),
        ],
      ),
    );
  }

  void _showSessionSheet() {
    showModalBottomSheet(context: context, backgroundColor: SafiColors.surface, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (_) => DraggableScrollableSheet(initialChildSize: 0.7, maxChildSize: 0.9, expand: false, builder: (context, scroll) => Padding(padding: const EdgeInsets.all(16), child: ListView(controller: scroll, children: [
      const Text('افحص جلساتك - من دخل حساباتك؟', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
      const SizedBox(height: 8),
      const Text('نحن لا نقرأ كلمات مرورك. نرشدك لصفحة الأجهزة الرسمية لكل منصة لتتأكد بنفسك.', style: TextStyle(fontSize: 12, color: SafiColors.textMuted)),
      const SizedBox(height: 16),
      ...SessionMonitorService.mockAlerts().map((a) => Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: SafiColors.background, borderRadius: BorderRadius.circular(12), border: Border.all(color: SafiColors.critical.withOpacity(0.3))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(a.titleAr, style: const TextStyle(color: SafiColors.critical, fontWeight: FontWeight.w700, fontSize: 13)), Text('${a.location} - ${a.device}', style: const TextStyle(fontSize: 12, color: SafiColors.textSecondary)), Text('قبل ${DateTime.now().difference(a.detectedAt).inHours} ساعة', style: const TextStyle(fontSize: 11, color: SafiColors.textMuted))]))),
      const SizedBox(height: 16),
      const Text('افحص كل منصاتك:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
      const SizedBox(height: 8),
      ...SocialSession.all.map((s) => ListTile(leading: CircleAvatar(backgroundColor: SafiColors.surfaceElevated, child: Text(s.icon, style: const TextStyle(fontSize: 12))), title: Text(s.nameAr, style: const TextStyle(fontSize: 14)), subtitle: Text(s.descriptionAr, style: const TextStyle(fontSize: 11, color: SafiColors.textMuted)), trailing: const Icon(Icons.open_in_new, size: 16), onTap: () => s.open())),
    ]))));
  }

  void _showBot() {
    showModalBottomSheet(context: context, backgroundColor: SafiColors.surface, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (_) => const BotSheet());
  }
}

class BotSheet extends StatefulWidget {
  const BotSheet({super.key});
  @override
  State<BotSheet> createState() => _BotSheetState();
}

class _BotSheetState extends State<BotSheet> {
  final _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {'isUser': false, 'text': 'مرحبا! أنا مساعد صافي الذكي. اسألني عن أي تنبيه أو إذن أو خطر ظهر لك.'}
  ];
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: 500,
        child: Column(
          children: [
            const Padding(padding: EdgeInsets.all(16), child: Text('مساعد صافي - اسأل عن أي شيء', style: TextStyle(fontWeight: FontWeight.w700))),
            Expanded(child: ListView.builder(padding: const EdgeInsets.all(12), itemCount: _messages.length, itemBuilder: (context, i) {
              final m = _messages[i];
              return Align(alignment: m['isUser'] ? Alignment.centerLeft : Alignment.centerRight, child: Container(margin: const EdgeInsets.symmetric(vertical: 4), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: m['isUser'] ? SafiColors.secondary : SafiColors.surfaceElevated, borderRadius: BorderRadius.circular(14)), child: Text(m['text'], style: const TextStyle(fontSize: 13))));
            })),
            Padding(padding: const EdgeInsets.all(12), child: Row(children: [
              Expanded(child: TextField(controller: _controller, decoration: const InputDecoration(hintText: 'مثال: ما معنى تطبيق مخفي؟', border: OutlineInputBorder(), isDense: true))),
              const SizedBox(width: 8),
              IconButton(icon: const Icon(Icons.send, color: SafiColors.primary), onPressed: _send),
            ])),
          ],
        ),
      ),
    );
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({'isUser': true, 'text': text});
      _messages.add({'isUser': false, 'text': _answer(text)});
    });
    _controller.clear();
  }

  String _answer(String q) {
    // simple knowledge base
    if (q.contains('روت')) return 'الروت يعني جهازك مفتوح لأي تطبيق. إذا ظهر لك تنبيه روت، فجهازك قابل للاختراق بسهولة. ألغِ الروت من Magisk أو استخدم جهاز آخر للبنوك.';
    if (q.contains('مخفي')) return 'التطبيق المخفي بلا أيقونة. افتح الإعدادات > التطبيقات > عرض كل التطبيقات. إذا وجدت تطبيق اسمه System Update أو غريب بلا أيقونة، احذفه.';
    if (q.contains('جلسة') || q.contains('دخول')) return 'للتأكد من جلساتك: اضغط افحص كل حساباتك في الرئيسية. سنفتح لك صفحة جوجل، فيسبوك، انستا الرسمية لترى الأجهزة. إذا رأيت جهاز من روسيا أو تركيا لا تعرفه، سجل خروجه وغير كلمة المرور فوراً.';
    if (q.contains('احتيال') || q.contains('رابط')) return 'الصق الرابط في خانة فحص الروابط المشبوهة في الرئيسية. سنعطيك درجة خطر ونوجهك لـ VirusTotal و Google Safe Browsing للتأكد.';
    return 'صافي يفحص 36 نوع خطر. كل تنبيه له شرح لماذا خطر وكيف تصلحه. اضغط على أي نتيجة في شاشة النتائج وسأشرحها لك بالتفصيل.';
  }
}
