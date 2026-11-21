import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../theme.dart';

/// لوحة أرقام لإدخال رمز من 4 خانات.
class PinPad extends StatefulWidget {
  final String title;
  final String? error;
  final void Function(String pin) onDone;
  final VoidCallback? onBio;
  const PinPad({super.key, required this.title, required this.onDone, this.error, this.onBio});

  @override
  State<PinPad> createState() => _PinPadState();
}

class _PinPadState extends State<PinPad> {
  String pin = '';

  void _tap(String d) {
    if (pin.length >= 4) return;
    setState(() => pin += d);
    if (pin.length == 4) {
      final p = pin;
      Future.delayed(const Duration(milliseconds: 150), () {
        if (!mounted) return;
        setState(() => pin = '');
        widget.onDone(p);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Widget key(Widget child, VoidCallback? onTap) => SizedBox(
          width: 72,
          height: 72,
          child: Material(
            color: onTap == null ? Colors.transparent : cs.surfaceContainerHighest,
            shape: const CircleBorder(),
            child: InkWell(customBorder: const CircleBorder(), onTap: onTap, child: Center(child: child)),
          ),
        );
    Widget digit(String d) => key(Text(d, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600)), () => _tap(d));
    Widget row(List<Widget> c) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: c),
        );

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(widget.title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (i) {
            final on = i < pin.length;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: on ? kGreen : Colors.transparent,
                border: Border.all(color: on ? kGreen : cs.outline, width: 2),
              ),
            );
          }),
        ),
        SizedBox(
          height: 30,
          child: Center(
            child: Text(widget.error ?? '', style: TextStyle(color: cs.error, fontSize: 13)),
          ),
        ),
        row([digit('1'), digit('2'), digit('3')]),
        row([digit('4'), digit('5'), digit('6')]),
        row([digit('7'), digit('8'), digit('9')]),
        row([
          widget.onBio != null
              ? key(const Icon(Icons.fingerprint, size: 32), widget.onBio)
              : const SizedBox(width: 72, height: 72),
          digit('0'),
          key(const Icon(Icons.backspace_outlined), pin.isEmpty ? null : () => setState(() => pin = pin.substring(0, pin.length - 1))),
        ]),
      ]),
    );
  }
}

/// نافذة إدخال/إنشاء/تحقق من الرمز. تُرجع الرمز عند النجاح أو null عند الإلغاء.
Future<String?> pinDialog(
  BuildContext context, {
  required String title,
  bool confirmEntry = false,
  bool Function(String)? verify,
}) {
  String? first;
  String? err;
  return showDialog<String>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, set) => AlertDialog(
        content: SizedBox(
          width: 300,
          child: PinPad(
            title: first == null ? title : tr('pinConfirm'),
            error: err,
            onDone: (p) {
              if (verify != null) {
                if (verify(p)) {
                  Navigator.pop(ctx, p);
                } else {
                  set(() => err = tr('pinWrong'));
                }
                return;
              }
              if (!confirmEntry) {
                Navigator.pop(ctx, p);
              } else if (first == null) {
                set(() {
                  first = p;
                  err = null;
                });
              } else if (first == p) {
                Navigator.pop(ctx, p);
              } else {
                set(() {
                  first = null;
                  err = tr('pinMismatch');
                });
              }
            },
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('cancel')))],
      ),
    ),
  );
}
