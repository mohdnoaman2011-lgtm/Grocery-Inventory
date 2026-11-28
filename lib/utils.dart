import 'package:flutter/material.dart';
import 'state/app_state.dart';

String fmt(num n) => n.round().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
String fmtNum(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toString();
String fmtTime(DateTime d) => '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
String fmtDate(DateTime d) => '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';
Widget watch(WidgetBuilder b) => ListenableBuilder(listenable: state, builder: (c, _) => b(c));
