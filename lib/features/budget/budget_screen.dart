import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../expense/models.dart';
import '../expense/repository.dart';
import 'models.dart';
import 'repository.dart';
import '../../core/notifications/notifications.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final BudgetRepository _repo = BudgetRepository();
  final ExpenseRepository _expenseRepo = ExpenseRepository();
  final NumberFormat _currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');
  List<BudgetItem> _items = <BudgetItem>[];
  List<ExpenseItem> _expenses = <ExpenseItem>[];
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month, 1);

  @override
  void initState() {
    super.initState();
    Future.wait(<Future<void>>[
      _repo.init(),
      _expenseRepo.init(),
    ]).then((_) => setState(() {
          _items = _repo.getAll();
          _expenses = _expenseRepo.getAll();
        }));
  }

  Future<void> _addBudget() async {
    final BudgetItem? item = await showDialog<BudgetItem>(
      context: context,
      builder: (BuildContext context) => const _BudgetDialog(),
    );
    if (item != null) {
      await _repo.upsert(item);
      setState(() => _items = _repo.getAll());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            title: const Text('Budget Planner'),
            actions: <Widget>[
              IconButton(
                tooltip: 'Pilih Bulan',
                icon: const Icon(Icons.calendar_month),
                onPressed: () async {
                  final DateTime now = DateTime.now();
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _month,
                    firstDate: DateTime(now.year - 2),
                    lastDate: DateTime(now.year + 2),
                  );
                  if (picked != null) setState(() => _month = DateTime(picked.year, picked.month, 1));
                },
              ),
            ],
          ),
          SliverList.builder(
            itemCount: _items.length,
            itemBuilder: (BuildContext _, int index) {
              final BudgetItem b = _items[index];
              final double spent = _repo.monthSpendForCategory(_expenses, b.category, _month);
              final double ratio = (b.monthlyLimit <= 0) ? 0 : (spent / b.monthlyLimit).clamp(0, 1);
              final bool nearLimit = ratio >= 0.8;
              if (nearLimit) {
                AppNotifications.showSimple(title: 'Budget ${b.category}', body: 'Pengeluaran mendekati limit');
              }
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  title: Text(b.category),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Limit: ${_currency.format(b.monthlyLimit)}'),
                      Text('Terpakai: ${_currency.format(spent)}'),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(value: ratio),
                      if (nearLimit) const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text('Mendekati limit!', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      final BudgetItem? edited = await showDialog<BudgetItem>(
                        context: context,
                        builder: (BuildContext context) => _BudgetDialog(initial: b),
                      );
                      if (edited != null) {
                        await _repo.upsert(edited.copyWith());
                        setState(() => _items = _repo.getAll());
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addBudget,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _BudgetDialog extends StatefulWidget {
  final BudgetItem? initial;
  const _BudgetDialog({this.initial});

  @override
  State<_BudgetDialog> createState() => _BudgetDialogState();
}

class _BudgetDialogState extends State<_BudgetDialog> {
  String _category = ExpenseCategory.other;
  final TextEditingController _limit = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _category = widget.initial!.category;
      _limit.text = widget.initial!.monthlyLimit.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Tambah Budget' : 'Ubah Budget'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          DropdownButtonFormField<String>(
            value: _category,
            items: ExpenseCategory.all.map((String c) => DropdownMenuItem<String>(value: c, child: Text(c))).toList(),
            onChanged: (String? v) => setState(() => _category = v ?? ExpenseCategory.other),
            decoration: const InputDecoration(labelText: 'Kategori'),
          ),
          TextField(
            controller: _limit,
            decoration: const InputDecoration(labelText: 'Limit Bulanan'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        FilledButton(
          onPressed: () {
            final double? lim = double.tryParse(_limit.text.replaceAll(',', '.'));
            if (lim == null || lim <= 0) return;
            final BudgetItem item = widget.initial ?? BudgetItem(
              id: const Uuid().v4(),
              category: _category,
              monthlyLimit: lim,
              createdAt: DateTime.now(),
            );
            Navigator.pop(context, item.copyWith(category: _category, monthlyLimit: lim));
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}

