import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'budget_summary_screen.dart';

class BudgetAllocateScreen extends StatefulWidget {
  final String name;
  final String cycle;
  const BudgetAllocateScreen({super.key, required this.name, required this.cycle});

  @override
  State<BudgetAllocateScreen> createState() => _BudgetAllocateScreenState();
}

class _BudgetAllocateScreenState extends State<BudgetAllocateScreen> {
  final NumberFormat _money = NumberFormat.currency(locale: 'id', symbol: 'Rp');

  final List<_Category> _categories = [
    _Category('Food & Drink', 0),
    _Category('Transport', 0),
    _Category('Home Bills', 0),
    _Category('Self-Care', 0),
    _Category('Shopping', 0),
    _Category('Health', 0),
  ];

  bool _autoCalculation = true;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _recalcTotal();
  }

  void _recalcTotal() {
    if (_autoCalculation) {
      _total = _categories.fold(0, (p, e) => p + e.amount);
    }
  }

  Future<void> _editCategoryAmount(int idx) async {
    final current = _categories[idx].amount;
    final res = await showDialog<int?>(
      context: context,
      builder: (ctx) {
        final ctrl = TextEditingController(text: current.toString());
        return AlertDialog(
          title: Text('Set amount for ${_categories[idx].title}'),
          content: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Amount'),
            onTap: () {
              if (ctrl.text == '0') ctrl.clear();
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final value = int.tryParse(ctrl.text) ?? current;
                Navigator.of(ctx).pop(value);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (res != null) {
      setState(() {
        _categories[idx].amount = res;
        _recalcTotal();
      });
    }
  }

  void _confirm() {
    final List<Map<String, dynamic>> categoriesList = _categories
        .map((c) => {'title': c.title, 'amount': c.amount}).toList();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => BudgetSummaryScreen(
          name: widget.name,
          cycle: widget.cycle,
          total: _total,
          categories: categoriesList,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(widget.cycle, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const CircleAvatar(radius: 28, backgroundColor: Color(0xFFFBF5DE), child: Icon(Icons.pie_chart, color: Colors.orange)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dinamis sesuai cycle yang dipilih
                    Text(widget.cycle, style: const TextStyle(color: Colors.black54)),
                    Text(_money.format(_total), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final c = _categories[index];
                return ListTile(
                  onTap: () => _editCategoryAmount(index),
                  leading: CircleAvatar(backgroundColor: Colors.grey.shade100, child: const Icon(Icons.circle, color: Colors.grey)),
                  title: Text(c.title),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(18)
                    ),
                    child: Text(_money.format(c.amount)),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Auto Calculation'),
                      Switch(
                        value: _autoCalculation,
                        onChanged: (v) {
                          setState(() {
                            _autoCalculation = v;
                            _recalcTotal(); // recalculasi otomatis hanya jika on
                          });
                        },
                      )
                    ]
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF7D657),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))
                    ),
                    onPressed: _confirm,
                    child: const Text('Confirm', style: TextStyle(color: Colors.black, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 18),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _Category {
  final String title;
  int amount;
  _Category(this.title, this.amount);
}
