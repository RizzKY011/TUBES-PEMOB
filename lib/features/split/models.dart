import 'package:collection/collection.dart';

class SplitParticipant {
  final String id;
  final String name;
  final double paidAmount;
  final double shareWeight; // 1.0 for equal; custom weights if needed

  const SplitParticipant({
    required this.id,
    required this.name,
    required this.paidAmount,
    required this.shareWeight,
  });

  SplitParticipant copyWith({
    String? id,
    String? name,
    double? paidAmount,
    double? shareWeight,
  }) {
    return SplitParticipant(
      id: id ?? this.id,
      name: name ?? this.name,
      paidAmount: paidAmount ?? this.paidAmount,
      shareWeight: shareWeight ?? this.shareWeight,
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'name': name,
        'paidAmount': paidAmount,
        'shareWeight': shareWeight,
      };

  static SplitParticipant fromMap(Map<String, dynamic> map) => SplitParticipant(
        id: map['id'] as String,
        name: map['name'] as String,
        paidAmount: (map['paidAmount'] as num).toDouble(),
        shareWeight: (map['shareWeight'] as num).toDouble(),
      );
}

class Settlement {
  final String fromParticipantId;
  final String toParticipantId;
  final double amount;

  const Settlement({
    required this.fromParticipantId,
    required this.toParticipantId,
    required this.amount,
  });
}

class SplitResult {
  final Map<String, double> owedByParticipant; // how much each owes
  final Map<String, double> netByParticipant; // positive means should receive
  final List<Settlement> settlements;

  const SplitResult({
    required this.owedByParticipant,
    required this.netByParticipant,
    required this.settlements,
  });
}

class SplitCalculator {
  static SplitResult calculate({
    required List<SplitParticipant> participants,
    required bool equalSplit,
  }) {
    final double totalPaid = participants.fold(0.0, (sum, p) => sum + p.paidAmount);

    // Determine owed per participant based on equal or weighted split
    final Map<String, double> owed = <String, double>{};
    if (participants.isEmpty || totalPaid <= 0.0) {
      for (final p in participants) {
        owed[p.id] = 0.0;
      }
    } else {
      if (equalSplit) {
        final double perHead = totalPaid / participants.length;
        for (final p in participants) {
          owed[p.id] = perHead;
        }
      } else {
        final double weightSum = participants.fold(0.0, (sum, p) => sum + (p.shareWeight <= 0 ? 0 : p.shareWeight));
        if (weightSum <= 0) {
          final double perHead = totalPaid / participants.length;
          for (final p in participants) {
            owed[p.id] = perHead;
          }
        } else {
          for (final p in participants) {
            final double w = p.shareWeight <= 0 ? 0 : p.shareWeight;
            owed[p.id] = totalPaid * (w / weightSum);
          }
        }
      }
    }

    final Map<String, double> net = <String, double>{};
    for (final p in participants) {
      net[p.id] = (p.paidAmount) - (owed[p.id] ?? 0.0);
    }

    // Build settlement suggestions: debtors (negative) pay creditors (positive)
    final List<MapEntry<String, double>> creditors = net.entries
        .where((e) => e.value > 0.0)
        .sortedBy<num>((e) => -e.value) // largest first
        .toList();
    final List<MapEntry<String, double>> debtors = net.entries
        .where((e) => e.value < 0.0)
        .sortedBy<num>((e) => e.value) // most negative first
        .toList();

    final List<Settlement> settlements = <Settlement>[];
    int i = 0;
    int j = 0;
    while (i < debtors.length && j < creditors.length) {
      final String debtorId = debtors[i].key;
      final String creditorId = creditors[j].key;
      final double debtorOwes = (-debtors[i].value);
      final double creditorReceives = creditors[j].value;
      final double x = debtorOwes < creditorReceives ? debtorOwes : creditorReceives;
      if (x > 0) {
        settlements.add(Settlement(fromParticipantId: debtorId, toParticipantId: creditorId, amount: _round2(x)));
      }
      debtors[i] = MapEntry(debtorId, _round2(debtors[i].value + x));
      creditors[j] = MapEntry(creditorId, _round2(creditors[j].value - x));
      if (debtors[i].value >= -1e-6) i++;
      if (creditors[j].value <= 1e-6) j++;
    }

    return SplitResult(
      owedByParticipant: owed.map((k, v) => MapEntry(k, _round2(v))),
      netByParticipant: net.map((k, v) => MapEntry(k, _round2(v))),
      settlements: settlements,
    );
  }

  static double _round2(double v) => (v * 100).roundToDouble() / 100.0;
}

