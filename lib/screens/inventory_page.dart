import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../l10n/strings.dart';
import '../theme.dart';
import '../models/product.dart';
import '../utils.dart';
import '../widgets/status_chip.dart';
import 'product_form.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});
  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  String q = '';
  Status? filter;

  Future<void> confirmDelete(Product p) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(tr('delTitle')),
        content: Text(tr('delMsg').replaceFirst('%s', p.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(tr('cancel'))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFB3261E)),
            onPressed: () => Navigator.pop(c, true),
            child: Text(tr('yesDelete')),
          ),
        ],
      ),
    );
    if (yes == true) state.remove(p);
  }

  @override
  Widget build(BuildContext context) => watch((c) {
        final list = state.products
            .where((p) => p.name.contains(q) && (filter == null || p.status == filter))
            .toList();
        Widget chip(String k, Status? s) => Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: ChoiceChip(label: Text(tr(k)), selected: filter == s, onSelected: (_) => setState(() => filter = s)),
            );
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            backgroundColor: kGreen, foregroundColor: Colors.white,
            onPressed: () => openForm(c), child: const Icon(Icons.add),
          ),
          body: SafeArea(
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  onChanged: (v) => setState(() => q = v),
                  decoration: InputDecoration(
                    hintText: tr('search'), prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(children: [
                  chip('all', null), chip('low', Status.low), chip('expiring', Status.expiring),
                  chip('expired', Status.expired), chip('ok', Status.ok),
                ]),
              ),
              Expanded(
                child: list.isEmpty
                    ? Center(child: Text(tr('empty')))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                        itemCount: list.length,
                        itemBuilder: (_, i) => _ProductCard(list[i], onDelete: () => confirmDelete(list[i])),
                      ),
              ),
            ]),
          ),
        );
      });
}

class _ProductCard extends StatelessWidget {
  final Product p;
  final VoidCallback onDelete;
  const _ProductCard(this.p, {required this.onDelete});

  @override
  Widget build(BuildContext context) => Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 10),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
          child: Column(children: [
            Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  Text('${p.category}${p.expiry != null ? ' · ${fmtDate(p.expiry!)}' : ''}', style: const TextStyle(fontSize: 12)),
                ]),
              ),
              StatusChip(p.status),
              PopupMenuButton<String>(
                onSelected: (v) => v == 'e' ? openForm(context, p) : onDelete(),
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'e', child: Text(tr('edit'))),
                  PopupMenuItem(value: 'd', child: Text(tr('delete'))),
                ],
              ),
            ]),
            const SizedBox(height: 6),
            Row(children: [
              Expanded(child: Text('${tr('cost')} ${p.cost} · ${tr('price')} ${p.price} · ${tr('min')} ${p.minQty}', style: const TextStyle(fontSize: 12))),
              IconButton.filledTonal(onPressed: () => state.changeQty(p, 1), icon: const Icon(Icons.add)),
              SizedBox(width: 40, child: Text('${p.qty}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700))),
              IconButton.filledTonal(onPressed: () => state.changeQty(p, -1), icon: const Icon(Icons.remove)),
            ]),
          ]),
        ),
      );
}
