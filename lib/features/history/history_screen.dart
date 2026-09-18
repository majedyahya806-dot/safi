import 'package:flutter/material.dart';
import '../../core/design/tokens.dart';
import '../../app.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = [
      {'date': 'اليوم', 'score': AppState.lastScore, 'findings': AppState.lastFindings.length},
      {'date': 'أمس', 'score': 78, 'findings': 2},
      {'date': 'قبل 3 أيام', 'score': 65, 'findings': 5},
    ];
    return Scaffold(
      backgroundColor: SafiColors.background,
      appBar: AppBar(title: const Text('السجل')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 120,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: SafiColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: SafiColors.border)),
            child: const Center(child: Text('مخطط Trust Score 30 يوم - SVG محلي', style: TextStyle(color: SafiColors.textMuted))),
          ),
          const SizedBox(height: 16),
          ...history.map((h) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: SafiColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: SafiColors.border)),
                child: Row(
                  children: [
                    CircleAvatar(backgroundColor: SafiColors.surfaceElevated, child: Text('${h['score']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                    const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(h['date'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)), Text('${h['findings']} تهديد', style: const TextStyle(fontSize: 12, color: SafiColors.textMuted))]),
                    const Spacer(),
                    const Icon(Icons.chevron_left, size: 18, color: SafiColors.textMuted),
                  ],
                ),
              )),
          const SizedBox(height: 20),
          ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.download_outlined), label: const Text('تصدير JSON')),
        ],
      ),
    );
  }
}
