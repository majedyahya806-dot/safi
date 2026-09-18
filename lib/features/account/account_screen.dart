import 'package:flutter/material.dart';
import '../../core/design/tokens.dart';
import '../../app.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SafiColors.background,
      appBar: AppBar(title: const Text('حسابي')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: SafiColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: SafiColors.border)),
            child: Row(
              children: [
                const CircleAvatar(radius: 28, backgroundColor: SafiColors.primary, child: Icon(Icons.person, color: Colors.black)),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${AppState.firstName} ${AppState.lastName}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const Text('حساب نشط • 1/5 أجهزة', style: TextStyle(fontSize: 12, color: SafiColors.textMuted)),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _tile(Icons.devices_outlined, 'الأجهزة (1/5)', 'إبطال جهاز'),
          _tile(Icons.lock_outline, 'تغيير كلمة المرور', ''),
          _tile(Icons.sync_outlined, 'المزامنة السحابية', 'مفعّلة'),
          _tile(Icons.picture_as_pdf_outlined, 'تصدير تقرير PDF رسمي', 'باسمك'),
          _tile(Icons.logout_outlined, 'تسجيل خروج', ''),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: SafiColors.critical.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: SafiColors.critical.withOpacity(0.3))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('حذف الحساب', style: TextStyle(color: SafiColors.critical, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                const Text('حذف سحابي بعد تراجع 7 أيام', style: TextStyle(fontSize: 12, color: SafiColors.textMuted)),
                const SizedBox(height: 8),
                OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(foregroundColor: SafiColors.critical), child: const Text('حذف الحساب')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: SafiColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: SafiColors.border)),
      child: ListTile(leading: Icon(icon, color: SafiColors.textSecondary), title: Text(title, style: const TextStyle(fontSize: 14)), subtitle: subtitle.isNotEmpty ? Text(subtitle, style: const TextStyle(fontSize: 11, color: SafiColors.textMuted)) : null, trailing: const Icon(Icons.chevron_left, size: 18)),
    );
  }
}
