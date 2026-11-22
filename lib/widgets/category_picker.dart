import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../models/categories.dart';
import '../theme.dart';

/// قائمة سفلية لاختيار فئة المنتج. تُرجع الفئة المختارة أو null.
Future<String?> pickCategory(BuildContext context, String current) {
  final list = [...kCategories];
  // إن كان للمنتج فئة قديمة خارج القائمة تبقى متاحة في أعلاها
  if (current.isNotEmpty && !list.contains(current)) list.insert(0, current);
  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.78),
        child: ListView(shrinkWrap: true, padding: const EdgeInsets.only(bottom: 12), children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(tr('chooseCategory'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          ),
          for (final k in list)
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: kGreen.withAlpha(30), borderRadius: BorderRadius.circular(12)),
                child: Icon(categoryIcon(k), color: kGreen, size: 22),
              ),
              title: Text(categoryLabel(k), style: const TextStyle(fontWeight: FontWeight.w600)),
              trailing: k == current ? const Icon(Icons.check_circle, color: kGreen) : null,
              onTap: () => Navigator.pop(ctx, k),
            ),
        ]),
      ),
    ),
  );
}
