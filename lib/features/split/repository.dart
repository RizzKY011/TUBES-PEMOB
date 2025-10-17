import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'models.dart';

class SplitSession {
  final String id;
  final DateTime createdAt;
  final bool equalSplit;
  final List<SplitParticipant> participants;

  const SplitSession({
    required this.id,
    required this.createdAt,
    required this.equalSplit,
    required this.participants,
  });

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'equalSplit': equalSplit,
        'participants': participants.map((p) => p.toMap()).toList(),
      };

  static SplitSession fromMap(Map<String, dynamic> map) => SplitSession(
        id: map['id'] as String,
        createdAt: DateTime.parse(map['createdAt'] as String),
        equalSplit: map['equalSplit'] as bool,
        participants: (map['participants'] as List<dynamic>).map((e) => SplitParticipant.fromMap(Map<String, dynamic>.from(e as Map))).toList(),
      );
}

class SplitRepository {
  static const String boxName = 'split_sessions';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(boxName);
  }

  Box<String> get _box => Hive.box<String>(boxName);

  Future<void> saveSession(SplitSession session) async {
    final String jsonStr = jsonEncode(session.toMap());
    await _box.put(session.id, jsonStr);
  }

  List<SplitSession> getAllSessions() {
    return _box.values
        .map((String v) => SplitSession.fromMap(jsonDecode(v) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> deleteSession(String id) async {
    await _box.delete(id);
  }
}


