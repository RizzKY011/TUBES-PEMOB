import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'budget_category_screen.dart';

class BudgetSummaryScreen extends StatefulWidget {
  final String name;
  final String cycle;
  final int total;
  final List<Map<String, dynamic>> categories; // {title, amount}

  const BudgetSummaryScreen({super.key, required this.name, required this.cycle, required this.total, required this.categories});

  @override
  State<BudgetSummaryScreen> createState() => _BudgetSummaryScreenState();
}

class _BudgetSummaryScreenState extends State<BudgetSummaryScreen> {
  DateTime _current = DateTime.now();
  final NumberFormat _money = NumberFormat.currency(locale: 'id', symbol: 'Rp');

  void _pickMonth() async {
    final result = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (ctx) {
        DateTime temp = _current;
        return SizedBox(
          height: 320,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(ctx).pop()),
                    Row(children: [
                      IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => setState(() => temp = DateTime(temp.year - 1, temp.month))), // Perbaikan: Gunakan setState dalam bottom sheet
                      Text('${temp.year}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(icon: const Icon(Icons.chevron_right), onPressed: () => setState(() => temp = DateTime(temp.year + 1, temp.month))), // Perbaikan: Gunakan setState dalam bottom sheet
                    ]),
                    IconButton(icon: const Icon(Icons.check), onPressed: () => Navigator.of(ctx).pop(temp)),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    children: List.generate(12, (i) {
                      final m = i + 1;
                      final isSelected = _current.month == m && _current.year == temp.year;
                      return GestureDetector(
                        onTap: () { 
                          // Perbaikan: Pop dengan tanggal yang dipilih, bukan hanya set temp
                          Navigator.of(ctx).pop(DateTime(temp.year, m)); 
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.yellow.shade200 : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(child: Text(DateFormat('MMM').format(DateTime(0, m)))),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (result != null) setState(() => _current = result);
  }

  // Fungsi baru untuk menghitung budget per hari
  int _calculatePerDay() {
    if (widget.total <= 0) return 0;

    int days = 0;
    switch (widget.cycle) {
      case 'Daily':
        days = 1;
        break;
      case 'Weekly':
        days = 7;
        break;
      case 'Monthly':
        days = _daysInMonth(_current);
        break;
      case 'Quarterly':
        // Rata-rata 365.25 / 4 / 3 = 30.4375 hari per bulan, jadi 91.31 hari per kuartal.
        // Untuk penyederhanaan, kita bisa pakai 90 hari atau 3 * _daysInMonth() jika periode dimulai sekarang
        days = 90; 
        break;
      case 'Yearly':
        days = 365; // Atau _current.year % 4 == 0 ? 366 : 365
        break;
      case 'Custom':
        // Asumsi Custom adalah 30 hari sebagai nilai default jika tidak ada info durasi
        days = 30; 
        break;
      case 'One-Time':
        days = 1; // Untuk One-Time, anggap semua dialokasikan untuk 1 hari (walaupun kurang relevan)
        break;
      default:
        days = _daysInMonth(_current); // Default ke Monthly
    }

    // Menggunakan Math.round() untuk pembulatan
    return (widget.total / days).round();
  }

  // Fungsi navigasi ke BudgetCategoryScreen
  void _navigateToCategorySummary() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => BudgetCategoryScreen(
          budgetName: widget.name,
          categories: widget.categories,
          totalBudget: widget.total,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final perDay = _calculatePerDay(); // Panggil fungsi baru

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
        title: Text(widget.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          // Mengganti ikon edit menjadi centang (check)
          IconButton(icon: const Icon(Icons.check), onPressed: _navigateToCategorySummary),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.cycle, style: const TextStyle(color: Colors.black54)),
                            const SizedBox(height: 6),
                            Text(_money.format(widget.total), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Text('~${_money.format(perDay)} per day', style: const TextStyle(color: Colors.black38)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: _pickMonth,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
                          child: Text('${DateFormat('MMM yyyy').format(_current)}'),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  // List Kategori di Summary Screen
                  Column(
                    children: widget.categories.map((c) {
                      final amt = (c['amount'] as int);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: ListTile(
                          tileColor: Colors.grey.shade50,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          title: Text(c['title']),
                          trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(18)), child: Text(amt > 0 ? _money.format(amt) : 'None')),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _daysInMonth(DateTime d) {
    final first = DateTime(d.year, d.month, 1);
    final next = DateTime(d.year, d.month + 1, 1);
    return next.difference(first).inDays;
  }
}