import 'package:flutter/material.dart';
import 'app.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await state.load();
  runApp(const InventoryApp());
}
