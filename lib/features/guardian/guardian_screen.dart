import 'package:flutter/material.dart';
import '../../core/design/tokens.dart';
import '../../core/guardian/guardian_service.dart';

class GuardianScreen extends StatefulWidget {
  const GuardianScreen({super.key});

  @override
  State<GuardianScreen> createState() => _GuardianScreenState();
}

class _GuardianScreenState extends State<GuardianScreen> {
  bool enabled = false;
  int interval = 24;
  final service = GuardianService();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final e = await service.isEnabled();
    final i = await service.getInterval();
    setState(() {
      enabled = e;
      interval = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SafiColors.background,
      appBar: AppBar(title: const Text('الحارس')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: SafiColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: SafiColors.border)),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('تفعيل الحارس', style: TextStyle(fontWeight: FontWeight.w700)), Switch(value: enabled, onChanged: (v) async {
                    setState(() => enabled = v);
                    if (v) {
                      await service.enable(intervalHours: interval);
                    } else {
                      await service.disable();
                    }
                  })]),
                  const SizedBox(height: 8),
                  const Text('لا يعمل كخدمة تنصّت - يفحص فقط الأذونات الجديدة', style: TextStyle(fontSize: 12, color: SafiColors.textMuted)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: SafiColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: SafiColors.border)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('فترة الفحص', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 12),
                  Row(children: [
                    _intervalChip(12),
                    const SizedBox(width: 8),
                    _intervalChip(24),
                    const SizedBox(width: 8),
                    _intervalChip(72),
                  ]),
                  const SizedBox(height: 12),
                  Text('آخر دورة: ${enabled ? 'قبل ساعتين' : 'متوقف'}', style: const TextStyle(fontSize: 12, color: SafiColors.textMuted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _intervalChip(int hours) {
    final selected = interval == hours;
    return ChoiceChip(label: Text('$hours ساعة', style: TextStyle(fontSize: 12, color: selected ? Colors.black : SafiColors.textSecondary)), selected: selected, selectedColor: SafiColors.primary, onSelected: (v) async {
      if (v) {
        setState(() => interval = hours);
        if (enabled) await service.enable(intervalHours: hours);
      }
    });
  }
}
