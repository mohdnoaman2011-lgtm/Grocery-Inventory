import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../l10n/strings.dart';
import '../models/product.dart';
import '../models/stock_count.dart';
import '../utils.dart';
import '../widgets/ui.dart';
import 'new_count_page.dart';

/// قائمة عمليات الجرد السابقة.
class CountsHistoryPage extends StatelessWidget {
  const CountsHistoryPage({super.key});

  @override
  Widget build(BuildContext context) => watch((c) {
        final cs = Theme.of(c).colorScheme;
        final br = Theme.of(c).brightness;
        return Scaffold(
          appBar: AppBar(
            title: Text(tr('pastCounts')),
            backgroundColor: Colors.transparent,
            scrolledUnderElevation: 0,
            centerTitle: false,
          ),
          body: state.counts.isEmpty
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.history, size: 56, color: cs.outline),
                    const SizedBox(height: 12),
                    Text(tr('noCounts'), style: TextStyle(color: cs.onSurfaceVariant, fontSize: 16)),
                    const SizedBox(height: 16),
                    FilledButton.tonalIcon(
                      onPressed: () => Navigator.of(c).pushReplacement(MaterialPageRoute(builder: (_) => const NewCountPage())),
                      icon: const Icon(Icons.add),
                      label: Text(tr('newCount')),
                    ),
                  ]),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  itemCount: state.counts.length,
                  itemBuilder: (_, i) {
                    final k = state.counts[i];
                    final clean = k.mismatches == 0;
                    final s = clean ? Status.ok : Status.low;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Surface(
                        padding: const EdgeInsets.all(14),
                        onTap: () => Navigator.of(c).push(MaterialPageRoute(builder: (_) => CountDetailPage(id: k.id))),
                        child: Row(children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(color: s.bg(br), borderRadius: BorderRadius.circular(14)),
                            child: Icon(clean ? Icons.check_circle_outline : Icons.rule, color: s.fg(br)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('${fmtDate(k.date)}  ${fmtTime(k.date)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                              Text('${tr('countedItems')}: ${k.lines.length} · ${clean ? tr('noDiffs') : '${tr('diffItems')}: ${k.mismatches}'}',
                                  style: TextStyle(fontSize: 12.5, color: cs.onSurfaceVariant)),
                            ]),
                          ),
                          const Icon(Icons.chevron_right),
                        ]),
                      ),
                    );
                  },
                ),
        );
      });
}

/// تفاصيل عملية جرد: كل منتج مع الكمية في النظام والمجرودة والفرق.
class CountDetailPage extends StatelessWidget {
  final String id;
  const CountDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) => watch((c) {
        final cs = Theme.of(c).colorScheme;
        final br = Theme.of(c).brightness;
        final found = state.counts.where((e) => e.id == id).toList();
        if (found.isEmpty) return const Scaffold(body: SizedBox.shrink());
        final k = found.first;

        Future<void> delete() async {
          final yes = await showDialog<bool>(
            context: c,
            builder: (d) => AlertDialog(
              icon: const Icon(Icons.delete_outline),
              title: Text(tr('deleteCount')),
              content: Text(tr('deleteCountMsg')),
              actions: [
                TextButton(onPressed: () => Navigator.pop(d, false), child: Text(tr('cancel'))),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: cs.error, foregroundColor: cs.onError),
                  onPressed: () => Navigator.pop(d, true),
                  child: Text(tr('yesDelete')),
                ),
              ],
            ),
          );
          if (yes == true && c.mounted) {
            state.deleteCount(k.id);
            Navigator.pop(c);
          }
        }

        Widget stat(String label, String v) => Expanded(
              child: Column(children: [
                Text(v, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
              ]),
            );

        return Scaffold(
          appBar: AppBar(
            title: Text('${fmtDate(k.date)}  ${fmtTime(k.date)}'),
            backgroundColor: Colors.transparent,
            scrolledUnderElevation: 0,
            centerTitle: false,
            actions: [IconButton(icon: Icon(Icons.delete_outline, color: cs.error), onPressed: delete)],
          ),
          body: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 24), children: [
            Surface(
              child: Column(children: [
                Row(children: [
                  stat(tr('countedItems'), '${k.lines.length}'),
                  stat(tr('matched'), '${k.matched}'),
                  stat(tr('shortage'), '${k.shortageUnits}'),
                  stat(tr('surplus'), '${k.surplusUnits}'),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Icon(k.applied ? Icons.sync : Icons.sync_disabled, size: 18, color: cs.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text(tr(k.applied ? 'applied' : 'notApplied'), style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
                ]),
              ]),
            ),
            const SizedBox(height: 14),
            for (final l in k.lines)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Surface(
                  radius: 20,
                  padding: const EdgeInsets.all(14),
                  child: Row(children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(l.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                        Text('${tr('systemQty')}: ${l.expected} · ${tr('countedQty')}: ${l.counted}',
                            style: TextStyle(fontSize: 12.5, color: cs.onSurfaceVariant)),
                      ]),
                    ),
                    Builder(builder: (_) {
                      final s = l.diff == 0 ? Status.ok : (l.diff < 0 ? Status.expired : Status.low);
                      final label = l.diff == 0
                          ? tr('matched')
                          : tr(l.diff < 0 ? 'shortageN' : 'surplusN').replaceFirst('%s', '${l.diff.abs()}');
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: s.bg(br), borderRadius: BorderRadius.circular(99)),
                        child: Text(label, style: TextStyle(color: s.fg(br), fontSize: 12, fontWeight: FontWeight.w700)),
                      );
                    }),
                  ]),
                ),
              ),
          ]),
        );
      });
}
