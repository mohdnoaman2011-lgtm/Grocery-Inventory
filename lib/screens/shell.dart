import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../utils.dart';
import 'home_page.dart';
import 'inventory_page.dart';
import 'settings_page.dart';

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int i = 0;

  @override
  Widget build(BuildContext context) => watch((c) => Scaffold(
        body: IndexedStack(index: i, children: const [HomePage(), InventoryPage(), SettingsPage()]),
        bottomNavigationBar: NavigationBar(
          selectedIndex: i,
          onDestinationSelected: (v) => setState(() => i = v),
          destinations: [
            NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: tr('home')),
            NavigationDestination(icon: const Icon(Icons.checklist_outlined), selectedIcon: const Icon(Icons.checklist), label: tr('inventory')),
            NavigationDestination(icon: const Icon(Icons.tune_outlined), selectedIcon: const Icon(Icons.tune), label: tr('settings')),
          ],
        ),
      ));
}

