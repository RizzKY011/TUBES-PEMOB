import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BudgetCategoryScreen extends StatelessWidget {
  final String budgetName;
  final int totalBudget;
  final List<Map<String, dynamic>> categories;

  const BudgetCategoryScreen({
    super.key,
    required this.budgetName,
    required this.categories,
    required this.totalBudget,
  });

  void _goBackToHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _navigateToBudgetPlanner(BuildContext context) {
    // Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BudgetPlannerScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final NumberFormat moneyFormatter =
        NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);

    final displayCategories = categories.map((c) {
      final budgetedAmount = c['amount'] as int;
      final spentAmount = budgetedAmount > 0 ? budgetedAmount ~/ 2 : 0;
      return {...c, 'spent': spentAmount};
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _goBackToHome(context),
        ),
        title: Text(budgetName, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFFF0E5FF),
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          Container(
            height: 200,
            decoration: const BoxDecoration(
              color: Color(0xFFF0E5FF),
            ),
          ),
          ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const SizedBox(height: 16),
              Center(
                  child: Column(
                children: [
                  const Text('Your Total Budget:', style: TextStyle(color: Colors.black54)),
                  const SizedBox(height: 4),
                  Text(moneyFormatter.format(totalBudget),
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                ],
              )),
              const SizedBox(height: 20),
              const Text('Expenses', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 0.8,
                ),
                itemCount: displayCategories.length,
                itemBuilder: (context, index) {
                  final category = displayCategories[index];
                  final title = category['title'] as String;
                  final budgetedAmount = category['amount'] as int;
                  final spentAmount = category['spent'] as int;
                  final remainingAmount = budgetedAmount - spentAmount;
                  final percentageSpent =
                      budgetedAmount > 0 ? (spentAmount / budgetedAmount) * 100 : 0;
                  final remainingPercentage = (100 - percentageSpent).round();
                  final progressValue = budgetedAmount > 0 ? spentAmount / budgetedAmount : 0.0;

                  return _CategoryCard(
                    title: title,
                    budgeted: budgetedAmount,
                    remaining: remainingAmount,
                    percentage: remainingPercentage,
                    formatter: moneyFormatter,
                    progressValue: progressValue,
                  );
                },
              ),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              onPressed: () => _navigateToBudgetPlanner(context),
              backgroundColor: const Color(0xFF5A44AA),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final int budgeted;
  final int remaining;
  final int percentage;
  final NumberFormat formatter;
  final double progressValue;

  const _CategoryCard({
    required this.title,
    required this.budgeted,
    required this.remaining,
    required this.percentage,
    required this.formatter,
    required this.progressValue,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Text('Per month/day', style: TextStyle(color: Colors.black54, fontSize: 12)),
            const Spacer(),
            Center(
              child: SizedBox(
                height: 80,
                width: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progressValue,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF5A44AA)),
                    ),
                    Text('$percentage%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Text(formatter.format(remaining),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text('left out of ${formatter.format(budgeted)}',
                style: const TextStyle(color: Colors.black45, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
