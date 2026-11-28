/// سطر واحد في عملية جرد: منتج، الكمية في النظام وقت الجرد، والكمية المجرودة فعلياً.
class CountLine {
  final String productId, name, category;
  final int expected, counted;
  const CountLine({
    required this.productId,
    required this.name,
    required this.category,
    required this.expected,
    required this.counted,
  });

  /// الفرق: سالب = نقص، موجب = زيادة.
  int get diff => counted - expected;

  Map<String, dynamic> toJson() => {
        'productId': productId, 'name': name, 'category': category,
        'expected': expected, 'counted': counted,
      };

  factory CountLine.fromJson(Map<String, dynamic> j) => CountLine(
        productId: j['productId'], name: j['name'], category: j['category'] ?? '',
        expected: j['expected'], counted: j['counted'],
      );
}

/// عملية جرد محفوظة.
class StockCount {
  final String id;
  final DateTime date;
  final List<CountLine> lines;
  final bool applied; // هل حُدّثت كميات المخزون بالكميات المجرودة؟
  const StockCount({required this.id, required this.date, required this.lines, required this.applied});

  int get matched => lines.where((l) => l.diff == 0).length;
  int get mismatches => lines.length - matched;
  int get shortageUnits => lines.where((l) => l.diff < 0).fold(0, (a, l) => a - l.diff);
  int get surplusUnits => lines.where((l) => l.diff > 0).fold(0, (a, l) => a + l.diff);

  Map<String, dynamic> toJson() => {
        'id': id, 'date': date.toIso8601String(), 'applied': applied,
        'lines': lines.map((e) => e.toJson()).toList(),
      };

  factory StockCount.fromJson(Map<String, dynamic> j) => StockCount(
        id: j['id'],
        date: DateTime.parse(j['date']),
        applied: j['applied'] ?? false,
        lines: (j['lines'] as List).map((e) => CountLine.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
      );
}
