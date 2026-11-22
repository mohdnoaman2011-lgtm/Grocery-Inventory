import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../l10n/strings.dart';
import '../utils.dart';
import '../widgets/pin_pad.dart';
import '../widgets/ui.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) => watch((c) {
        final cs = Theme.of(c).colorScheme;
        void snack(String m) => ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(m)));

        Widget section(String k, List<Widget> kids) => Padding(
              padding: const EdgeInsets.only(top: 22),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: Text(tr(k), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: cs.primary)),
                ),
                Surface(padding: const EdgeInsets.symmetric(vertical: 4), child: Column(children: kids)),
              ]),
            );

        Widget tile(IconData icon, String title, {String? sub, Widget? trailing, VoidCallback? onTap, Color? color}) {
          final col = color ?? cs.primary;
          return ListTile(
            onTap: onTap,
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: col.withAlpha(30), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: col, size: 22),
            ),
            title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
            subtitle: sub == null ? null : Text(sub),
            trailing: trailing,
          );
        }

        Widget switchTile(IconData icon, String title, bool v, ValueChanged<bool> on, {String? sub}) =>
            tile(icon, title, sub: sub, onTap: () => on(!v), trailing: Switch(value: v, onChanged: on));

        Future<void> toggleLock(bool on) async {
          if (on) {
            final pin = await pinDialog(c, title: tr('newPin'), confirmEntry: true);
            if (pin != null) state.enableLock(pin);
          } else {
            final ok = await pinDialog(c, title: tr('currentPin'), verify: state.verifyPin);
            if (ok != null) state.disableLock();
          }
        }

        Future<void> changePin() async {
          final cur = await pinDialog(c, title: tr('currentPin'), verify: state.verifyPin);
          if (cur == null || !c.mounted) return;
          final pin = await pinDialog(c, title: tr('newPin'), confirmEntry: true);
          if (pin != null) {
            state.setPin(pin);
            snack(tr('done'));
          }
        }

        Future<void> toggleBio(bool on) async {
          if (!on) {
            state.biometric = false;
            state.commit();
            return;
          }
          if (!state.appLock) return snack(tr('needLockFirst'));
          final pre = await state.bioCheck();
          if (pre != null) return snack('${tr('bioUnavailable')} ($pre)');
          final err = await state.bioAuth(tr('bioReason'));
          if (err == null) {
            state.biometric = true;
            state.commit();
          } else if (err != 'cancelled') {
            snack('${tr('bioFail')} ($err)');
          }
        }

        Future<bool> confirm(String title, String msg) async {
          final yes = await showDialog<bool>(
            context: c,
            builder: (d) => AlertDialog(
              title: Text(title),
              content: Text(msg),
              actions: [
                TextButton(onPressed: () => Navigator.pop(d, false), child: Text(tr('cancel'))),
                FilledButton(onPressed: () => Navigator.pop(d, true), child: Text(tr('continueBtn'))),
              ],
            ),
          );
          return yes == true;
        }

        Future<void> exportFile() async {
          try {
            final bytes = Uint8List.fromList(utf8.encode(state.exportJson()));
            final name = 'inventory_backup_${fmtDate(DateTime.now()).replaceAll('/', '-')}.json';
            final path = await FilePicker.platform.saveFile(
              dialogTitle: tr('saveToPhone'),
              fileName: name,
              bytes: bytes,
              type: FileType.any,
            );
            if (path != null) {
              state.backupNow();
              snack(tr('saved'));
            }
          } catch (e) {
            snack('$e');
          }
        }

        Future<void> importFile() async {
          try {
            final r = await FilePicker.platform.pickFiles(type: FileType.any, withData: true);
            if (r == null || r.files.isEmpty) return;
            final bytes = r.files.first.bytes;
            if (bytes == null) return snack(tr('badFile'));
            if (state.products.isNotEmpty && !await confirm(tr('restoreFromFile'), tr('importConfirm'))) return;
            snack(tr(state.importJson(utf8.decode(bytes)) ? 'restored' : 'badFile'));
          } catch (e) {
            snack(tr('badFile'));
          }
        }

        Future<void> clearAll() async {
          final yes = await showDialog<bool>(
            context: c,
            builder: (d) => AlertDialog(
              icon: const Icon(Icons.warning_amber_rounded),
              title: Text(tr('clearAll')),
              content: Text(tr('clearAllMsg')),
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
          if (yes == true) {
            state.clearAll();
            snack(tr('done'));
          }
        }

        return Scaffold(
          body: SafeArea(
            child: ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 24), children: [
              Text(tr('settings'), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
              section('appearance', [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ThemeMode>(
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(value: ThemeMode.light, icon: const Icon(Icons.light_mode_outlined), label: Text(tr('light'))),
                        ButtonSegment(value: ThemeMode.dark, icon: const Icon(Icons.dark_mode_outlined), label: Text(tr('dark'))),
                        ButtonSegment(value: ThemeMode.system, icon: const Icon(Icons.brightness_auto_outlined), label: Text(tr('system'))),
                      ],
                      selected: {state.theme},
                      onSelectionChanged: (s) {
                        state.theme = s.first;
                        state.commit();
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: Row(children: [
                    Icon(Icons.translate, color: cs.primary),
                    const SizedBox(width: 12),
                    Expanded(child: Text(tr('language'), style: const TextStyle(fontWeight: FontWeight.w600))),
                    SegmentedButton<bool>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(value: true, label: Text('العربية')),
                        ButtonSegment(value: false, label: Text('English')),
                      ],
                      selected: {state.isAr},
                      onSelectionChanged: (s) {
                        state.isAr = s.first;
                        state.commit();
                      },
                    ),
                  ]),
                ),
              ]),
              section('backup', [
                tile(
                  Icons.save_alt,
                  tr('lastBackup'),
                  sub: state.lastBackup == null ? tr('never') : fmtDate(state.lastBackup!),
                  trailing: FilledButton.tonal(onPressed: exportFile, child: Text(tr('backupNow'))),
                ),
                tile(Icons.folder_open, tr('restoreFromFile'), trailing: const Icon(Icons.chevron_right), onTap: importFile),
                switchTile(Icons.autorenew, tr('autoBackup'), state.autoBackup, (v) {
                  state.autoBackup = v;
                  state.commit();
                  if (v) state.maybeAutoBackup();
                }, sub: tr('autoBackupHint')),
                tile(Icons.settings_backup_restore, tr('restoreInternal'), trailing: const Icon(Icons.chevron_right), onTap: () {
                  snack(tr(state.restore() ? 'restored' : 'noBackup'));
                }),
              ]),
              section('security', [
                switchTile(Icons.lock_outline, tr('appLock'), state.appLock, toggleLock),
                if (state.appLock) tile(Icons.password, tr('changePin'), trailing: const Icon(Icons.chevron_right), onTap: changePin),
                switchTile(Icons.fingerprint, tr('biometric'), state.biometric, toggleBio),
              ]),
              section('data', [
                tile(Icons.delete_outline, tr('clearAll'), color: cs.error, onTap: clearAll),
                tile(Icons.info_outline, tr('version'), trailing: const Text('1.0.0')),
              ]),
            ]),
          ),
        );
      });
}
