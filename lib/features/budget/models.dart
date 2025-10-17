class BudgetItem {
  final String id;
  final String category;
  final double monthlyLimit;
  final DateTime createdAt;

  const BudgetItem({
    required this.id,
    required this.category,
    required this.monthlyLimit,
    required this.createdAt,
  });

  BudgetItem copyWith({String? category, double? monthlyLimit}) => BudgetItem(
        id: id,
        category: category ?? this.category,
        monthlyLimit: monthlyLimit ?? this.monthlyLimit,
        createdAt: createdAt,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'category': category,
        'monthlyLimit': monthlyLimit,
        'createdAt': createdAt.toIso8601String(),
      };

  static BudgetItem fromMap(Map<String, dynamic> map) => BudgetItem(
        id: map['id'] as String,
        category: map['category'] as String,
        monthlyLimit: (map['monthlyLimit'] as num).toDouble(),
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}


