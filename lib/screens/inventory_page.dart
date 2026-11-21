import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../l10n/strings.dart';
import '../models/product.dart';
import '../utils.dart';
import '../widgets/status_chip.dart';
import '../widgets/ui.dart';
import 'product_form.dart';

Future<bool> confirmDelete(BuildContext c, Product p) async {
  final yes = await showDialog<bool>(
    context: c,
    builder: (d) => AlertDialog(
      icon: const Icon(Icons.delete_outline),
      title: Text(tr('delTitle')),
      content: Text(tr('delMsg').replaceFirst('%s', p.name)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(d, false), child: Text(tr('cancel'))),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: const Color(0xFFB3261E)),
          onPressed: () => Navigator.pop(d, true),
          child: Text(tr('yesDelete')),
        ),
      ],
    ),
  );
  return yes == true;
}

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});
  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  String q = '';
  Status? filter;

  @override
  Widget build(BuildContext context) => watch((c) {
        final cs = Theme.of(c).colorScheme;
        final list = state.products
            .where((p) => p.name.contains(q) && (filter == null || p.status == filter))
            .toList();

        Widget chip(String k, Status? s) => Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: ChoiceChip(
                label: Text(tr(k)),
                selected: filter == s,
                shape: const StadiumBorder(),
                onSelected: (_) => setState(() => filter = s),
              ),
            );

        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => openForm(c),
            icon: const Icon(Icons.add),
            label: Text(tr('newProduct')),
          ),
          body: SafeArea(
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(tr('inventory'), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SearchBar(
                  hintText: tr('search'),
                  leading: const Icon(Icons.search),
                  elevation: const WidgetStatePropertyAll(0.0),
                  backgroundColor: WidgetStatePropertyAll(cs.surfaceContainerHigh),
                  onChanged: (v) => setState(() => q = v),
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(children: [
                  chip('all', null),
                  chip('low', Status.low),
                  chip('expiring', Status.expiring),
                  chip('expired', Status.expired),
                  chip('ok', Status.ok),
                ]),
              ),
              Expanded(
                child: list.isEmpty
                    ? Center(
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.inventory_2_outlined, size: 56, color: cs.outline),
                          const SizedBox(height: 12),
                          Text(tr('empty'), style: TextStyle(color: cs.onSurfaceVariant, fontSize: 16)),
                          if (state.products.isEmpty) ...[
                            const SizedBox(height: 16),
                            FilledButton.tonalIcon(onPressed: () => openForm(c), icon: const Icon(Icons.add), label: Text(tr('addFirst'))),
                          ],
                        ]),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 96),
                        itemCount: list.length,
                        itemBuilder: (_, i) {
                          final p = list[i];
                          Widget swipeBg() => Container(
                                decoration: BoxDecoration(color: cs.errorContainer, borderRadius: BorderRadius.circular(24)),
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                alignment: Alignment.center,
                                child: Align(
                                  alignment: AlignmentDirectional.centerEnd,
                                  child: Icon(Icons.delete_outline, color: cs.onErrorContainer),
                                ),
                              );
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Dismissible(
                              key: ValueKey(p.id),
                              background: swipeBg(),
                              secondaryBackground: swipeBg(),
                              confirmDismiss: (_) => confirmDelete(c, p),
                              onDismissed: (_) => state.remove(p),
                              child: _ProductCard(p),
                            ),
                          );
                        },
                      ),
              ),
            ]),
          ),
        );
      });
}

class _ProductCard extends StatelessWidget {
  final Product p;
  const _ProductCard(this.p);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final br = Theme.of(context).brightness;
    final s = p.status;
    return Surface(
      padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
      onTap: () => openForm(context, p),
      child: Column(children: [
        Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: s.bg(br), borderRadius: BorderRadius.circular(14)),
            child: Icon(s.icon, color: s.fg(br)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              Text('${p.category}${p.expiry != null ? ' · ${fmtDate(p.expiry!)}' : ''}',
                  style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
            ]),
          ),
          StatusChip(s),
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'e') {
                openForm(context, p);
              } else if (await confirmDelete(context, p)) {
                state.remove(p);
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'e', child: Text(tr('edit'))),
              PopupMenuItem(value: 'd', child: Text(tr('delete'))),
            ],
          ),
        ]),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 8),
          child: Row(children: [
            Expanded(
              child: Text(
                '${tr('cost')} ${fmtNum(p.cost)} · ${tr('price')} ${fmtNum(p.price)}\n${tr('min')} ${p.minQty}',
                style: TextStyle(fontSize: 12.5, height: 1.5, color: cs.onSurfaceVariant),
              ),
            ),
            Container(
              decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(99)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: p.qty > 0 ? () => state.changeQty(p, -1) : null,
                  icon: const Icon(Icons.remove),
                ),
                SizedBox(
                  width: 36,
                  child: Text('${p.qty}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => state.changeQty(p, 1),
                  icon: const Icon(Icons.add),
                ),
              ]),
            ),
          ]),
        ),
      ]),
    );
  }
}
