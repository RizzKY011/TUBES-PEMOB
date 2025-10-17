import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import '../expense/models.dart';
import 'models.dart';

class BudgetRepository {
  static const String boxName = 'budgets';

  Future<void> init() async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<String>(boxName);
    }
  }

  Box<String> get _box => Hive.box<String>(boxName);

  Future<void> upsert(BudgetItem item) async {
    await _box.put(item.id, jsonEncode(item.toMap()));
  }

  List<BudgetItem> getAll() => _box.values
      .map((String v) => BudgetItem.fromMap(jsonDecode(v) as Map<String, dynamic>))
      .toList();

  Future<void> delete(String id) async => _box.delete(id);

  double monthSpendForCategory(List<ExpenseItem> allExpenses, String category, DateTime month) {
    final DateTime start = DateTime(month.year, month.month, 1);
    final DateTime end = DateTime(month.year, month.month + 1, 0);
    return allExpenses
        .where((ExpenseItem e) => e.category == category && !e.date.isBefore(start) && !e.date.isAfter(end))
        .fold(0.0, (double s, ExpenseItem e) => s + e.amount);
  }
}


