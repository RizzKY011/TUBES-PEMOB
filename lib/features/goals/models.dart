class GoalItem {
  final String id;
  final String name;
  final double targetAmount;
  final DateTime targetDate;
  final double savedAmount;
  final String frequency; // weekly | monthly

  const GoalItem({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.targetDate,
    required this.savedAmount,
    required this.frequency,
  });

  GoalItem copyWith({double? savedAmount}) => GoalItem(
        id: id,
        name: name,
        targetAmount: targetAmount,
        targetDate: targetDate,
        savedAmount: savedAmount ?? this.savedAmount,
        frequency: frequency,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'name': name,
        'targetAmount': targetAmount,
        'targetDate': targetDate.toIso8601String(),
        'savedAmount': savedAmount,
        'frequency': frequency,
      };

  static GoalItem fromMap(Map<String, dynamic> map) => GoalItem(
        id: map['id'] as String,
        name: map['name'] as String,
        targetAmount: (map['targetAmount'] as num).toDouble(),
        targetDate: DateTime.parse(map['targetDate'] as String),
        savedAmount: (map['savedAmount'] as num).toDouble(),
        frequency: map['frequency'] as String,
      );
}


