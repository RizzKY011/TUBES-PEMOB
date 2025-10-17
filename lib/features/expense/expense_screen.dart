import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'models.dart';
import 'repository.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final ExpenseRepository _repo = ExpenseRepository();
  final DateFormat _fmt = DateFormat('dd MMM yyyy');
  List<ExpenseItem> _items = <ExpenseItem>[];
  String? _filterCategory;
  DateTimeRange? _filterRange;

  @override
  void initState() {
    super.initState();
    _repo.init().then((_) => setState(() => _items = _repo.getAll()));
  }

  Future<void> _addExpense() async {
    final ExpenseItem? item = await showDialog<ExpenseItem>(
      context: context,
      builder: (BuildContext context) => const _ExpenseDialog(),
    );
    if (item != null) {
      await _repo.addExpense(item);
      setState(() => _items = _repo.getAll());
    }
  }

  Iterable<ExpenseItem> get _filtered {
    return _items.where((ExpenseItem e) {
      if (_filterCategory != null && e.category != _filterCategory) return false;
      if (_filterRange != null) {
        if (e.date.isBefore(_filterRange!.start) || e.date.isAfter(_filterRange!.end)) return false;
      }
      return true;
    });
  }

  double get _total => _filtered.fold(0.0, (double s, ExpenseItem e) => s + e.amount);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            title: const Text('Expense Tracker'),
            actions: <Widget>[
              PopupMenuButton<String>(
                tooltip: 'Kategori',
                onSelected: (String v) => setState(() => _filterCategory = v == 'Semua' ? null : v),
                itemBuilder: (BuildContext _) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(value: 'Semua', child: Text('Semua')),
                  ...ExpenseCategory.all.map((String c) => PopupMenuItem<String>(value: c, child: Text(c))),
                ],
                icon: const Icon(Icons.filter_list),
              ),
              IconButton(
                tooltip: 'Rentang Tanggal',
                icon: const Icon(Icons.date_range),
                onPressed: () async {
                  final DateTime now = DateTime.now();
                  final DateTimeRange? range = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(now.year - 2),
                    lastDate: DateTime(now.year + 2),
                  );
                  if (range != null) setState(() => _filterRange = range);
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Total: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp').format(_total)}',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          SliverList.builder(
            itemCount: _filtered.length,
            itemBuilder: (BuildContext _, int index) {
              final ExpenseItem e = _filtered.elementAt(index);
              return Dismissible(
                key: ValueKey<String>(e.id),
                background: Container(color: Colors.red),
                onDismissed: (_) async {
                  await _repo.delete(e.id);
                  setState(() => _items = _repo.getAll());
                },
                child: ListTile(
                  leading: e.receiptPath != null && File(e.receiptPath!).existsSync()
                      ? Image.file(File(e.receiptPath!), width: 40, height: 40, fit: BoxFit.cover)
                      : const Icon(Icons.receipt),
                  title: Text('${e.category} • ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp').format(e.amount)}'),
                  subtitle: Text('${_fmt.format(e.date)}${e.note == null ? '' : ' • ${e.note}'}'),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExpense,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ExpenseDialog extends StatefulWidget {
  const _ExpenseDialog();

  @override
  State<_ExpenseDialog> createState() => _ExpenseDialogState();
}

class _ExpenseDialogState extends State<_ExpenseDialog> {
  final TextEditingController _amount = TextEditingController();
  final TextEditingController _note = TextEditingController();
  String _category = ExpenseCategory.other;
  DateTime _date = DateTime.now();
  String? _receiptPath;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Pengeluaran'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            DropdownButtonFormField<String>(
              value: _category,
              items: ExpenseCategory.all.map((String c) => DropdownMenuItem<String>(value: c, child: Text(c))).toList(),
              onChanged: (String? v) => setState(() => _category = v ?? ExpenseCategory.other),
              decoration: const InputDecoration(labelText: 'Kategori'),
            ),
            TextField(
              controller: _amount,
              decoration: const InputDecoration(labelText: 'Nominal'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            TextField(
              controller: _note,
              decoration: const InputDecoration(labelText: 'Catatan (opsional)'),
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Text(DateFormat('dd MMM yyyy').format(_date)),
                const Spacer(),
                TextButton(
                  onPressed: () async {
                    final DateTime? d = await showDatePicker(
                      context: context,
                      firstDate: DateTime(DateTime.now().year - 2),
                      lastDate: DateTime(DateTime.now().year + 2),
                    );
                    if (d != null) setState(() => _date = d);
                  },
                  child: const Text('Ubah Tanggal'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                ElevatedButton.icon(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? file = await picker.pickImage(source: ImageSource.camera);
                    if (file != null) setState(() => _receiptPath = file.path);
                  },
                  icon: const Icon(Icons.photo_camera),
                  label: const Text('Kamera'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
                    if (file != null) setState(() => _receiptPath = file.path);
                  },
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galeri'),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        FilledButton(
          onPressed: () {
            final double? amt = double.tryParse(_amount.text.replaceAll(',', '.'));
            if (amt == null || amt <= 0) return;
            final ExpenseItem item = ExpenseItem(
              id: const Uuid().v4(),
              date: _date,
              amount: amt,
              category: _category,
              note: _note.text.trim().isEmpty ? null : _note.text.trim(),
              receiptPath: _receiptPath,
            );
            Navigator.pop(context, item);
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}


