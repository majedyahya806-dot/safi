import 'package:flutter/material.dart';
import '../../core/design/tokens.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/onboarding');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SafiColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: SafiColors.surface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: SafiColors.border),
              ),
              child: const Center(
                child: Text('ص', style: TextStyle(fontSize: 56, fontWeight: FontWeight.w700, color: SafiColors.primary, fontFamily: 'Cairo')),
              ),
            ),
            const SizedBox(height: 20),
            const Text('صافي', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: SafiColors.textPrimary, fontFamily: 'Cairo')),
            const SizedBox(height: 8),
            const Text('هل يراك أحد؟', style: TextStyle(fontSize: 16, color: SafiColors.textSecondary, fontFamily: 'Cairo')),
            const SizedBox(height: 40),
            const SizedBox(width: 120, child: LinearProgressIndicator(color: SafiColors.primary, backgroundColor: SafiColors.surfaceElevated, minHeight: 3)),
          ],
        ),
      ),
    );
  }
}
