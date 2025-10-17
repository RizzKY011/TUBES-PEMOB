import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// Loading animation simplified to avoid external assets
import '../expense/models.dart';
import '../expense/repository.dart';
import '../goals/models.dart';
import '../goals/repository.dart';
import '../budget/repository.dart';
import '../budget/models.dart';
import 'package:splatsplit/core/export/export_helper.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  final ExpenseRepository _expenseRepo = ExpenseRepository();
  final GoalsRepository _goalsRepo = GoalsRepository();
  final BudgetRepository _budgetRepo = BudgetRepository();
  List<ExpenseItem> _expenses = <ExpenseItem>[];
  List<GoalItem> _goals = <GoalItem>[];
  List<BudgetItem> _budgets = <BudgetItem>[];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait(<Future<void>>[
      _expenseRepo.init(),
      _goalsRepo.init(),
      _budgetRepo.init(),
    ]);
    
    setState(() {
      _expenses = _expenseRepo.getAll();
      _goals = _goalsRepo.getAll();
      _budgets = _budgetRepo.getAll();
      _isLoading = false;
    });
  }

  Map<String, double> _monthlyTotals() {
    final Map<String, double> m = <String, double>{};
    for (final ExpenseItem e in _expenses) {
      final String key = DateFormat('yyyy-MM').format(e.date);
      m[key] = (m[key] ?? 0) + e.amount;
    }
    return m;
  }

  List<BarChartGroupData> _barGroups() {
    final List<MapEntry<String, double>> data = _monthlyTotals().entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    int x = 0;
    return data.map((MapEntry<String, double> e) {
      return BarChartGroupData(x: x++, barRods: <BarChartRodData>[
        BarChartRodData(toY: e.value, width: 14, color: const Color(0xFF2196F3)),
      ], showingTooltipIndicators: const <int>[0]);
    }).toList();
  }

  List<String> _generateAIInsights() {
    final List<String> insights = <String>[];
    final Map<String, double> monthly = _monthlyTotals();
    final DateTime now = DateTime.now();
    final String currentMonth = DateFormat('yyyy-MM').format(now);
    final String lastMonth = DateFormat('yyyy-MM').format(DateTime(now.year, now.month - 1, 1));
    
    // Monthly comparison insight
    if (monthly.containsKey(currentMonth) && monthly.containsKey(lastMonth)) {
      final double current = monthly[currentMonth] ?? 0;
      final double previous = monthly[lastMonth] ?? 0;
      if (previous > 0) {
        final double change = ((current - previous) / previous) * 100;
        final String sign = change >= 0 ? 'naik' : 'turun';
        insights.add('💰 Pengeluaran bulan ini $sign ${change.abs().toStringAsFixed(1)}% dibanding bulan lalu');
      }
    }
    
    // Category insights
    final Map<String, double> categoryTotals = <String, double>{};
    for (final ExpenseItem expense in _expenses) {
      final String month = DateFormat('yyyy-MM').format(expense.date);
      if (month == currentMonth) {
        categoryTotals[expense.category] = (categoryTotals[expense.category] ?? 0) + expense.amount;
      }
    }
    
    if (categoryTotals.isNotEmpty) {
      final String topCategory = categoryTotals.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      final double topAmount = categoryTotals[topCategory] ?? 0;
      insights.add('📊 Kategori terbesar: $topCategory (Rp ${NumberFormat('#,###').format(topAmount)})');
    }
    
    // Budget insights
    for (final BudgetItem budget in _budgets) {
      final double spent = _budgetRepo.monthSpendForCategory(_expenses, budget.category, now);
      final double percentage = (spent / budget.monthlyLimit) * 100;
      if (percentage >= 80) {
        insights.add('⚠️ Budget $budget.category sudah ${percentage.toStringAsFixed(0)}% terpakai');
      }
    }
    
    // Goal insights
    for (final GoalItem goal in _goals) {
      final double progress = (goal.savedAmount / goal.targetAmount) * 100;
      if (progress >= 50) {
        insights.add('🎯 Goal "${goal.name}" sudah ${progress.toStringAsFixed(0)}% tercapai');
      }
    }
    
    if (insights.isEmpty) {
      insights.add('📈 Tambahkan lebih banyak data untuk insight yang lebih akurat');
    }
    
    return insights;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: CustomScrollView(
          slivers: <Widget>[
            const SliverAppBar(
              pinned: true,
              title: Text('MONAS Insights'),
            ),
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(width: 40, height: 40, child: CircularProgressIndicator()),
                    SizedBox(height: 12),
                    Text('Analyzing your financial data...'),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    final List<String> insights = _generateAIInsights();
    
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            title: const Text('MONAS Insights'),
            backgroundColor: Theme.of(context).colorScheme.surface,
            foregroundColor: Theme.of(context).colorScheme.primary,
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (String value) async {
                  switch (value) {
                    case 'export_csv':
                      await ExportHelper.exportToCSV(
                        expenses: _expenses,
                        goals: _goals,
                        budgets: _budgets,
                      );
                      break;
                    case 'export_excel':
                      await ExportHelper.exportToExcel(
                        expenses: _expenses,
                        goals: _goals,
                        budgets: _budgets,
                      );
                      break;
                    case 'export_sheets':
                      await ExportHelper.exportToGoogleSheets(
                        expenses: _expenses,
                        goals: _goals,
                        budgets: _budgets,
                      );
                      break;
                    case 'refresh':
                      _loadData();
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'export_csv',
                    child: ListTile(
                      leading: Icon(Icons.file_download),
                      title: Text('Export CSV'),
                      dense: true,
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'export_excel',
                    child: ListTile(
                      leading: Icon(Icons.table_chart),
                      title: Text('Export Excel'),
                      dense: true,
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'export_sheets',
                    child: ListTile(
                      leading: Icon(Icons.cloud_upload),
                      title: Text('Export Google Sheets'),
                      dense: true,
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'refresh',
                    child: ListTile(
                      leading: Icon(Icons.refresh),
                      title: Text('Refresh Data'),
                      dense: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // AI Insights Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.psychology, color: Theme.of(context).colorScheme.primary),
                              const SizedBox(width: 8),
                              Text(
                                'Smart Insights',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ...insights.map((String insight) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    insight,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Gamification Badges
                  Text(
                    'Achievements',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const <Widget>[
                      Chip(
                        label: Text('🏆 First Split'),
                        backgroundColor: Color(0xFFF5D3C4),
                      ),
                      Chip(
                        label: Text('💎 7 Days Saving'),
                        backgroundColor: Color(0xFFF2AEBB),
                      ),
                      Chip(
                        label: Text('📊 Budget Master'),
                        backgroundColor: Color(0xFFA7AAE1),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Cash Flow Chart
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cash Flow',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 220,
                            child: BarChart(
                              BarChartData(
                                barGroups: _barGroups(),
                                titlesData: FlTitlesData(
                                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true)),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (double value, TitleMeta meta) {
                                        final int idx = value.toInt();
                                        final List<String> keys = _monthlyTotals().keys.toList()..sort();
                                        if (idx < 0 || idx >= keys.length) return const SizedBox.shrink();
                                        return SideTitleWidget(
                                          axisSide: meta.axisSide,
                                          space: 6,
                                          child: Text(keys[idx].substring(5)),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                gridData: const FlGridData(show: false),
                                borderData: FlBorderData(show: false),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Goals Section
                  Text(
                    'Your Goals',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._goals.map((GoalItem g) {
                    final double progress = (g.savedAmount / g.targetAmount).clamp(0, 1);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          child: Icon(Icons.flag, color: Theme.of(context).colorScheme.primary),
                        ),
                        title: Text(g.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Target: Rp ${NumberFormat('#,###').format(g.targetAmount)}'),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                            ),
                            const SizedBox(height: 4),
                            Text('${(progress * 100).toStringAsFixed(0)}% • Rp ${NumberFormat('#,###').format(g.savedAmount)}'),
                          ],
                        ),
                      ),
                    );
                  }),
                  
                  if (_goals.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(
                              Icons.flag_outlined,
                              size: 48,
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No goals yet',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Create your first savings goal',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final GoalItem? g = await showDialog<GoalItem>(
            context: context,
            builder: (BuildContext context) => const _GoalDialog(),
          );
          if (g != null) {
            await _goalsRepo.upsert(g);
            setState(() => _goals = _goalsRepo.getAll());
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('New Goal'),
      ),
    );
  }
}

class _GoalDialog extends StatefulWidget {
  const _GoalDialog();

  @override
  State<_GoalDialog> createState() => _GoalDialogState();
}

class _GoalDialogState extends State<_GoalDialog> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _target = TextEditingController();
  final TextEditingController _saved = TextEditingController(text: '0');
  DateTime _date = DateTime.now().add(const Duration(days: 180));
  String _freq = 'monthly';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Create New Goal',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              decoration: const InputDecoration(labelText: 'Goal Name'),
              controller: _name,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Target Amount (Rp)'),
              controller: _target,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Already Saved (Rp)'),
              controller: _saved,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Text('Target Date: ${DateFormat('dd MMM yyyy').format(_date)}'),
                const Spacer(),
                TextButton(
                  onPressed: () async {
                    final DateTime? d = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(DateTime.now().year + 5),
                      initialDate: _date,
                    );
                    if (d != null) setState(() => _date = d);
                  },
                  child: const Text('Change'),
                )
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _freq,
              items: const <DropdownMenuItem<String>>[
                DropdownMenuItem<String>(value: 'weekly', child: Text('Weekly')),
                DropdownMenuItem<String>(value: 'monthly', child: Text('Monthly')),
              ],
              onChanged: (String? v) => setState(() => _freq = v ?? 'monthly'),
              decoration: const InputDecoration(labelText: 'Savings Frequency'),
            ),
            const SizedBox(height: 16),
            // Smart calculation preview
            if (_target.text.isNotEmpty && _saved.text.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Smart Calculation:',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _calculateSmartSuggestion(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final double? t = double.tryParse(_target.text.replaceAll(',', '.'));
            final double? s = double.tryParse(_saved.text.replaceAll(',', '.'));
            if (t == null || t <= 0 || s == null || s < 0) return;
            final GoalItem g = GoalItem(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              name: _name.text.trim().isEmpty ? 'New Goal' : _name.text.trim(),
              targetAmount: t,
              targetDate: _date,
              savedAmount: s,
              frequency: _freq,
            );
            Navigator.pop(context, g);
          },
          child: const Text('Create Goal'),
        )
      ],
    );
  }

  String _calculateSmartSuggestion() {
    final double? target = double.tryParse(_target.text.replaceAll(',', '.'));
    final double? saved = double.tryParse(_saved.text.replaceAll(',', '.'));
    
    if (target == null || saved == null || target <= 0) return '';
    
    final double remaining = target - saved;
    final int daysUntilTarget = _date.difference(DateTime.now()).inDays;
    
    if (daysUntilTarget <= 0) return 'Target date has passed';
    
    final double dailyAmount = remaining / daysUntilTarget;
    final double weeklyAmount = dailyAmount * 7;
    final double monthlyAmount = dailyAmount * 30;
    
    if (_freq == 'weekly') {
      return 'Save Rp ${NumberFormat('#,###').format(weeklyAmount.round())} per week';
    } else {
      return 'Save Rp ${NumberFormat('#,###').format(monthlyAmount.round())} per month';
    }
  }
}

