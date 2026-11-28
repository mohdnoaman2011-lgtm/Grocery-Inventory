import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../l10n/strings.dart';
import '../models/product.dart';
import '../utils.dart';
import '../widgets/ui.dart';
import 'counts_history_page.dart';
import 'new_count_page.dart';
import 'product_form.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => watch((c) {
        final cs = Theme.of(c).colorScheme;
        final br = Theme.of(c).brightness;
        final empty = state.products.isEmpty;

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

        return Scaffold(
          body: SafeArea(
            child: ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 20), children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(tr('welcome'), style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant)),
                  Text(tr('app'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                ]),
              ]),
              const SizedBox(height: 18),
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
              else
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
              ActionCard(
                icon: Icons.add_circle,
                title: tr('newCount'),
                subtitle: tr('newCountSub'),
                colors: const [Color(0xFF12483A), Color(0xFF2E9E78)],
                onTap: () => Navigator.of(c).push(MaterialPageRoute(builder: (_) => const NewCountPage())),
              ),
              const SizedBox(height: 12),
              ActionCard(
                icon: Icons.history,
                title: tr('pastCounts'),
                subtitle: tr('pastCountsSub'),
                colors: const [Color(0xFF2B8A6C), Color(0xFF52B596)],
                onTap: () => Navigator.of(c).push(MaterialPageRoute(builder: (_) => const CountsHistoryPage())),
              ),
              if (!empty) ...[
                const SizedBox(height: 12),
                IntrinsicHeight(
                  child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    mini(Icons.category_outlined, 'totalItems', state.products.length, cs.primary),
                    const SizedBox(width: 12),
                    mini(Icons.trending_down, 'lowStock', state.count((s) => s == Status.low), Status.low.fg(br)),
                  ]),
                ),
                const SizedBox(height: 12),
                IntrinsicHeight(
                  child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    mini(Icons.event_busy, 'expiryAlerts', state.count((s) => s == Status.expiring || s == Status.expired), Status.expired.fg(br)),
                  ]),
                ),
              ],
            ]),
          ),
        );
      });
}
