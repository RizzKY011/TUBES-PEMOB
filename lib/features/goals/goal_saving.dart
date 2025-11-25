import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'goal_add.dart';
import 'goal_progress.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Goal Saving App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const GoalSavingScreen(),
    );
  }
}

class GoalSavingScreen extends StatefulWidget {
  const GoalSavingScreen({super.key});

  @override
  State<GoalSavingScreen> createState() => _GoalSavingScreenState();
}

class _GoalSavingScreenState extends State<GoalSavingScreen> {
  bool _hideTotalSaved = false;

  final List<Map<String, dynamic>> _goalSavings = [
    {
      'name': 'A big beach house',
      'current': 110274.0,
      'goal': 2800000.0,
      'endsInDays': 1078,
      'icon': Icons.house_outlined,
      'iconColor': Colors.amber,
    },
    {
      'name': 'Trip to Hawaii',
      'current': 11568.0,
      'goal': 50000.0,
      'endsInDays': null,
      'icon': Icons.airplane_ticket_outlined,
      'iconColor': Colors.lightBlue,
    },
    {
      'name': 'A new car',
      'current': 36888.0,
      'goal': 300000.0,
      'endsInDays': null,
      'icon': Icons.directions_car_outlined,
      'iconColor': Colors.green,
    },
    {
      'name': 'Special money',
      'current': 9554.0,
      'goal': 50000.0,
      'endsInDays': null,
      'icon': Icons.monetization_on_outlined,
      'iconColor': Colors.amber,
    },
    {
      'name': 'Trip to LA',
      'current': 1554.0,
      'goal': 20000.0,
      'endsInDays': 135,
      'icon': Icons.airplane_ticket_outlined,
      'iconColor': Colors.lightBlue,
    },
    {
      'name': 'Test Goal',
      'current': 0.0,
      'goal': 2000000.0,
      'endsInDays': 12,
      'icon': Icons.arrow_upward,
      'iconColor': Colors.amber,
    },
  ];

  void _navigateToCreateGoal() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateSavingGoalScreen(
          onGoalCreated: (newGoal) {
            setState(() {
              _goalSavings.add({
                'name': newGoal.name,
                'current': 0.0,
                'goal': newGoal.goalAmount,
                'endsInDays': newGoal.endsInDays,
                'icon': newGoal.icon,
                'iconColor': newGoal.color,
              });
            });
          },
        ),
      ),
    );
  }

  void _navigateToProgressScreen(Map<String, dynamic> goal) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GoalProgressScreen(
          goalName: goal['name'],
          initialCurrentAmount: goal['current'],
          goalAmount: goal['goal'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double totalSavedAmount =
        _goalSavings.fold(0.0, (sum, item) => sum + (item['current'] as double));
    final NumberFormat moneyFormatter =
        NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF696FC7),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF696FC7), Color(0xFFA7AAE1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 48.0, left: 16.0, right: 16.0, bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.add, color: Colors.white),
                            onPressed: _navigateToCreateGoal,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Column(
                          children: [
                            const Text(
                              'Total Saved',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  _hideTotalSaved
                                      ? '••••••••••'
                                      : moneyFormatter.format(totalSavedAmount),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(
                                    _hideTotalSaved
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _hideTotalSaved = !_hideTotalSaved;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final goal = _goalSavings[index];
                final String name = goal['name'];
                final double current = goal['current'];
                final double goalAmount = goal['goal'];
                final int? endsInDays = goal['endsInDays'];
                final IconData icon = goal['icon'];
                final Color iconColor = goal['iconColor'];

                final double progress =
                    goalAmount > 0 ? (current / goalAmount).clamp(0.0, 1.0) : 0.0;

                return GestureDetector(
                  onTap: () => _navigateToProgressScreen(goal),
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: iconColor.withOpacity(0.1),
                                child: Icon(icon, color: iconColor, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16),
                                    ),
                                    if (endsInDays != null)
                                      Text(
                                        'Ends in $endsInDays days',
                                        style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12),
                                      ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    moneyFormatter.format(current),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  Text(
                                    'Goal: ${moneyFormatter.format(goalAmount)}',
                                    style: TextStyle(
                                        color: Colors.grey[600], fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey[200],
                            color: iconColor,
                            minHeight: 4,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              childCount: _goalSavings.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
