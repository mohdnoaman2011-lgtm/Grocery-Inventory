import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../l10n/strings.dart';
import '../models/product.dart';
import '../utils.dart';
import '../widgets/status_chip.dart';
import '../widgets/ui.dart';
import 'product_form.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => watch((c) {
        final cs = Theme.of(c).colorScheme;
        final br = Theme.of(c).brightness;
        final empty = state.products.isEmpty;
        final critical = state.products.where((p) => p.status != Status.ok).toList()
          ..sort((a, b) => b.status.index.compareTo(a.status.index));

        Widget mini(IconData icon, String k, num v, Color tint) => Expanded(
              child: Surface(
                radius: 20,
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: tint.withAlpha(38), shape: BoxShape.circle),
                    child: Icon(icon, color: tint, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      CountUp(v, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, height: 1.2)),
                      Text(tr(k), maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11.5, height: 1.25, color: cs.onSurfaceVariant)),
                    ]),
                  ),
                ]),
              ),
            );

        String sub(Product p) => (p.status == Status.low || p.expiry == null)
            ? '${tr('qty')}: ${p.qty} / ${p.minQty}'
            : fmtDate(p.expiry!);

        return Scaffold(
          body: SafeArea(
            child: ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 20), children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(tr('welcome'), style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant)),
                  Text(tr('app'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                ]),
                FilledButton.icon(
                  onPressed: () => openForm(c),
                  icon: const Icon(Icons.add),
                  label: Text(tr('newProduct')),
                ),
              ]),
              const SizedBox(height: 20),
              if (empty)
                Surface(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                  child: Column(children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(color: cs.primaryContainer, shape: BoxShape.circle),
                      child: Icon(Icons.inventory_2_outlined, size: 36, color: cs.onPrimaryContainer),
                    ),
                    const SizedBox(height: 18),
                    Text(tr('emptyHome'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 18),
                    FilledButton.icon(onPressed: () => openForm(c), icon: const Icon(Icons.add), label: Text(tr('addFirst'))),
                  ]),
                )
              else ...[
                Surface(
                  radius: 24,
                  padding: const EdgeInsets.all(18),
                  gradient: const LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [kGreen, kGreenDark]),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(tr('stockValue'), style: TextStyle(color: Colors.white.withAlpha(215), fontSize: 14)),
                      const SizedBox(height: 6),
                      CountUp(state.value, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(color: Colors.white.withAlpha(38), borderRadius: BorderRadius.circular(99)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.trending_up, color: Colors.white, size: 18),
                          const SizedBox(width: 6),
                          Text('${tr('profit')}: ${fmt(state.profit)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                        ]),
                      ),
                    ]),
                  ),
                ),
                const SizedBox(height: 12),
                IntrinsicHeight(
                  child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  mini(Icons.category_outlined, 'totalItems', state.products.length, cs.primary),
                  const SizedBox(width: 12),
                  mini(Icons.layers_outlined, 'totalUnits', state.units, cs.tertiary),
                  ]),
                ),
                const SizedBox(height: 12),
                IntrinsicHeight(
                  child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  mini(Icons.trending_down, 'lowStock', state.count((s) => s == Status.low), Status.low.fg(br)),
                  const SizedBox(width: 12),
                  mini(Icons.event_busy, 'expiryAlerts', state.count((s) => s == Status.expiring || s == Status.expired), Status.expired.fg(br)),
                  ]),
                ),
                const SizedBox(height: 20),
                Text(tr('attention'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                if (critical.isEmpty)
                  Surface(
                    child: Row(children: [
                      Icon(Icons.check_circle, color: Status.ok.fg(br)),
                      const SizedBox(width: 12),
                      Expanded(child: Text(tr('allGood'), style: const TextStyle(fontWeight: FontWeight.w600))),
                    ]),
                  )
                else
                  ...critical.take(4).map((p) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Surface(
                          padding: const EdgeInsets.all(14),
                          onTap: () => openForm(c, p),
                          child: Row(children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(color: p.status.bg(br), borderRadius: BorderRadius.circular(14)),
                              child: Icon(p.status.icon, color: p.status.fg(br)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                                Text(sub(p), style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
                              ]),
                            ),
                            StatusChip(p.status),
                          ]),
                        ),
                      )),
              ],
            ]),
          ),
        );
      });
}
