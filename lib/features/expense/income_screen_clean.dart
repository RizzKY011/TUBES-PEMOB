import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'expense_screen.dart';
import 'settings_screen.dart';

// Warna sama seperti Expense
const Color _kPurpleBackground = Color(0xFF6B4BD6);
const Color _kPurpleLight = Color(0xFFEEEAFF);
const Color _kWhiteBackground = Colors.white;

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

// --- Calculator keyboard widget ---
class CalculatorKeyboard extends StatelessWidget {
  final String expression;
  final void Function(String) onKey;
  final VoidCallback onClear;
  final VoidCallback onBackspace;
  final VoidCallback onConfirm;
  final VoidCallback onToday;

  const CalculatorKeyboard({
    super.key,
    required this.expression,
    required this.onKey,
    required this.onClear,
    required this.onBackspace,
    required this.onConfirm,
    required this.onToday,
  });

  Widget _buildKey(String label,
      {Color? color,
      required double fontSize,
      required FontWeight fontWeight,
      void Function()? onTap,
      IconData? icon}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: AspectRatio(
          aspectRatio: 1.25,
          child: GestureDetector(
            onTap: onTap ?? () => onKey(label),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: color != null ? Border.all(color: color, width: 2) : null,
              ),
              child: Center(
                child: icon != null
                    ? Icon(icon, color: color ?? Colors.black, size: 28)
                    : Text(label,
                        style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: fontWeight,
                            color: color ?? Colors.black)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kPurpleBackground,
      child: Column(
        children: [
          Row(children: [
            _buildKey('TODAY',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                onTap: onToday),
            _buildKey('+',
                fontSize: 28,
                fontWeight: FontWeight.w400,
                color: Colors.green,
                onTap: () => onKey('+')),
            _buildKey('✓',
                icon: Icons.check,
                color: Colors.teal,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                onTap: onConfirm),
          ]),

          Row(children: [
            _buildKey('×',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                onTap: () => onKey('×')),
            _buildKey('7', fontSize: 28, fontWeight: FontWeight.w600),
            _buildKey('8', fontSize: 28, fontWeight: FontWeight.w600),
            _buildKey('9', fontSize: 28, fontWeight: FontWeight.w600),
          ]),

          Row(children: [
            _buildKey('÷',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                onTap: () => onKey('÷')),
            _buildKey('4', fontSize: 28, fontWeight: FontWeight.w600),
            _buildKey('5', fontSize: 28, fontWeight: FontWeight.w600),
            _buildKey('6', fontSize: 28, fontWeight: FontWeight.w600),
          ]),

          Row(children: [
            _buildKey('-',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                onTap: () => onKey('-')),
            _buildKey('1', fontSize: 28, fontWeight: FontWeight.w600),
            _buildKey('2', fontSize: 28, fontWeight: FontWeight.w600),
            _buildKey('3', fontSize: 28, fontWeight: FontWeight.w600),
          ]),

          Row(children: [
            _buildKey('+',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                onTap: () => onKey('+')),
            _buildKey('.', fontSize: 28, fontWeight: FontWeight.w600),
            _buildKey('0', fontSize: 28, fontWeight: FontWeight.w600),
            _buildKey('X',
                icon: Icons.close,
                color: Colors.red,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                onTap: onBackspace),
          ]),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------
// Income Screen (mirip Expense, hanya beda kategori & header)
// ---------------------------------------------------------------
class _IncomeScreenState extends State<IncomeScreen> {
  // Kategori Income
  final List<String> labels = [
    'Salary',
    'Bonus',
    'Gift',
    'Business',
    'Investment',
    'Freelance',
    'Savings',
    'Refund',
  ];

  final List<IconData> icons = [
    Icons.work,
    Icons.monetization_on,
    Icons.card_giftcard,
    Icons.store,
    Icons.trending_up,
    Icons.edit,
    Icons.savings,
    Icons.refresh,
  ];

  int _selectedIndex = 0;

  final TextEditingController _noteController = TextEditingController();
  String _calcExpression = '';
  String _displayAmount = '0';
  bool _showKeyboard = true;

  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _onCalcKey(String key) {
    setState(() {
      _calcExpression += key;
      _displayAmount = _calcExpression;
    });
  }

  void _onCalcBackspace() {
    setState(() {
      if (_calcExpression.isNotEmpty) {
        _calcExpression = _calcExpression.substring(0, _calcExpression.length - 1);
      }
      _displayAmount = _calcExpression.isEmpty ? '0' : _calcExpression;
    });
  }

  void _onCalcClear() {
    setState(() {
      _calcExpression = '';
      _displayAmount = '0';
    });
  }

  void _onCalcConfirm() {
    setState(() {
      _showKeyboard = false;
    });
  }

  Future<void> _pickDate() async {
    DateTime temp = _selectedDate;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18.0)),
      ),
      builder: (ctx) {
        return SizedBox(
          height: 420,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(ctx).pop()),
                    Text(DateFormat('MMMM yyyy').format(temp), style: const TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.check), onPressed: () { Navigator.of(ctx).pop(); }),
                  ],
                ),
              ),
              Expanded(
                child: CalendarDatePicker(
                  initialDate: temp,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  onDateChanged: (d) => temp = d,
                ),
              ),
            ],
          ),
        );
      },
    );
    setState(() {
      _selectedDate = temp;
    });
  }

  // UI Income
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kWhiteBackground,
      appBar: AppBar(
        leading: const BackButton(),
        centerTitle: true,
        backgroundColor: _kPurpleBackground,
        foregroundColor: Colors.white,
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          // Expense pill (klik → ke Expense)
          GestureDetector(
            onTap: () => Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const ExpenseScreen())),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                  color: _kPurpleBackground,
                  borderRadius: BorderRadius.circular(20)),
              child: const Row(
                children: [
                  Icon(Icons.credit_card, size: 18, color: Colors.white),
                  SizedBox(width: 6),
                  Text('Expense',
                      style:
                          TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Income pill (selected)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: const Row(
              children: [
                Icon(Icons.savings, size: 18, color: _kPurpleBackground),
                SizedBox(width: 6),
                Text('Income',
                    style: TextStyle(
                        color: _kPurpleBackground,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ]),
      ),

      body: Column(
        children: [
          Container(height: 56, width: double.infinity, color: _kPurpleBackground),

          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
              child: Column(
                children: [
                  // Settings
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                          color: _kPurpleLight,
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        children: [
                          const Spacer(),
                          GestureDetector(
                            onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SettingsScreen(
                                categories: labels,
                                icons: icons,
                                title: "Income Categories",
                              ),
                            ),
                          ),
                            child: const Row(
                              children: [
                                Icon(Icons.settings,
                                    size: 18, color: Colors.black54),
                                SizedBox(width: 8),
                                Text('Settings',
                                    style: TextStyle(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

                  // Categories
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 18,
                          runSpacing: 18,
                          children: List.generate(labels.length, (i) {
                            bool selected = i == _selectedIndex;

                            return GestureDetector(
                              onTap: () => setState(() => _selectedIndex = i),
                              child: SizedBox(
                                width: (MediaQuery.of(context).size.width - 64) / 4,
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? _kPurpleLight
                                            : _kPurpleBackground,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        icons[i],
                                        color: selected
                                            ? _kPurpleBackground
                                            : Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(labels[i],
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.black))
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Note + Amount
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GestureDetector(
                      onTap: () => setState(() => _showKeyboard = true),
                      child: Container(
                        height: 64,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _noteController,
                                readOnly: true,
                                decoration: const InputDecoration(
                                    hintText: "Note",
                                    border: InputBorder.none),
                              ),
                            ),
                            Text(_displayAmount,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Keyboard
                  AnimatedSwitcher(
  duration: const Duration(milliseconds: 200),
  child: Container(
    key: ValueKey(_showKeyboard),
    height: 320, // FIXED HEIGHT
    width: double.infinity,
    decoration: BoxDecoration(
      color: _kPurpleBackground,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
    ),
    padding: const EdgeInsets.all(4),
    child: _showKeyboard
        ? CalculatorKeyboard(
            expression: _calcExpression,
            onKey: _onCalcKey,
            onClear: _onCalcClear,
            onBackspace: _onCalcBackspace,
            onConfirm: _onCalcConfirm,
            onToday: () => _pickDate(),
            
          )
        : GestureDetector(
            onTap: () => setState(() => _showKeyboard = true),
            child: const Center(
              child: Text(
                'Tap Note to open keyboard',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
  ),
),

                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
