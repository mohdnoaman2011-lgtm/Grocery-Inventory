import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../theme.dart';
import 'shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const Shell()));
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(center: Alignment(0, -0.2), radius: 1.1, colors: [Colors.white, Color(0xFFF3F8F5), Color(0xFFE3EEE8)], stops: [0, .55, 1]),
          ),
          child: SafeArea(
            child: Column(children: [
              const Spacer(flex: 3),
              Image.asset('assets/logo.png', width: 280,
                  errorBuilder: (_, __, ___) => const Icon(Icons.shopping_basket, size: 120, color: kGreen)),
              const SizedBox(height: 18),
              Container(width: 40, height: 3, decoration: BoxDecoration(color: kGreen, borderRadius: BorderRadius.circular(9))),
              const SizedBox(height: 14),
              Text(tr('tagline'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2F3A35))),
              const Spacer(flex: 3),
              SizedBox(width: 140, child: ClipRRect(borderRadius: BorderRadius.circular(9), child: const LinearProgressIndicator(minHeight: 4, color: kGreen, backgroundColor: Color(0xFFCFDDD5)))),
              const SizedBox(height: 12),
              Text(tr('loading'), style: const TextStyle(fontSize: 13, color: Color(0xFF4F5B55))),
              const SizedBox(height: 18),
              const Text('1.0.0', style: TextStyle(fontSize: 12, color: Color(0xFF4F5B55))),
              const SizedBox(height: 16),
            ]),
          ),
        ),
      );
}
