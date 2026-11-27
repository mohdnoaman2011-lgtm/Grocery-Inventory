import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../l10n/strings.dart';

/// يفتح ماسح الباركود كنافذة سفلية، ويرجع الرقم المقروء أو null عند الإلغاء.
Future<String?> scanBarcode(BuildContext context) => showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      dragHandleColor: Colors.white38,
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

  /// بديل إن تعذّر البث المباشر: التقاط صورة بكاميرا النظام ثم قراءة الباركود منها.
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
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return SafeArea(
      top: false,
      child: SizedBox(
        height: h * 0.74,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
            child: Text(tr('scanHint'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 18)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: Stack(fit: StackFit.expand, children: [
                MobileScanner(controller: controller, onDetect: (c) => _finish(c.barcodes)),
                Center(
                  child: Container(
                    width: 270,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white70, width: 2),
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
                PositionedDirectional(
                  top: 12,
                  end: 12,
                  child: IconButton.filledTonal(
                    onPressed: () => controller.toggleTorch(),
                    icon: const Icon(Icons.flashlight_on_outlined),
                  ),
                ),
                // عند تعذّر تشغيل الكاميرا يظهر سبب الخطأ بدل الرسالة العامة
                ValueListenableBuilder<MobileScannerState>(
                  valueListenable: controller,
                  builder: (context, v, _) {
                    final e = v.error;
                    if (e == null) return const SizedBox.shrink();
                    return Container(
                      color: Colors.black87,
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.error_outline, color: Colors.white, size: 40),
                          const SizedBox(height: 12),
                          Text(tr('scanErr'), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          Text('${e.errorCode.name}${e.errorDetails?.message != null ? '\n${e.errorDetails!.message}' : ''}',
                              textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        ]),
                      ),
                    );
                  },
                ),
              ]),
            ),
          ),
          if (note != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(note!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.amber, fontSize: 13)),
            ),
          TextButton.icon(
            onPressed: _fromPhoto,
            icon: const Icon(Icons.photo_camera_outlined, color: Colors.white70),
            label: Text(tr('scanFromPhoto'), style: const TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('cancel'), style: const TextStyle(color: Colors.white70, fontSize: 16)),
          ),
          const SizedBox(height: 4),
        ]),
      ),
    );
  }
}
