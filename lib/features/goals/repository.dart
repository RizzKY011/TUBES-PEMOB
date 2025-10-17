import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'models.dart';

class GoalsRepository {
  static const String boxName = 'goals';

  Future<void> init() async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<String>(boxName);
    }
  }

  Box<String> get _box => Hive.box<String>(boxName);

  Future<void> upsert(GoalItem item) async => _box.put(item.id, jsonEncode(item.toMap()));
  Future<void> delete(String id) async => _box.delete(id);

  List<GoalItem> getAll() => _box.values
      .map((String v) => GoalItem.fromMap(jsonDecode(v) as Map<String, dynamic>))
      .toList();
}


