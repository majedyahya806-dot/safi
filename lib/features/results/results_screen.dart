import 'package:flutter/material.dart';
import '../../core/design/tokens.dart';
import '../../core/security/rules.dart';
import '../../core/security/scoring.dart';
import '../../app.dart';
import '../../services/native_channel.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  String filter = 'all';
  String search = '';
  final _channel = NativeChannel();

  @override
  Widget build(BuildContext context) {
    final findings = AppState.lastFindings.where((f) {
      if (filter != 'all' && f.severity.name != filter) return false;
      if (search.isNotEmpty && !f.appName.toLowerCase().contains(search.toLowerCase()) && !f.ruleId.toLowerCase().contains(search.toLowerCase())) return false;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: SafiColors.background,
      appBar: AppBar(title: Text('النتائج - ${AppState.lastFindings.length} تهديد'), actions: [IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {})]),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search, size: 20), hintText: 'بحث عن تطبيق أو خطر...', isDense: true, border: OutlineInputBorder()), onChanged: (v) => setState(() => search = v)),
                const SizedBox(height: 12),
                SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
                  _filterChip('الكل', 'all'),
                  _filterChip('حرج', 'critical'),
                  _filterChip('مرتفع', 'high'),
                  _filterChip('متوسط', 'medium'),
                ])),
              ],
            ),
          ),
          Expanded(
            child: findings.isEmpty
                ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.verified_user_outlined, size: 64, color: SafiColors.primary), const SizedBox(height: 12), Text(AppState.lastFindings.isEmpty ? 'لا شيء مفتوح الآن' : 'لا نتائج بهذا المرشح', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)), Text('آخر فحص ${AppState.lastScanTime != null ? '${AppState.lastScanTime!.day}/${AppState.lastScanTime!.month}' : ''}', style: const TextStyle(color: SafiColors.textMuted))]))
                : ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: findings.length, itemBuilder: (context, i) {
                    final f = findings[i];
                    final rule = SafiRules.byId(f.ruleId);
                    final color = f.severity == Severity.critical ? SafiColors.critical : f.severity == Severity.high ? SafiColors.high : f.severity == Severity.medium ? SafiColors.medium : SafiColors.unknown;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(color: SafiColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withOpacity(0.25))),
                      child: ListTile(
                        leading: Container(width: 4, height: 50, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
                        title: Text(rule?.titleAr ?? f.ruleId, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('${f.appName} • ${f.packageName}', style: const TextStyle(fontSize: 11, color: SafiColors.textMuted)),
                          const SizedBox(height: 4),
                          Text(rule?.whyAr ?? '', style: const TextStyle(fontSize: 12, color: SafiColors.textSecondary)),
                        ]),
                        trailing: PopupMenuButton(itemBuilder: (_) => [const PopupMenuItem(value: 'fix', child: Text('إصلاح')), const PopupMenuItem(value: 'ignore', child: Text('تجاهل'))], onSelected: (v) {
                          if (v == 'fix') _fix(f);
                          if (v == 'ignore') _ignore(f);
                        }),
                        onTap: () => _showDetails(f),
                      ),
                    );
                  }),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final selected = filter == value;
    return Padding(padding: const EdgeInsets.only(left: 8), child: ChoiceChip(label: Text(label, style: TextStyle(fontSize: 12, color: selected ? Colors.black : SafiColors.textSecondary)), selected: selected, selectedColor: SafiColors.primary, backgroundColor: SafiColors.surface, onSelected: (_) => setState(() => filter = value)));
  }

  void _fix(Finding f) async {
    final rule = SafiRules.byId(f.ruleId);
    String action = 'accessibility';
    if (f.category == RuleCategory.deviceControl) action = 'device_admin';
    if (f.category == RuleCategory.watcher) action = 'accessibility';
    if (f.category == RuleCategory.network) action = 'ca_certs';
    await _channel.openSystemSettings(action);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(rule?.fixAr ?? 'افتح الإعدادات')));
  }

  void _ignore(Finding f) {
    setState(() {
      AppState.lastFindings = AppState.lastFindings.map((e) => e.id == f.id ? Finding(id: e.id, ruleId: e.ruleId, packageName: e.packageName, appName: e.appName, version: e.version, installedAt: e.installedAt, severity: e.severity, category: e.category, status: FindingStatus.acknowledged, evidence: e.evidence) : e).toList();
    });
  }

  void _showDetails(Finding f) {
    final rule = SafiRules.byId(f.ruleId);
    showModalBottomSheet(context: context, backgroundColor: SafiColors.surface, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (_) => Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: f.severity == Severity.critical ? SafiColors.critical : SafiColors.high, shape: BoxShape.circle)), const SizedBox(width: 8), Text(rule?.titleAr ?? f.ruleId, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16))]),
      const SizedBox(height: 12),
      const Text('ماذا وجدنا', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: SafiColors.primary)),
      Text(rule?.whyAr ?? '', style: const TextStyle(fontSize: 13, height: 1.6)),
      const SizedBox(height: 12),
      const Text('لماذا هذا خطر', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: SafiColors.critical)),
      Text('${rule?.whyAr ?? ''} - ${f.evidence}', style: const TextStyle(fontSize: 13, height: 1.6)),
      const SizedBox(height: 12),
      Text('الحزمة: ${f.packageName}\nالإصدار: ${f.version}\nالتثبيت: ${f.installedAt.day}/${f.installedAt.month}/${f.installedAt.year}', style: const TextStyle(fontSize: 11, color: SafiColors.textMuted)),
      const SizedBox(height: 16),
      Row(children: [Expanded(child: OutlinedButton(onPressed: () { Navigator.pop(context); _ignore(f); }, child: const Text('تجاهل'))), const SizedBox(width: 12), Expanded(child: ElevatedButton(onPressed: () { Navigator.pop(context); _fix(f); }, child: const Text('فتح الإعدادات')))]),
      const SizedBox(height: 8),
      OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 44)), child: const Text('نسخ تقرير')),
    ])));
  }
}
