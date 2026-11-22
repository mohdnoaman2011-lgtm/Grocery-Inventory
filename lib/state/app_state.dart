import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

final state = AppState();

class AppState extends ChangeNotifier {
  List<Product> products = [];
  ThemeMode theme = ThemeMode.system;
  bool isAr = true, autoBackup = true, appLock = false, biometric = false;
  bool locked = false, authenticating = false;
  DateTime? lastBackup;
  String? pinHash, pinSalt;
  late SharedPreferences _p;
  final _auth = LocalAuthentication();

  // ───── التحميل ─────
  Future<void> load() async {
    _p = await SharedPreferences.getInstance();
    // حذف البيانات التجريبية القديمة (معرّفاتها 1 إلى 4) من المنتجات ومن النسخة الاحتياطية
    products = _clean(_p.getString('products'));
    final bk = _p.getString('backup');
    if (bk != null) _p.setString('backup', _encode(_clean(bk)));
    _p.setString('products', _encode(products));

    theme = ThemeMode.values[_p.getInt('theme') ?? 0];
    isAr = _p.getBool('ar') ?? true;
    autoBackup = _p.getBool('autoBackup') ?? true;
    appLock = _p.getBool('appLock') ?? false;
    biometric = _p.getBool('biometric') ?? false;
    pinHash = _p.getString('pinHash');
    pinSalt = _p.getString('pinSalt');
    final lb = _p.getString('lastBackup');
    lastBackup = lb == null ? null : DateTime.parse(lb);
    locked = appLock && pinHash != null;
    maybeAutoBackup();
  }

  List<Product> _decode(String raw) =>
      (jsonDecode(raw) as List).map((e) => Product.fromJson(e)).toList();
  String _encode(List<Product> l) => jsonEncode(l.map((e) => e.toJson()).toList());
  List<Product> _clean(String? raw) => raw == null
      ? []
      : _decode(raw).where((p) => !const {'1', '2', '3', '4'}.contains(p.id)).toList();

  void commit() {
    _p.setString('products', _encode(products));
    _p.setInt('theme', theme.index);
    _p.setBool('ar', isAr);
    _p.setBool('autoBackup', autoBackup);
    _p.setBool('appLock', appLock);
    _p.setBool('biometric', biometric);
    notifyListeners();
  }

  // ───── المنتجات ─────
  void upsert(Product p) {
    final i = products.indexWhere((e) => e.id == p.id);
    i == -1 ? products.add(p) : products[i] = p;
    commit();
  }

  void remove(Product p) {
    products.removeWhere((e) => e.id == p.id);
    commit();
  }

  void clearAll() {
    products.clear();
    commit();
  }

  void changeQty(Product p, int d) {
    p.qty = (p.qty + d).clamp(0, 999999);
    commit();
  }

  // ───── النسخ الاحتياطي ─────
  void backupNow() {
    _p.setString('backup', _encode(products));
    lastBackup = DateTime.now();
    _p.setString('lastBackup', lastBackup!.toIso8601String());
    notifyListeners();
  }

  /// ينسخ تلقائياً إن مرّت 7 أيام على آخر نسخة.
  void maybeAutoBackup() {
    if (!autoBackup || products.isEmpty) return;
    if (lastBackup == null || DateTime.now().difference(lastBackup!).inDays >= 7) backupNow();
  }

  bool restore() {
    final raw = _p.getString('backup');
    if (raw == null) return false;
    products = _decode(raw);
    commit();
    return true;
  }

  // ───── تصدير / استيراد ملف ─────
  String exportJson() => jsonEncode({
        'app': 'grocery_inventory',
        'v': 1,
        'date': DateTime.now().toIso8601String(),
        'products': products.map((e) => e.toJson()).toList(),
      });

  bool importJson(String raw) {
    try {
      final m = jsonDecode(raw);
      final list = (m is Map ? m['products'] : m) as List;
      products = list.map((e) => Product.fromJson(e)).toList();
      commit();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ───── القفل بالرمز السري ─────
  String _hash(String pin, String salt) => sha256.convert(utf8.encode('$salt:$pin')).toString();

  void setPin(String pin) {
    pinSalt = Random.secure().nextInt(1 << 31).toString();
    pinHash = _hash(pin, pinSalt!);
    _p.setString('pinHash', pinHash!);
    _p.setString('pinSalt', pinSalt!);
  }

  bool verifyPin(String pin) => pinHash != null && _hash(pin, pinSalt!) == pinHash;

  void enableLock(String pin) {
    setPin(pin);
    appLock = true;
    commit();
  }

  void disableLock() {
    appLock = false;
    biometric = false;
    pinHash = null;
    pinSalt = null;
    _p.remove('pinHash');
    _p.remove('pinSalt');
    commit();
  }

  void lockNow() {
    if (appLock && pinHash != null && !locked && !authenticating) {
      locked = true;
      notifyListeners();
    }
  }

  void unlock() {
    locked = false;
    notifyListeners();
  }

  // ───── البصمة ─────
  /// يرجع null إذا كانت البصمة جاهزة، أو سبب العطل.
  Future<String?> bioCheck() async {
    try {
      if (!await _auth.isDeviceSupported()) return 'not_supported';
      if ((await _auth.getAvailableBiometrics()).isEmpty) return 'not_enrolled';
      return null;
    } on PlatformException catch (e) {
      return '${e.code}: ${e.message ?? ''}';
    } catch (e) {
      return '$e';
    }
  }

  /// يرجع null عند النجاح، 'cancelled' عند الإلغاء، أو نص الخطأ.
  Future<String?> bioAuth(String reason) async {
    authenticating = true;
    try {
      final ok = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(biometricOnly: false, stickyAuth: true),
      );
      return ok ? null : 'cancelled';
    } on PlatformException catch (e) {
      return '${e.code}: ${e.message ?? ''}';
    } catch (e) {
      return '$e';
    } finally {
      Future.delayed(const Duration(milliseconds: 600), () => authenticating = false);
    }
  }

  // ───── الإحصائيات ─────
  int get units => products.fold(0, (a, p) => a + p.qty);
  int count(bool Function(Status) f) => products.where((p) => f(p.status)).length;
  double get value => products.fold(0.0, (a, p) => a + p.cost * p.qty);
  double get profit => products.fold(0.0, (a, p) => a + (p.price - p.cost) * p.qty);
}
