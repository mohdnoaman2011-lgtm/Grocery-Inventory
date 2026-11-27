import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../l10n/strings.dart';

/// شاشة مسح الباركود. تُرجع الرقم المقروء عبر Navigator.pop.
class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});
  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  final controller = MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates);
  bool done = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void onDetect(BarcodeCapture capture) {
    if (done) return;
    for (final b in capture.barcodes) {
      final v = b.rawValue;
      if (v != null && v.isNotEmpty) {
        done = true;
        Navigator.pop(context, v);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          title: Text(tr('scanBarcode')),
          actions: [
            IconButton(icon: const Icon(Icons.flashlight_on_outlined), onPressed: () => controller.toggleTorch()),
          ],
        ),
        extendBodyBehindAppBar: true,
        body: Stack(fit: StackFit.expand, children: [
          MobileScanner(controller: controller, onDetect: onDetect),
          Center(
            child: Container(
              width: 280,
              height: 170,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 60,
            child: Text(tr('scanHint'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 15)),
          ),
        ]),
      );
}
