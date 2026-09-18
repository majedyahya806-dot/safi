import 'package:flutter/material.dart';
import '../../core/design/tokens.dart';
import '../../core/security/audit_engine.dart';
import '../../core/security/scoring.dart';
import '../../app.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final _engine = AuditEngine();
  AuditStage? currentStage;
  int checked = 0;
  int total = 100;
  double progress = 0;
  bool running = true;
  List<String> logs = [];

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final result = await _engine.runFullAudit(onProgress: (p) {
      if (!mounted) return;
      setState(() {
        currentStage = p.stage;
        checked = p.checked;
        total = p.total;
        progress = p.percent;
        logs.add('${p.stage.nameAr}: ${p.checked}/${p.total}');
        if (logs.length > 6) logs.removeAt(0);
      });
    });

    if (!mounted) return;
    AppState.lastFindings = result.findings;
    AppState.lastScore = result.trustScore;
    AppState.lastScanTime = result.timestamp;

    // If not logged in and first scan, go to auth
    if (!AppState.isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/auth');
    } else {
      Navigator.pushReplacementNamed(context, '/results');
    }
  }

  @override
  void dispose() {
    _engine.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SafiColors.background,
      appBar: AppBar(title: const Text('جاري الفحص - 60 ثانية'), leading: IconButton(icon: const Icon(Icons.close), onPressed: () {
        _engine.cancel();
        Navigator.pop(context);
      })),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(width: 160, height: 160, child: CircularProgressIndicator(value: progress, strokeWidth: 8, backgroundColor: SafiColors.surfaceElevated, color: SafiColors.primary)),
                Column(
                  children: [
                    Text('${(progress * 100).toInt()}%', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, fontFamily: 'Inter')),
                    Text(currentStage?.nameAr ?? 'يبدأ...', style: const TextStyle(fontSize: 13, color: SafiColors.textSecondary)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: SafiColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: SafiColors.border)),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(currentStage?.nameAr ?? 'الحزم', style: const TextStyle(fontWeight: FontWeight.w700)), Text('$checked / $total عنصر', style: const TextStyle(fontSize: 12, color: SafiColors.textMuted))]),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(value: total == 0 ? 0 : checked / total, color: SafiColors.primary, backgroundColor: SafiColors.surfaceElevated),
                  const SizedBox(height: 12),
                  ...logs.reversed.map((l) => Align(alignment: Alignment.centerRight, child: Text(l, style: const TextStyle(fontSize: 11, color: SafiColors.textMuted)))),
                ],
              ),
            ),
            const Spacer(),
            const Text('نفحص 8 مراحل حقيقية - ليس رقم وهمي', style: TextStyle(fontSize: 12, color: SafiColors.textMuted)),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: () { _engine.cancel(); Navigator.pop(context); }, child: const Text('إلغاء')),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
