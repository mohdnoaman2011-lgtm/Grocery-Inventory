import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../l10n/strings.dart';
import '../models/product.dart';
import '../models/stock_count.dart';
import '../widgets/ui.dart';
import 'barcode_scanner_page.dart';

/// شاشة إنشاء جرد جديد: يُدخل المستخدم الكمية الفعلية لكل منتج، ثم يُنهي الجرد ويُحفظ السجل.
class NewCountPage extends StatefulWidget {
  const NewCountPage({super.key});
  @override
  State<NewCountPage> createState() => _NewCountPageState();
}

class _NewCountPageState extends State<NewCountPage> {
  final counted = <String, int>{};
  String q = '';

  void snack(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  /// مسح باركود منتج يزيد كميته المجرودة بواحد.
  Future<void> scan() async {
    final code = await scanBarcode(context);
    if (code == null || !mounted) return;
    final found = state.products.where((e) => e.barcode == code).toList();
    if (found.isEmpty) return snack(tr('noProductBarcode'));
    final p = found.first;
    setState(() => counted[p.id] = (counted[p.id] ?? 0) + 1);
    snack('${p.name}: ${counted[p.id]}');
  }

  Future<void> finish() async {
    final lines = [
      for (final p in state.products)
        if (counted.containsKey(p.id))
          CountLine(productId: p.id, name: p.name, category: p.category, expected: p.qty, counted: counted[p.id]!),
    ];
    final draft = StockCount(id: '', date: DateTime.now(), lines: lines, applied: false);
    bool apply = true;
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => StatefulBuilder(
        builder: (d, set) => AlertDialog(
          icon: const Icon(Icons.fact_check_outlined),
          title: Text(tr('countSummary')),
          content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${tr('countedItems')}: ${lines.length}'),
            Text('${tr('matched')}: ${draft.matched}'),
            Text('${tr('shortage')}: ${draft.shortageUnits} ${tr('units')}'),
            Text('${tr('surplus')}: ${draft.surplusUnits} ${tr('units')}'),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(tr('applyQty'), style: const TextStyle(fontSize: 14)),
              value: apply,
              onChanged: (v) => set(() => apply = v),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(d, false), child: Text(tr('cancel'))),
            FilledButton(onPressed: () => Navigator.pop(d, true), child: Text(tr('finishCount'))),
          ],
        ),
      ),
    );
    if (ok != true || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    state.addCount(StockCount(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      date: draft.date,
      lines: lines,
      applied: apply,
    ));
    Navigator.pop(context);
    messenger.showSnackBar(SnackBar(content: Text(tr('done'))));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final br = Theme.of(context).brightness;
    final list = state.products.where((p) => p.name.contains(q) || (p.barcode ?? '').contains(q)).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    final total = state.products.length;

    Widget diffChip(int d) {
      final s = d == 0 ? Status.ok : (d < 0 ? Status.expired : Status.low);
      final label = d == 0 ? tr('matched') : tr(d < 0 ? 'shortageN' : 'surplusN').replaceFirst('%s', '${d.abs()}');
      return Container(
        margin: const EdgeInsets.only(top: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(color: s.bg(br), borderRadius: BorderRadius.circular(99)),
        child: Text(label, style: TextStyle(color: s.fg(br), fontSize: 12, fontWeight: FontWeight.w700)),
      );
    }

    Widget row(Product p) {
      final c = counted[p.id];
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Surface(
          radius: 20,
          padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                Text('${tr('systemQty')}: ${p.qty}', style: TextStyle(fontSize: 12.5, color: cs.onSurfaceVariant)),
                if (c != null) diffChip(c - p.qty),
              ]),
            ),
            if (c == null)
              TextButton(onPressed: () => setState(() => counted[p.id] = p.qty), child: Text(tr('matched'))),
            Container(
              decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(99)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => setState(() => counted[p.id] = ((c ?? 0) - 1).clamp(0, 999999)),
                  icon: const Icon(Icons.remove),
                ),
                SizedBox(
                  width: 38,
                  child: Text(c?.toString() ?? '—', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => setState(() => counted[p.id] = (c ?? 0) + 1),
                  icon: const Icon(Icons.add),
                ),
              ]),
            ),
          ]),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('newCount')),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        centerTitle: false,
        actions: [IconButton(icon: const Icon(Icons.qr_code_scanner), onPressed: scan)],
      ),
      body: total == 0
          ? Center(child: Text(tr('empty'), style: TextStyle(color: cs.onSurfaceVariant, fontSize: 16)))
          : Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(tr('countedOf').replaceFirst('%s', '${counted.length}').replaceFirst('%s', '$total'),
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(value: counted.length / total, minHeight: 8),
                  ),
                  const SizedBox(height: 12),
                  SearchBar(
                    hintText: tr('search'),
                    leading: const Icon(Icons.search),
                    elevation: const WidgetStatePropertyAll(0.0),
                    backgroundColor: WidgetStatePropertyAll(cs.surfaceContainerHigh),
                    onChanged: (v) => setState(() => q = v),
                  ),
                ]),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  children: [for (final p in list) row(p)],
                ),
              ),
            ]),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: FilledButton.icon(
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54)),
            onPressed: counted.isEmpty ? null : finish,
            icon: const Icon(Icons.check),
            label: Text(tr('finishCount')),
          ),
        ),
      ),
    );
  }
}
