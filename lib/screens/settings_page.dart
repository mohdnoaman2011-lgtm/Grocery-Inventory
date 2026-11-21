import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../l10n/strings.dart';
import '../theme.dart';
import '../utils.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) => watch((c) {
        Widget section(String k, List<Widget> children) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 16, 4, 6),
                child: Text(tr(k), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kGreen)),
              ),
              Card(elevation: 0, child: Column(children: children)),
            ]);
        Widget row(String k, Widget trailing) => ListTile(title: Text(tr(k)), trailing: trailing);

        return Scaffold(
          body: SafeArea(
            child: ListView(padding: const EdgeInsets.all(16), children: [
              Text(tr('settings'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              section('appearance', [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ThemeMode>(
                      segments: [
                        ButtonSegment(value: ThemeMode.light, label: Text(tr('light'))),
                        ButtonSegment(value: ThemeMode.dark, label: Text(tr('dark'))),
                        ButtonSegment(value: ThemeMode.system, label: Text(tr('system'))),
                      ],
                      selected: {state.theme},
                      onSelectionChanged: (s) { state.theme = s.first; state.commit(); },
                    ),
                  ),
                ),
                row('language', SegmentedButton<bool>(
                  segments: const [ButtonSegment(value: true, label: Text('العربية')), ButtonSegment(value: false, label: Text('English'))],
                  selected: {state.isAr},
                  onSelectionChanged: (s) { state.isAr = s.first; state.commit(); },
                )),
              ]),
              section('backup', [
                ListTile(
                  title: Text(tr('lastBackup')),
                  subtitle: Text(state.lastBackup == null ? tr('never') : fmtDate(state.lastBackup!)),
                  trailing: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: kGreen),
                    onPressed: () {
                      state.backupNow();
                      ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(tr('done'))));
                    },
                    child: Text(tr('backupNow')),
                  ),
                ),
                SwitchListTile(title: Text(tr('autoBackup')), value: state.autoBackup, onChanged: (v) { state.autoBackup = v; state.commit(); }),
                ListTile(
                  title: Text(tr('restore')),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    final ok = state.restore();
                    ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(tr(ok ? 'done' : 'never'))));
                  },
                ),
              ]),
              section('security', [
                // للقفل الفعلي والبصمة استخدم حزمة local_auth وربطها بهذين المفتاحين.
                SwitchListTile(title: Text(tr('appLock')), value: state.appLock, onChanged: (v) { state.appLock = v; state.commit(); }),
                SwitchListTile(title: Text(tr('biometric')), value: state.biometric, onChanged: (v) { state.biometric = v; state.commit(); }),
              ]),
            ]),
          ),
        );
      });
}
