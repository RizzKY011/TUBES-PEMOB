class ExpenseCategory {
  static const String food = 'Makanan';
  static const String transport = 'Transport';
  static const String entertainment = 'Hiburan';
  static const String bills = 'Tagihan';
  static const String shopping = 'Belanja';
  static const String other = 'Lainnya';

  static const List<String> all = <String>[food, transport, entertainment, bills, shopping, other];
}

class ExpenseItem {
  final String id;
  final DateTime date;
  final double amount;
  final String category;
  final String? note;
  final String? receiptPath; // local file path

  const ExpenseItem({
    required this.id,
    required this.date,
    required this.amount,
    required this.category,
    this.note,
    this.receiptPath,
  });

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'date': date.toIso8601String(),
        'amount': amount,
        'category': category,
        'note': note,
        'receiptPath': receiptPath,
      };

  static ExpenseItem fromMap(Map<String, dynamic> map) => ExpenseItem(
        id: map['id'] as String,
        date: DateTime.parse(map['date'] as String),
        amount: (map['amount'] as num).toDouble(),
        category: map['category'] as String,
        note: map['note'] as String?,
        receiptPath: map['receiptPath'] as String?,
      );
}


