import 'package:flutter/material.dart';
import '../../core/design/tokens.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SafiColors.background,
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('عام'),
          _tile('اللغة', 'عربي / English', Icons.language_outlined, () {}),
          _tile('السمة', 'داكن', Icons.dark_mode_outlined, () {}),
          _tile('حجم الخط', 'متوسط', Icons.text_fields_outlined, () {}),
          const SizedBox(height: 16),
          _section('الأذونات'),
          _tile('إدارة الأذونات', 'تفتح النظام', Icons.security_outlined, () {}),
          _tile('التخزين', '24 MB', Icons.storage_outlined, () {}),
          const SizedBox(height: 16),
          _section('حول'),
          _tile('حول صافي', 'الإصدار v2.0 - القواعد v1.3', Icons.info_outline, () => Navigator.pushNamed(context, '/privacy')),
          _tile('سياسة الخصوصية', 'صفحة واحدة', Icons.privacy_tip_outlined, () => Navigator.pushNamed(context, '/privacy')),
          _tile('المصادر', 'مفتوحة', Icons.source_outlined, () {}),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: SafiColors.critical.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('حذف كل البيانات', style: TextStyle(color: SafiColors.critical, fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 8),
                const Text('اكتب احذف للتأكيد', style: TextStyle(fontSize: 12, color: SafiColors.textMuted)),
                const SizedBox(height: 8),
                TextField(decoration: const InputDecoration(hintText: 'احذف', border: OutlineInputBorder(), isDense: true)),
                const SizedBox(height: 8),
                OutlinedButton(onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                }, style: OutlinedButton.styleFrom(foregroundColor: SafiColors.critical), child: const Text('تأكيد الحذف')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title) => Padding(padding: const EdgeInsets.only(bottom: 8, top: 8), child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: SafiColors.textSecondary)));
  Widget _tile(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: SafiColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: SafiColors.border)),
      child: ListTile(leading: Icon(icon, size: 20, color: SafiColors.textSecondary), title: Text(title, style: const TextStyle(fontSize: 14)), subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: SafiColors.textMuted)), trailing: const Icon(Icons.chevron_left, size: 18), onTap: onTap),
    );
  }
}
