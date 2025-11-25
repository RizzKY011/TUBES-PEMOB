import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'budget_cycle_picker.dart';
import 'budget_allocate_screen.dart';

const Color _kPurpleBackground = Color(0xFF6B4BD6);
const Color _kPurpleLight = Color(0xFFEEEAFF);

class BudgetPlannerScreen extends StatefulWidget {
  const BudgetPlannerScreen({super.key});

  @override
  State<BudgetPlannerScreen> createState() => _BudgetPlannerScreenState();
}

class _BudgetPlannerScreenState extends State<BudgetPlannerScreen> {
  final TextEditingController _nameController =
      TextEditingController(text: 'Daily');

  String _cycle = 'Monthly';
  bool _reuseBudget = false;
  String _hierarchy = 'Category Budget';
  bool _autoRollover = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickCycle() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BudgetCyclePicker()),
    );
    if (result is String) setState(() => _cycle = result);
  }

  Future<void> _pickHierarchy() async {
    final List<String> options = [
      'Category Budget',
      'Priority Budget',
      'Envelope Budget',
      'Zero-Based Budget',
    ];

    final selected = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: options.map((item) {
            return ListTile(
              title: Text(item),
              trailing: item == _hierarchy
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
              onTap: () => Navigator.pop(context, item),
            );
          }).toList(),
        );
      },
    );

    if (selected != null) {
      setState(() => _hierarchy = selected);
    }
  }

  void _next() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BudgetAllocateScreen(
          name: _nameController.text.trim(),
          cycle: _cycle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close)),
                  const Spacer(),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Illustration + Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: _kPurpleLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                        child: Text('Illustration',
                            style: TextStyle(color: Colors.black45))),
                  ),
                  const SizedBox(height: 12),
                  const Text('Set Budget',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            const SizedBox(height: 18),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListView(
                  children: [
                    const SizedBox(height: 6),

                    // Name
                    _buildTile(
                      child: TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Name',
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Cycle
                    GestureDetector(
                      onTap: _pickCycle,
                      child: _buildTile(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Budget Cycle',
                                style: TextStyle(color: Colors.black54)),
                            Text(_cycle),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Reuse Budget
                    _buildTile(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Reuse Budget'),
                          Switch(
                              value: _reuseBudget,
                              onChanged: (v) =>
                                  setState(() => _reuseBudget = v)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Budget Hierarchy
                    GestureDetector(
                      onTap: _pickHierarchy,
                      child: _buildTile(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Budget Hierarchy',
                                style: TextStyle(color: Colors.black54)),
                            Text(_hierarchy),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Auto Rollover
                    _buildTile(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Auto Rollover Budget',
                              style: TextStyle(color: Colors.black54)),
                          Switch(
                            value: _autoRollover,
                            onChanged: (v) => setState(() => _autoRollover = v),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Next Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF7D657),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        onPressed: _next,
                        child: const Text('Next',
                            style:
                                TextStyle(color: Colors.black, fontSize: 16)),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: child,
    );
  }
}
