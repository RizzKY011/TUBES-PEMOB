import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../split/split_screen.dart';
import '../debt/debt_screen.dart';
import '../expense/expense_screen.dart';
import '../budget/budget_screen.dart';
import '../budget/repository.dart';
import '../expense/repository.dart';
import '../budget/models.dart';
import '../expense/models.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class MonasApp extends StatelessWidget {
  final String initialRoute;
  const MonasApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MONAS',
      initialRoute: initialRoute,
      routes: {
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}


class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _hideTotal = false;
  bool _hideRecords = false;

  final BudgetRepository _budgetRepo = BudgetRepository();
  final ExpenseRepository _expenseRepo = ExpenseRepository();

  double _totalIncome = 0.0;
  double _totalOutcome = 0.0;
  double _monthIncome = 0.0;
  double _monthOutcome = 0.0;

  @override
  void initState() {
    super.initState();
    _loadFinancialData();
  }

  Future<void> _loadFinancialData() async {
    await _budgetRepo.init();
    await _expenseRepo.init();

    final List<BudgetItem> budgets = _budgetRepo.getAll();
    final List<ExpenseItem> expenses = _expenseRepo.getAll();

    final DateTime now = DateTime.now();

    // Total income dan outcome
_totalIncome = budgets.fold(0.0, (sum, item) => sum + item.monthlyLimit);
_totalOutcome = expenses.fold(0.0, (sum, item) => sum + item.amount); // expenseItem nanti tetap pakai amount

// Bulan ini
_monthIncome = budgets
    .where((b) => b.createdAt.month == now.month && b.createdAt.year == now.year)
    .fold(0.0, (sum, item) => sum + item.monthlyLimit);
_monthOutcome = expenses
    .where((e) => e.date.month == now.month && e.date.year == now.year)
    .fold(0.0, (sum, item) => sum + item.amount);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // === HEADER SECTION ===
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 48, left: 20, right: 20, bottom: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF696FC7), Color(0xFFA7AAE1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row atas: Welcome + notif + profil
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Welcome,',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                          SizedBox(height: 4),
                          Text('Lisa!',
                              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
                        ],
                      ),
                      Row(
                        children: const [
                          Icon(Icons.notifications, color: Colors.white, size: 24),
                          SizedBox(width: 12),
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white24,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Total
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('Total', style: TextStyle(fontWeight: FontWeight.w600)),
                            const Spacer(),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: Icon(
                                _hideTotal ? Icons.visibility_off : Icons.visibility,
                                size: 18,
                              ),
                              onPressed: () => setState(() => _hideTotal = !_hideTotal),
                            )
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _hideTotal
                              ? '••••••••••'
                              : NumberFormat.currency(locale: 'id_ID', symbol: 'Rp')
                                  .format(_totalIncome - _totalOutcome),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Badge
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDEADE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: const [
                        Icon(Icons.emoji_events, size: 18, color: Colors.brown),
                        SizedBox(width: 8),
                        Expanded(
                            child: Text(
                                'Hemat Champion!  Kamu hemat 7 hari berturut-turut.',
                                style: TextStyle(fontSize: 12))),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // === SEARCH BAR ===
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Find feature',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: const Color(0xFFF7D8DD),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // === FEATURE GRID 2x3 ===
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _featureTile(Icons.account_balance_wallet, 'Budget Planner'),
                  _featureTile(Icons.handshake, 'Debt & Loan Tracker'),
                  _featureTile(Icons.wallet, 'Expense Tracker'),
                  _featureTile(Icons.receipt_long, 'Split Bill'),
                  _featureTile(Icons.savings, 'Goal Saving'),
                  _featureTile(Icons.insights, 'Insights'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // === RECORDS SUMMARY ===
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Records', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('October - November',
                              style: TextStyle(fontSize: 12, color: Colors.black54)),
                          InkWell(
                            onTap: () => setState(() => _hideRecords = !_hideRecords),
                            child: Row(
                              children: [
                                const Text('Show ', style: TextStyle(fontSize: 12)),
                                Icon(
                                  _hideRecords ? Icons.visibility_off : Icons.visibility,
                                  size: 14,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Income - Outcome horizontal
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: _summaryBox(
                              title: 'Income',
                              value: _hideRecords
                                  ? '•••••••••'
                                  : '+${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp').format(_monthIncome)}',
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _summaryBox(
                              title: 'Outcome',
                              value: _hideRecords
                                  ? '•••••••••'
                                  : '-${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp').format(_monthOutcome)}',
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      SizedBox(height: 120, child: _miniLineChart()),
                      const SizedBox(height: 8),
                      Text(
                        'Remainder ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp').format(_monthIncome - _monthOutcome)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF696FC7),
        onPressed: () {},
        child: const Icon(Icons.shopping_bag),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Invoice'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  // === Widgets ===

  Widget _featureTile(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 4)),
            ],
          ),
          child: Icon(icon, color: AppTheme.primary),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 10), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _summaryBox({required String title, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _miniLineChart() {
    final spots = [
      const FlSpot(0, 1),
      const FlSpot(1, 2.5),
      const FlSpot(2, 2),
      const FlSpot(3, 3),
      const FlSpot(4, 2.5),
      const FlSpot(5, 3),
      const FlSpot(6, 2.2),
    ];

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: AppTheme.primary,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            spots: spots,
          ),
        ],
      ),
    );
  }
}
