import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../theme.dart';
import '../widgets/ui.dart';
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
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: SizedBox.expand(
          child: Column(children: [
          const Spacer(flex: 3),
          const BrandLogo(height: 220),
          const SizedBox(height: 18),
          Container(width: 40, height: 3, decoration: BoxDecoration(color: kGreen, borderRadius: BorderRadius.circular(9))),
          const SizedBox(height: 14),
          Text(tr('tagline'), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: cs.onSurface)),
          const Spacer(flex: 3),
          SizedBox(
            width: 140,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: const LinearProgressIndicator(minHeight: 4, color: kGreen, backgroundColor: Color(0x331F6F54)),
            ),
          ),
          const SizedBox(height: 12),
          Text(tr('loading'), style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
          const SizedBox(height: 18),
          Text('1.0.0', style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
          const SizedBox(height: 16),
        ]),
        ),
      ),
    );
  }
}
