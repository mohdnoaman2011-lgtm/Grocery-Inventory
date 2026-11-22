import 'package:flutter/material.dart';
import '../theme.dart';
import '../utils.dart';

/// بطاقة عامة بزوايا مستديرة وظل ناعم، وتدعم التدرج اللوني والنقر.
class Surface extends StatelessWidget {
  final Widget child;
  final Color? color;
  final Gradient? gradient;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;

  const Surface({
    super.key,
    required this.child,
    this.color,
    this.gradient,
    this.padding = const EdgeInsets.all(16),
    this.radius = 24,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final light = Theme.of(context).brightness == Brightness.light;
    final base = light ? Colors.white : const Color(0xFF18201C);
    final r = BorderRadius.circular(radius);
    return Container(
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? base) : null,
        gradient: gradient,
        borderRadius: r,
        boxShadow: light && color == null && gradient == null
            ? const [BoxShadow(color: Color(0x1410281E), blurRadius: 18, offset: Offset(0, 6))]
            : null,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(borderRadius: r, onTap: onTap, child: Padding(padding: padding, child: child)),
      ),
    );
  }
}

/// رقم يعدّ تصاعدياً بحركة ناعمة.
class CountUp extends StatelessWidget {
  final num value;
  final TextStyle? style;
  const CountUp(this.value, {super.key, this.style});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: value.toDouble()),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
        builder: (_, v, __) => Text(fmt(v), style: style),
      );
}

/// الشعار بخلفية متناسقة: في الوضع الفاتح يندمج مع الخلفية، وفي الداكن يوضع على بطاقة بيضاء.
class BrandLogo extends StatelessWidget {
  final double height;
  const BrandLogo({super.key, this.height = 110});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    Widget fallback(_, __, ___) => Icon(Icons.shopping_basket, size: height * .7, color: kGreen);
    if (t.brightness == Brightness.dark) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: const Color(0xFFFEFEFF), borderRadius: BorderRadius.circular(28)),
        child: Image.asset('assets/logo.png', height: height, errorBuilder: fallback),
      );
    }
    return Image.asset('assets/logo.png',
        height: height, color: t.scaffoldBackgroundColor, colorBlendMode: BlendMode.multiply, errorBuilder: fallback);
  }
}
