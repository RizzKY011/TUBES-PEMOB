import 'package:flutter/material.dart';

class BudgetCyclePicker extends StatelessWidget {
  const BudgetCyclePicker({super.key});

  static const List<String> _options = ['Daily', 'Weekly', 'Monthly', 'Quarterly', 'Yearly', 'Custom', 'One-Time'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
        title: const Text('Budget Cycle'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView.separated(
        itemCount: _options.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = _options[index];
          return ListTile(
            title: Text(item),
            onTap: () => Navigator.of(context).pop(item),
          );
        },
      ),
    );
  }
}
