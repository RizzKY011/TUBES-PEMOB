import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'models.dart';
import 'repository.dart';

class DebtScreen extends StatefulWidget {
  const DebtScreen({super.key});

  @override
  State<DebtScreen> createState() => _DebtScreenState();
}

class _DebtScreenState extends State<DebtScreen> {
  final DebtRepository _repo = DebtRepository();
  final NumberFormat _currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');
  List<DebtItem> _items = <DebtItem>[];

  @override
  void initState() {
    super.initState();
    _repo.init().then((_) => setState(() => _items = _repo.getAll()));
  }

  Future<void> _addDebt() async {
    final DebtItem? item = await showDialog<DebtItem>(
      context: context,
      builder: (BuildContext context) => const _DebtDialog(),
    );
    if (item != null) {
      await _repo.add(item);
      setState(() => _items = _repo.getAll());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          const SliverAppBar(
            pinned: true,
            title: Text('Debt & Loans'),
          ),
          SliverList.builder(
            itemCount: _items.length,
            itemBuilder: (BuildContext _, int index) {
              final DebtItem d = _items[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  title: Text('${d.fromName} ➜ ${d.toName}'),
                  subtitle: Text('${_currency.format(d.amount)} • ${DateFormat('dd MMM yyyy').format(d.createdAt)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        tooltip: d.settled ? 'Sudah Lunas' : 'Tandai Lunas',
                        icon: Icon(d.settled ? Icons.check_circle : Icons.check_circle_outline, color: d.settled ? Colors.green : null),
                        onPressed: () async {
                          final DebtItem updated = d.copyWith(settled: !d.settled);
                          await _repo.update(updated);
                          setState(() => _items = _repo.getAll());
                        },
                      ),
                      IconButton(
                        tooltip: 'Hapus',
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await _repo.delete(d.id);
                          setState(() => _items = _repo.getAll());
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addDebt,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _DebtDialog extends StatefulWidget {
  const _DebtDialog();

  @override
  State<_DebtDialog> createState() => _DebtDialogState();
}

class _DebtDialogState extends State<_DebtDialog> {
  final TextEditingController _from = TextEditingController();
  final TextEditingController _to = TextEditingController();
  final TextEditingController _amount = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Utang/Piutang'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: _from,
            decoration: const InputDecoration(labelText: 'Dari (yang berhutang)'),
          ),
          TextField(
            controller: _to,
            decoration: const InputDecoration(labelText: 'Ke (yang menerima)'),
          ),
          TextField(
            controller: _amount,
            decoration: const InputDecoration(labelText: 'Nominal'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        FilledButton(
          onPressed: () {
            final double? amt = double.tryParse(_amount.text.replaceAll(',', '.'));
            if (amt == null || amt <= 0) return;
            final DebtItem item = DebtItem(
              id: const Uuid().v4(),
              fromName: _from.text.trim().isEmpty ? 'A' : _from.text.trim(),
              toName: _to.text.trim().isEmpty ? 'B' : _to.text.trim(),
              amount: amt,
              createdAt: DateTime.now(),
            );
            Navigator.pop(context, item);
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}


