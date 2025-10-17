import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'models.dart';

class DebtRepository {
  static const String boxName = 'debts';

  Future<void> init() async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<String>(boxName);
    }
  }

  Box<String> get _box => Hive.box<String>(boxName);

  Future<void> add(DebtItem item) async => _box.put(item.id, jsonEncode(item.toMap()));
  Future<void> delete(String id) async => _box.delete(id);
  Future<void> update(DebtItem item) async => _box.put(item.id, jsonEncode(item.toMap()));

  List<DebtItem> getAll() => _box.values
      .map((String v) => DebtItem.fromMap(jsonDecode(v) as Map<String, dynamic>))
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
}


