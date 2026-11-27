import 'package:flutter/material.dart';
import '../l10n/strings.dart';

enum Status { ok, low, expiring, expired }

extension StatusUi on Status {
  String get label => tr(name);

  IconData get icon => switch (this) {
        Status.ok => Icons.check_circle_outline,
        Status.low => Icons.trending_down,
        Status.expiring => Icons.hourglass_bottom,
        Status.expired => Icons.event_busy,
      };

  Color fg(Brightness b) => b == Brightness.light
      ? switch (this) {
          Status.ok => const Color(0xFF145238),
          Status.low => const Color(0xFF7A4B00),
          _ => const Color(0xFF8C1D18),
        }
      : switch (this) {
          Status.ok => const Color(0xFF6FCF97),
          Status.low => const Color(0xFFFFC857),
          _ => const Color(0xFFFF8A80),
        };

  Color bg(Brightness b) => b == Brightness.light
      ? switch (this) {
          Status.ok => const Color(0xFFE1F2EA),
          Status.low => const Color(0xFFFFF1D6),
          _ => const Color(0xFFFDE4E1),
        }
      : fg(b).withAlpha(46);
}

class Product {
  String id, name, category;
  int qty, minQty;
  double cost, price;
  DateTime? expiry;
  String? imagePath, barcode;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.qty,
    required this.minQty,
    required this.cost,
    required this.price,
    this.expiry,
    this.imagePath,
    this.barcode,
  });

  Status get status {
    final n = DateTime.now();
    final today = DateTime(n.year, n.month, n.day);
    if (expiry != null) {
      if (expiry!.isBefore(today)) return Status.expired;
      if (expiry!.difference(today).inDays <= 7) return Status.expiring;
    }
    return qty <= minQty ? Status.low : Status.ok;
  }

  Map<String, dynamic> toJson() => {
        'id': id, 'name': name, 'category': category, 'qty': qty,
        'minQty': minQty, 'cost': cost, 'price': price,
        'expiry': expiry?.toIso8601String(),
        'imagePath': imagePath, 'barcode': barcode,
      };

  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id: j['id'], name: j['name'], category: j['category'],
        qty: j['qty'], minQty: j['minQty'],
        cost: (j['cost'] as num).toDouble(), price: (j['price'] as num).toDouble(),
        expiry: j['expiry'] == null ? null : DateTime.parse(j['expiry']),
        imagePath: j['imagePath'], barcode: j['barcode'],
      );
}
