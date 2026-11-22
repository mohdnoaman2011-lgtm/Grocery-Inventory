import 'package:flutter/material.dart';
import '../state/app_state.dart';

/// فئات المنتجات (تُحفظ بالعربية، وتُعرض بالإنجليزية عند تغيير اللغة).
const kCategories = <String>[
  'المواد الغذائية الأساسية',
  'الألبان والأجبان',
  'المعلبات',
  'المشروبات والعصائر',
  'المخبوزات والحلويات',
  'التوابل والبهارات',
  'المجمدات',
  'المنظفات والورقيات',
  'العناية الشخصية',
];

const _en = <String, String>{
  'المواد الغذائية الأساسية': 'Basic groceries',
  'الألبان والأجبان': 'Dairy & cheese',
  'المعلبات': 'Canned goods',
  'المشروبات والعصائر': 'Drinks & juices',
  'المخبوزات والحلويات': 'Bakery & sweets',
  'التوابل والبهارات': 'Spices & seasonings',
  'المجمدات': 'Frozen foods',
  'المنظفات والورقيات': 'Cleaning & paper goods',
  'العناية الشخصية': 'Personal care',
};

const _icons = <String, IconData>{
  'المواد الغذائية الأساسية': Icons.rice_bowl_outlined,
  'الألبان والأجبان': Icons.egg_alt_outlined,
  'المعلبات': Icons.inventory_2_outlined,
  'المشروبات والعصائر': Icons.local_drink_outlined,
  'المخبوزات والحلويات': Icons.bakery_dining_outlined,
  'التوابل والبهارات': Icons.grain,
  'المجمدات': Icons.ac_unit,
  'المنظفات والورقيات': Icons.cleaning_services_outlined,
  'العناية الشخصية': Icons.spa_outlined,
};

String categoryLabel(String k) => state.isAr ? k : (_en[k] ?? k);
IconData categoryIcon(String k) => _icons[k] ?? Icons.category_outlined;
