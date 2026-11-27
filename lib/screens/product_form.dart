import 'dart:io';
import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../l10n/strings.dart';
import '../models/product.dart';
import '../theme.dart';
import '../utils.dart';
import '../models/categories.dart';
import '../widgets/category_picker.dart';
import '../widgets/ui.dart';
import 'barcode_scanner_page.dart';
import '../widgets/product_media.dart';

void openForm(BuildContext c, [Product? p]) =>
    Navigator.of(c).push(MaterialPageRoute(fullscreenDialog: true, builder: (_) => ProductForm(product: p)));

class ProductForm extends StatefulWidget {
  final Product? product;
  const ProductForm({super.key, this.product});
  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _key = GlobalKey<FormState>();
  late final p = widget.product;
  late final name = TextEditingController(text: p?.name);
  late final cat = TextEditingController(text: p?.category);
  late final qty = TextEditingController(text: p?.qty.toString());
  late final min = TextEditingController(text: p?.minQty.toString());
  late final cost = TextEditingController(text: p == null ? null : fmtNum(p!.cost));
  late final price = TextEditingController(text: p == null ? null : fmtNum(p!.price));
  late DateTime? expiry = p?.expiry;
  late final barcode = TextEditingController(text: p?.barcode);
  late String? image = p?.imagePath;

  InputDecoration deco({Widget? suffix}) => InputDecoration(
        filled: true,
        isDense: true,
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      );

