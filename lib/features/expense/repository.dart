import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'models.dart';

class ExpenseRepository {
  static const String boxName = 'expenses';

  Future<void> init() async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<String>(boxName);
    }
  }

  Box<String> get _box => Hive.box<String>(boxName);

  Future<void> addExpense(ExpenseItem item) async {
    await _box.put(item.id, jsonEncode(item.toMap()));
  }

  List<ExpenseItem> getAll() {
    return _box.values
        .map((String v) => ExpenseItem.fromMap(jsonDecode(v) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> delete(String id) async => _box.delete(id);
}


