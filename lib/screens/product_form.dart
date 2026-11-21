import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../l10n/strings.dart';
import '../theme.dart';
import '../models/product.dart';
import '../utils.dart';

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
  late final cost = TextEditingController(text: p?.cost.toString());
  late final price = TextEditingController(text: p?.price.toString());
  late DateTime? expiry = p?.expiry;

  Widget field(TextEditingController c, String k, {bool number = false}) => TextFormField(
        controller: c,
        keyboardType: number ? const TextInputType.numberWithOptions(decimal: true) : null,
        decoration: InputDecoration(labelText: tr(k), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
        validator: (v) => (v == null || v.trim().isEmpty || (number && num.tryParse(v) == null)) ? tr('required') : null,
      );

  Future<void> pickDate() async {
    final n = DateTime.now();
    final d = await showDatePicker(
      context: context, initialDate: expiry ?? n,
      firstDate: n.subtract(const Duration(days: 365)), lastDate: n.add(const Duration(days: 3650)),
    );
    if (d != null) setState(() => expiry = d);
  }

  void save() {
    if (!_key.currentState!.validate()) return;
    state.upsert(Product(
      id: p?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.text.trim(), category: cat.text.trim(),
      qty: int.parse(qty.text), minQty: int.parse(min.text),
      cost: double.parse(cost.text), price: double.parse(price.text), expiry: expiry,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(tr(p == null ? 'addTitle' : 'editTitle'))),
        body: Form(
          key: _key,
          child: ListView(padding: const EdgeInsets.all(16), children: [
            field(name, 'name'),
            const SizedBox(height: 16),
            field(cat, 'category'),
            const SizedBox(height: 16),
            Row(children: [Expanded(child: field(qty, 'qty', number: true)), const SizedBox(width: 12), Expanded(child: field(min, 'min', number: true))]),
            const SizedBox(height: 16),
            Row(children: [Expanded(child: field(cost, 'cost', number: true)), const SizedBox(width: 12), Expanded(child: field(price, 'price', number: true))]),
            const SizedBox(height: 16),
            InkWell(
              onTap: pickDate,
              child: InputDecorator(
                decoration: InputDecoration(labelText: tr('expiry'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), suffixIcon: const Icon(Icons.calendar_today)),
                child: Text(expiry == null ? '—' : fmtDate(expiry!)),
              ),
            ),
          ]),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Expanded(flex: 2, child: FilledButton(style: FilledButton.styleFrom(backgroundColor: kGreen, minimumSize: const Size(0, 50)), onPressed: save, child: Text(tr('save')))),
              const SizedBox(width: 10),
              Expanded(child: OutlinedButton(style: OutlinedButton.styleFrom(minimumSize: const Size(0, 50)), onPressed: () => Navigator.pop(context), child: Text(tr('cancel')))),
            ]),
          ),
        ),
      );
}
