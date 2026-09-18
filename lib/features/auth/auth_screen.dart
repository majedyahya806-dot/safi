import 'package:flutter/material.dart';
import '../../core/design/tokens.dart';
import '../../app.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isEmail = true;
  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final contactCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SafiColors.background,
      appBar: AppBar(title: const Text('إنشاء حساب - إجباري للمزامنة')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('الحساب مطلوب بعد أول فحص لحفظ السجل والتنبيهات والتقارير PDF', style: TextStyle(fontSize: 13, color: SafiColors.textSecondary)),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: TextField(controller: firstNameCtrl, decoration: const InputDecoration(labelText: 'الاسم الأول *', border: OutlineInputBorder()))),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: lastNameCtrl, decoration: const InputDecoration(labelText: 'اسم العائلة *', border: OutlineInputBorder()))),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              ChoiceChip(label: const Text('بريد'), selected: isEmail, onSelected: (v) => setState(() => isEmail = true)),
              const SizedBox(width: 8),
              ChoiceChip(label: const Text('هاتف OTP'), selected: !isEmail, onSelected: (v) => setState(() => isEmail = false)),
            ]),
            const SizedBox(height: 12),
            TextField(controller: contactCtrl, decoration: InputDecoration(labelText: isEmail ? 'البريد الإلكتروني' : 'رقم الهاتف', border: const OutlineInputBorder(), prefixIcon: Icon(isEmail ? Icons.email_outlined : Icons.phone_outlined))),
            const SizedBox(height: 16),
            TextField(controller: passCtrl, obscureText: obscure, decoration: InputDecoration(labelText: 'كلمة المرور (10+ أحرف)', border: const OutlineInputBorder(), suffixIcon: IconButton(icon: Icon(obscure ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => obscure = !obscure)))),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: (passCtrl.text.length / 12).clamp(0, 1).toDouble(), color: passCtrl.text.length >= 10 ? SafiColors.primary : SafiColors.high, backgroundColor: SafiColors.surfaceElevated),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _signup, child: const Text('إنشاء حساب وتسجيل دخول')),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: () => Navigator.pushReplacementNamed(context, '/home'), child: const Text('تخطي مؤقتاً - سأكمل لاحقاً')),
            const SizedBox(height: 20),
            const Text('أمان الحساب: قفل 5 محاولات / 15 دقيقة • Access 15m + Refresh 30d • بصمة بعد أول دخول • 5 أجهزة كحد أقصى', style: TextStyle(fontSize: 11, color: SafiColors.textMuted)),
          ],
        ),
      ),
    );
  }

  void _signup() {
    if (firstNameCtrl.text.length < 1 || lastNameCtrl.text.length < 1) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الاسم الأول والعائلة إلزامي')));
      return;
    }
    if (contactCtrl.text.isEmpty || passCtrl.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أكمل البيانات - كلمة المرور 10+')));
      return;
    }
    AppState.isLoggedIn = true;
    AppState.firstName = firstNameCtrl.text;
    AppState.lastName = lastNameCtrl.text;
    Navigator.pushReplacementNamed(context, '/home');
  }
}
