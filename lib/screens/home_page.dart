import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../l10n/strings.dart';
import '../models/product.dart';
import '../utils.dart';
import '../widgets/status_chip.dart';
import 'product_form.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => watch((c) {
        final critical = state.products.where((p) => p.status != Status.ok).toList()
          ..sort((a, b) => b.status.index.compareTo(a.status.index));
        Widget stat(String k, String v, [Color? bg, Color? fg]) => Card(
              color: bg, elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(tr(k), style: TextStyle(fontSize: 13, color: fg)),
                  Text(v, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: fg)),
                ]),
              ),
            );
        return Scaffold(
          body: SafeArea(
            child: ListView(padding: const EdgeInsets.all(16), children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(tr('welcome'), style: const TextStyle(fontSize: 12)),
                  Text(tr('app'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                ]),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: kGreen, minimumSize: const Size(0, 46)),
                  onPressed: () => openForm(c),
                  child: Text(tr('newProduct')),
                ),
              ]),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2, childAspectRatio: 1.7, mainAxisSpacing: 10, crossAxisSpacing: 10,
                shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                children: [
                  stat('totalItems', fmt(state.products.length)),
                  stat('totalUnits', fmt(state.units)),
                  stat('lowStock', fmt(state.count((s) => s == Status.low)), const Color(0xFFFFF1D6), const Color(0xFF7A4B00)),
                  stat('expiryAlerts', fmt(state.count((s) => s == Status.expiring || s == Status.expired)), const Color(0xFFFDE4E1), const Color(0xFF8C1D18)),
                  stat('stockValue', fmt(state.value)),
                  stat('profit', fmt(state.profit), const Color(0xFFE1F2EA), const Color(0xFF145238)),
                ],
              ),
              const SizedBox(height: 18),
              Text(tr('attention'), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              ...critical.take(3).map((p) => Card(
                    elevation: 0,
                    child: ListTile(
                      title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(p.expiry != null ? fmtDate(p.expiry!) : '${p.qty} / ${p.minQty}'),
                      trailing: StatusChip(p.status),
                    ),
                  )),
            ]),
          ),
        );
      });
}
