class DebtItem {
  final String id;
  final String fromName; // who owes
  final String toName; // who receives
  final double amount;
  final DateTime createdAt;
  final bool settled;

  const DebtItem({
    required this.id,
    required this.fromName,
    required this.toName,
    required this.amount,
    required this.createdAt,
    this.settled = false,
  });

  DebtItem copyWith({bool? settled}) => DebtItem(
        id: id,
        fromName: fromName,
        toName: toName,
        amount: amount,
        createdAt: createdAt,
        settled: settled ?? this.settled,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'fromName': fromName,
        'toName': toName,
        'amount': amount,
        'createdAt': createdAt.toIso8601String(),
        'settled': settled,
      };

  static DebtItem fromMap(Map<String, dynamic> map) => DebtItem(
        id: map['id'] as String,
        fromName: map['fromName'] as String,
        toName: map['toName'] as String,
        amount: (map['amount'] as num).toDouble(),
        createdAt: DateTime.parse(map['createdAt'] as String),
        settled: map['settled'] as bool? ?? false,
      );
}


