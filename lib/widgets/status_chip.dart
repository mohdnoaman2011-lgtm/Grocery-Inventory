import 'package:flutter/material.dart';
import '../models/product.dart';

class StatusChip extends StatelessWidget {
  final Status s;
  const StatusChip(this.s, {super.key});

  @override
  Widget build(BuildContext context) {
    final br = Theme.of(context).brightness;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: s.bg(br), borderRadius: BorderRadius.circular(99)),
      child: Text(s.label, style: TextStyle(color: s.fg(br), fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}
