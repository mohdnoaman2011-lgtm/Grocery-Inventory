import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../state/app_state.dart';
import '../widgets/pin_pad.dart';
import '../widgets/ui.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});
  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String? error;

  @override
  void initState() {
    super.initState();
    if (state.biometric) WidgetsBinding.instance.addPostFrameCallback((_) => _bio());
  }

  Future<void> _bio() async {
    if (await state.bioAuth(tr('bioReason')) == null) state.unlock();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const BrandLogo(height: 110),
                const SizedBox(height: 28),
                PinPad(
                  title: tr('enterPin'),
                  error: error,
                  onBio: state.biometric ? _bio : null,
                  onDone: (p) {
                    if (state.verifyPin(p)) {
                      state.unlock();
                    } else {
                      setState(() => error = tr('pinWrong'));
                    }
                  },
                ),
              ]),
            ),
          ),
        ),
      );
}
