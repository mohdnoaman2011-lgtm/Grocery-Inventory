import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../l10n/strings.dart';

/// يفتح ماسح الباركود كنافذة سفلية سوداء، ويرجع الرقم المقروء أو null عند الإلغاء.
Future<String?> scanBarcode(BuildContext context) => showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => const _ScannerSheet(),
    );

class _ScannerSheet extends StatefulWidget {
  const _ScannerSheet();
  @override
  State<_ScannerSheet> createState() => _ScannerSheetState();
}

class _ScannerSheetState extends State<_ScannerSheet> {
  final controller = MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates);
  bool done = false;
  String? note;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _finish(Iterable<Barcode> codes) {
    if (done) return;
    for (final b in codes) {
      final v = b.rawValue;
      if (v != null && v.isNotEmpty) {
        done = true;
        Navigator.pop(context, v);
        return;
      }
    }
  }

  /// بديل يظهر فقط إن تعذّر البث المباشر: صورة بكاميرا النظام ثم قراءة الباركود منها.
  Future<void> _fromPhoto() async {
    try {
      final x = await ImagePicker().pickImage(source: ImageSource.camera);
      if (x == null) return;
      final cap = await controller.analyzeImage(x.path);
      if (cap == null || cap.barcodes.isEmpty) {
        if (mounted) setState(() => note = tr('noBarcodeFound'));
        return;
      }
      _finish(cap.barcodes);
    } catch (e) {
      if (mounted) setState(() => note = '$e');
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        top: false,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // مقبض السحب
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(color: Colors.white38, borderRadius: BorderRadius.circular(99)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 16),
            child: Text(tr('scanHint'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 18)),
          ),
          // معاينة الكاميرا بعرض النافذة وبزوايا مستديرة
          AspectRatio(
            aspectRatio: 1.45,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: Stack(fit: StackFit.expand, children: [
                MobileScanner(controller: controller, onDetect: (c) => _finish(c.barcodes)),
                // عند تعذّر تشغيل الكاميرا يظهر السبب وزر القراءة من صورة
                ValueListenableBuilder<MobileScannerState>(
                  valueListenable: controller,
                  builder: (context, v, _) {
                    final e = v.error;
                    if (e == null) return const SizedBox.shrink();
                    return Container(
                      color: Colors.black87,
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: SingleChildScrollView(
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.error_outline, color: Colors.white, size: 32),
                            const SizedBox(height: 8),
                            Text(tr('scanErr'), style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text('${e.errorCode.name}${e.errorDetails?.message != null ? '\n${e.errorDetails!.message}' : ''}',
                                textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            if (note != null) ...[
                              const SizedBox(height: 6),
                              Text(note!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.amber, fontSize: 12)),
                            ],
                            TextButton.icon(
                              onPressed: _fromPhoto,
                              icon: const Icon(Icons.photo_camera_outlined, color: Colors.white),
                              label: Text(tr('scanFromPhoto'), style: const TextStyle(color: Colors.white)),
                            ),
                          ]),
                        ),
                      ),
                    );
                  },
                ),
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(tr('cancel'), style: const TextStyle(color: Colors.white70, fontSize: 17)),
            ),
          ),
        ]),
      );
}
