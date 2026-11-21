import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

final state = AppState();

class AppState extends ChangeNotifier {
  List<Product> products = [];
  ThemeMode theme = ThemeMode.light;
  bool isAr = true, autoBackup = true, appLock = false, biometric = false;
  DateTime? lastBackup;
  late SharedPreferences _p;

  Future<void> load() async {
    _p = await SharedPreferences.getInstance();
    final raw = _p.getString('products');
    products = raw == null ? _sample() : _decode(raw);
    theme = ThemeMode.values[_p.getInt('theme') ?? 1];
    isAr = _p.getBool('ar') ?? true;
    autoBackup = _p.getBool('autoBackup') ?? true;
    appLock = _p.getBool('appLock') ?? false;
    biometric = _p.getBool('biometric') ?? false;
    final lb = _p.getString('lastBackup');
    lastBackup = lb == null ? null : DateTime.parse(lb);
  }

  List<Product> _decode(String raw) =>
      (jsonDecode(raw) as List).map((e) => Product.fromJson(e)).toList();
  String _encode() => jsonEncode(products.map((e) => e.toJson()).toList());

  List<Product> _sample() {
    final n = DateTime.now();
    return [
      Product(id: '1', name: 'حليب كامل الدسم 1 لتر', category: 'ألبان', qty: 3, minQty: 10, cost: 4.5, price: 6, expiry: n.add(const Duration(days: 10))),
      Product(id: '2', name: 'زبادي طبيعي', category: 'ألبان', qty: 18, minQty: 12, cost: 1.2, price: 2, expiry: n.add(const Duration(days: 2))),
      Product(id: '3', name: 'أرز بسمتي 5 كجم', category: 'حبوب', qty: 24, minQty: 6, cost: 28, price: 35, expiry: n.add(const Duration(days: 300))),
      Product(id: '4', name: 'عصير برتقال', category: 'مشروبات', qty: 11, minQty: 8, cost: 3, price: 4.5, expiry: n.subtract(const Duration(days: 10))),
    ];
  }

  /// يحفظ كل شيء ويحدّث الواجهة فوراً.
  void commit() {
    _p.setString('products', _encode());
    _p.setInt('theme', theme.index);
    _p.setBool('ar', isAr);
    _p.setBool('autoBackup', autoBackup);
    _p.setBool('appLock', appLock);
    _p.setBool('biometric', biometric);
    notifyListeners();
  }

  void upsert(Product p) {
    final i = products.indexWhere((e) => e.id == p.id);
    i == -1 ? products.add(p) : products[i] = p;
    commit();
  }

  void remove(Product p) {
    products.removeWhere((e) => e.id == p.id);
    commit();
  }

  void changeQty(Product p, int d) {
    p.qty = (p.qty + d).clamp(0, 999999);
    commit();
  }

  void backupNow() {
    _p.setString('backup', _encode());
    lastBackup = DateTime.now();
    _p.setString('lastBackup', lastBackup!.toIso8601String());
    notifyListeners();
  }

  bool restore() {
    final raw = _p.getString('backup');
    if (raw == null) return false;
    products = _decode(raw);
    commit();
    return true;
  }

  int get units => products.fold(0, (a, p) => a + p.qty);
  int count(bool Function(Status) f) => products.where((p) => f(p.status)).length;
  double get value => products.fold(0.0, (a, p) => a + p.cost * p.qty);
  double get profit => products.fold(0.0, (a, p) => a + (p.price - p.cost) * p.qty);
}