  /// عنوان فوق الحقل (بدل العنوان العائم الذي كان يتداخل مع حدود الحقل).
  Widget labeled(String k, Widget child) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 6),
          child: Text(tr(k), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ),
        child,
      ]);

  Widget field(TextEditingController c, String k, {bool number = false}) => labeled(
        k,
        TextFormField(
          controller: c,
          keyboardType: number ? const TextInputType.numberWithOptions(decimal: true) : null,
          decoration: deco(),
          validator: (v) => (v == null || v.trim().isEmpty || (number && num.tryParse(v) == null)) ? tr('required') : null,
        ),
      );

  Widget categoryField() => labeled(
        'category',
        FormField<String>(
          validator: (_) => cat.text.trim().isEmpty ? tr('required') : null,
          builder: (st) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () async {
                final v = await pickCategory(context, cat.text);
                if (v != null) {
                  setState(() => cat.text = v);
                  st.didChange(v);
                }
              },
              child: InputDecorator(
                decoration: deco(suffix: const Icon(Icons.keyboard_arrow_down)),
                isEmpty: cat.text.isEmpty,
                child: Text(
                  cat.text.isEmpty ? tr('chooseCategory') : categoryLabel(cat.text),
                  style: TextStyle(color: cat.text.isEmpty ? Theme.of(context).hintColor : null),
                ),
              ),
            ),
            if (st.hasError)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                child: Text(st.errorText!, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
              ),
          ]),
        ),
      );

  Future<void> pickImage() async {
    final r = await pickProductImage(context, hasImage: image != null);
    if (r == null || !mounted) return;
    // حذف الصورة المؤقتة السابقة إن كانت جديدة وغير محفوظة
    if (image != null && image != p?.imagePath) {
      try {
        File(image!).deleteSync();
      } catch (_) {}
    }
    setState(() => image = r.isEmpty ? null : r);
  }

  Future<void> scan() async {
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(fullscreenDialog: true, builder: (_) => const BarcodeScannerPage()),
    );
    if (code == null || !mounted) return;
    setState(() => barcode.text = code);
    final dup = state.products.where((e) => e.barcode == code && e.id != p?.id).toList();
    if (dup.isEmpty) return;
    final open = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        icon: const Icon(Icons.qr_code_2),
        title: Text(tr('barcodeExistsTitle')),
        content: Text(tr('barcodeExists').replaceFirst('%s', dup.first.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: Text(tr('keepAdding'))),
          FilledButton(onPressed: () => Navigator.pop(d, true), child: Text(tr('openIt'))),
        ],
      ),
    );
    if (open == true && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(fullscreenDialog: true, builder: (_) => ProductForm(product: dup.first)),
      );
    }
  }

  /// أعلى النموذج: بطاقتا (صورة المنتج) و(مسح الباركود) ثم حقل رقم الباركود.
  Widget mediaSection() {
    final cs = Theme.of(context).colorScheme;
    Widget tile(IconData icon, String label, VoidCallback onTap, {Widget? content}) => Expanded(
          child: Material(
            color: cs.primaryContainer.withAlpha(120),
            borderRadius: BorderRadius.circular(24),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: SizedBox(
                height: 124,
                child: content ??
                    Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(icon, size: 34, color: cs.primary),
                      const SizedBox(height: 10),
                      Text(label, style: TextStyle(fontWeight: FontWeight.w700, color: cs.primary)),
                    ]),
              ),
            ),
          ),
        );
    final hasImg = image != null && File(image!).existsSync();
    return Column(children: [
      Row(children: [
        tile(
          Icons.add_a_photo,
          tr('productPhoto'),
          pickImage,
          content: hasImg
              ? Stack(fit: StackFit.expand, children: [
                  Image.file(File(image!), fit: BoxFit.cover, cacheWidth: 600),
                  PositionedDirectional(
                    top: 8,
                    end: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                      child: const Icon(Icons.edit, size: 16, color: Colors.white),
                    ),
                  ),
                ])
              : null,
        ),
        const SizedBox(width: 12),
        tile(Icons.qr_code_scanner, tr('scanBarcode'), scan),
      ]),
    ]);
  }

  /// حقل رقم الباركود (يوضع قبل تاريخ انتهاء الصلاحية).
  Widget barcodeField() => labeled(
          'barcodeLabel',
          Row(children: [
            Expanded(
              child: TextFormField(
                controller: barcode,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  filled: true,
                  isDense: true,
                  hintText: tr('barcodeHint'),
                  prefixIcon: const Icon(Icons.qr_code_2),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Material(
              color: kGreen,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: scan,
                child: const SizedBox(width: 52, height: 52, child: Icon(Icons.qr_code_scanner, color: Colors.white)),
              ),
            ),
          ]),
      );

  Future<void> pickDate() async {
    final n = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: expiry ?? n,
      firstDate: n.subtract(const Duration(days: 365)),
      lastDate: n.add(const Duration(days: 3650)),
    );
    if (d != null) setState(() => expiry = d);
  }

  void save() {
    if (!_key.currentState!.validate()) return;
    state.upsert(Product(
      id: p?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.text.trim(),
      category: cat.text.trim(),
      qty: int.parse(qty.text),
      minQty: int.parse(min.text),
      cost: double.parse(cost.text),
      price: double.parse(price.text),
      expiry: expiry,
      imagePath: image,
      barcode: barcode.text.trim().isEmpty ? null : barcode.text.trim(),
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(tr(p == null ? 'addTitle' : 'editTitle')),
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
          centerTitle: false,
          systemOverlayStyle: overlayFor(Theme.of(context).brightness),
        ),
        body: Form(
          key: _key,
          child: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 24), children: [
            mediaSection(),
            const SizedBox(height: 14),
            Surface(
              child: Column(children: [
                field(name, 'name'),
                const SizedBox(height: 16),
                categoryField(),
              ]),
            ),
            const SizedBox(height: 14),
            Surface(
              child: Column(children: [
                Row(children: [
                  Expanded(child: field(qty, 'qty', number: true)),
                  const SizedBox(width: 12),
                  Expanded(child: field(min, 'min', number: true)),
                ]),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(child: field(cost, 'cost', number: true)),
                  const SizedBox(width: 12),
                  Expanded(child: field(price, 'price', number: true)),
                ]),
              ]),
            ),
            const SizedBox(height: 14),
            Surface(child: barcodeField()),
            const SizedBox(height: 14),
            Surface(
              child: labeled(
                'expiry',
                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: pickDate,
                  child: InputDecorator(
                    decoration: deco(suffix: const Icon(Icons.calendar_today_outlined)),
                    child: Text(expiry == null ? '—' : fmtDate(expiry!), style: const TextStyle(fontSize: 15)),
                  ),
                ),
              ),
            ),
          ]),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(children: [
              Expanded(
                flex: 2,
                child: FilledButton(
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 54)),
                  onPressed: save,
                  child: Text(tr('save')),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(minimumSize: const Size(0, 54)),
                  onPressed: () => Navigator.pop(context),
                  child: Text(tr('cancel')),
                ),
              ),
            ]),
          ),
        ),
      );
}
