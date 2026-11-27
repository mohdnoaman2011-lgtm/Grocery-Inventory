import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../l10n/strings.dart';

final _picker = ImagePicker();

/// يعرض خيارات (كاميرا / معرض / حذف) ويرجع مسار الصورة المحفوظة داخل التطبيق.
/// يرجع '' عند اختيار الحذف، و null عند الإلغاء.
Future<String?> pickProductImage(BuildContext context, {required bool hasImage}) async {
  final cs = Theme.of(context).colorScheme;
  final src = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(
          leading: const Icon(Icons.photo_camera_outlined),
          title: Text(tr('takePhoto')),
          onTap: () => Navigator.pop(ctx, 'cam'),
        ),
        ListTile(
          leading: const Icon(Icons.photo_library_outlined),
          title: Text(tr('fromGallery')),
          onTap: () => Navigator.pop(ctx, 'gal'),
        ),
        if (hasImage)
          ListTile(
            leading: Icon(Icons.delete_outline, color: cs.error),
            title: Text(tr('removePhoto'), style: TextStyle(color: cs.error)),
            onTap: () => Navigator.pop(ctx, 'del'),
          ),
        const SizedBox(height: 8),
      ]),
    ),
  );
  if (src == null) return null;
  if (src == 'del') return '';
  try {
    final x = await _picker.pickImage(
      source: src == 'cam' ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 80,
    );
    if (x == null) return null;
    // نسخ الصورة إلى مجلد التطبيق حتى لا تُحذف مع الملفات المؤقتة
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory('${dir.path}/product_images');
    if (!await folder.exists()) await folder.create(recursive: true);
    final dest = '${folder.path}/${DateTime.now().microsecondsSinceEpoch}.jpg';
    await File(x.path).copy(dest);
    return dest;
  } catch (_) {
    return null;
  }
}
