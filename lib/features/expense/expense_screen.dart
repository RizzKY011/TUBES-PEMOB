import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'income_screen_clean.dart';
import 'settings_screen.dart';

// Definisi Warna Kustom
const Color _kPurpleBackground = Color(0xFF6B4BD6); // Warna Ungu Keyboard
const Color _kPurpleLight = Color(0xFFEEEAFF); // Warna Ungu Muda untuk latar kategori/tanggal
const Color _kWhiteBackground = Colors.white;

// Warna tombol spesial (mengikuti layout pink, tetapi warna border diganti)
const Color _kGreenKeyBorder = Color(0xFF4ADE80);
const Color _kTealKeyBorder = Color(0xFF40C4FF);
const Color _kRedKeyBorder = Color(0xFFF44336);

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
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

  // Helper function untuk membangun tombol kalkulator dengan styling kustom
  Widget _buildKey(String label, {Color? color, required double fontSize, required FontWeight fontWeight, void Function()? onTap, IconData? icon}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: AspectRatio(
          aspectRatio: 1.25,
          child: GestureDetector(
            onTap: onTap ?? () => onKey(label),
            child: Container(
              height: 68,
              decoration: BoxDecoration(
                color: Colors.white, // Semua kunci berwarna putih
                borderRadius: BorderRadius.circular(16),
                // Border/shadow untuk tombol spesial
                border: color != null && color != Colors.white
                    ? Border.all(color: color, width: 2.0)
                    : null,
              ),
              child: Center(
                child: icon != null
                    ? Icon(icon, color: color ?? Colors.black, size: 28)
                    : Text(
                        label,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: fontWeight,
                          color: color ?? Colors.black,
                        ),
                      ),
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
        child: Column(
          children: [
            // Row 1: TODAY, +, Confirm
            Row(
              children: [
                _buildKey(
                  'TODAY',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  onTap: onToday,
                ),
                _buildKey(
                  '+',
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                  color: _kGreenKeyBorder, 
                  onTap: () => onKey('+'),
                ),
                _buildKey(
                  '✓', 
                  icon: Icons.check, 
                  color: _kTealKeyBorder, 
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  onTap: onConfirm,
                ),
              ],
            ),

            // Row 2: ×, 7, 8, 9
            Row(
              children: [
                _buildKey('×', fontSize: 24, fontWeight: FontWeight.bold, onTap: () => onKey('×')),
                _buildKey('7', fontSize: 28, fontWeight: FontWeight.w600),
                _buildKey('8', fontSize: 28, fontWeight: FontWeight.w600),
                _buildKey('9', fontSize: 28, fontWeight: FontWeight.w600),
              ],
            ),

            // Row 3: ÷, 4, 5, 6
            Row(
              children: [
                _buildKey('÷', fontSize: 24, fontWeight: FontWeight.bold, onTap: () => onKey('÷')),
                _buildKey('4', fontSize: 28, fontWeight: FontWeight.w600),
                _buildKey('5', fontSize: 28, fontWeight: FontWeight.w600),
                _buildKey('6', fontSize: 28, fontWeight: FontWeight.w600),
              ],
            ),

            // Row 4: -, 1, 2, 3
            Row(
              children: [
                _buildKey('-', fontSize: 24, fontWeight: FontWeight.bold, onTap: () => onKey('-')),
                _buildKey('1', fontSize: 28, fontWeight: FontWeight.w600),
                _buildKey('2', fontSize: 28, fontWeight: FontWeight.w600),
                _buildKey('3', fontSize: 28, fontWeight: FontWeight.w600),
              ],
            ),

            // Row 5: +, ., 0, X (Backspace/Clear)
            Row(
              children: [
                _buildKey(
                  '+',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  onTap: () => onKey('+'),
                ),
                _buildKey(
                  '.',
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
                _buildKey(
                  '0',
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
                _buildKey(
                  'X', 
                  icon: Icons.close, 
                  color: _kRedKeyBorder, 
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  onTap: onBackspace,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  // Daftar label kategori
  final List<String> labels = [
    'Food', 'Daily', 'Transport', 'Social',
    'Housing', 'Gifts', 'Comm', 'Clothing',
    'Entertain', 'Beauty', 'Medical', 'Tax',
  ];

  // Daftar ikon placeholder yang lebih generik
  final List<IconData> icons = [
    Icons.restaurant, Icons.shopping_bag, Icons.directions_car, Icons.people,
    Icons.home, Icons.card_giftcard, Icons.phone_android, Icons.checkroom,
    Icons.movie, Icons.face, Icons.local_hospital, Icons.account_balance,
  ];

  int _selectedIndex = 0;
  final TextEditingController _noteController = TextEditingController();
  final FocusNode _noteFocus = FocusNode();
  // Calculator state
  bool _showCalculator = true; // Set default ke true agar keyboard langsung terlihat
  String _calcExpression = '';
  String _displayAmount = '0';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _noteController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _noteController.dispose();
    _noteFocus.dispose();
    super.dispose();
  }

  // --- Calculator helpers ---
  void _onCalcKey(String key) {
    setState(() {
      if (key == '.') {
        final lastOp = _calcExpression.lastIndexOf(RegExp(r'[×÷+\-]'));
        final current = lastOp == -1 ? _calcExpression : _calcExpression.substring(lastOp + 1);
        if (current.contains('.')) return; 
      }
      if (RegExp(r'[×÷+\-]').hasMatch(key)) {
        if (_calcExpression.isEmpty) {
          if (key != '-') return;
        } else {
          final last = _calcExpression[_calcExpression.length - 1];
          if (RegExp(r'[×÷+\-]').hasMatch(last)) {
            _calcExpression = _calcExpression.substring(0, _calcExpression.length - 1) + key;
            return;
          }
        }
      }
      _calcExpression += key;
      _displayAmount = _calcExpression; // Update display saat mengetik
    });
  }

  void _onCalcBackspace() {
    setState(() {
      if (_calcExpression.isNotEmpty) {
        _calcExpression = _calcExpression.substring(0, _calcExpression.length - 1);
      }
      _displayAmount = _calcExpression.isEmpty ? '0' : _calcExpression; // Update display
    });
  }

  void _onCalcClear() {
    setState(() {
      _calcExpression = '';
      _displayAmount = '0';
    });
  }

  void _onCalcConfirm() {
    final res = _evaluateExpression(_calcExpression);
    setState(() {
      _displayAmount = res;
      _calcExpression = res; // Set expression ke hasil setelah konfirmasi
      _showCalculator = false;
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

  String _evaluateExpression(String expr) {
    if (expr.trim().isEmpty) return '0';
    // Logic evaluasi tetap sama
    final normalized = expr.replaceAll('×', '*').replaceAll('÷', '/');
    final tokens = <String>[];
    String numBuf = '';
    // Tokenize
    var i = 0;
    // Handle unary minus at the start
    if (normalized.startsWith('-')) {
      numBuf += '-';
      i = 1;
    }

    for (; i < normalized.length; i++) {
      final c = normalized[i];
      if ((c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57) || c == '.') {
        numBuf += c;
      } else if (c == '+' || c == '-' || c == '*' || c == '/') {
        if (numBuf.isNotEmpty && numBuf != '-') { // Pastikan bukan unary minus yang belum lengkap
          tokens.add(numBuf);
          numBuf = '';
        }
        tokens.add(c);
      }
    }
    if (numBuf.isNotEmpty && numBuf != '-') tokens.add(numBuf);

    if (tokens.isEmpty) return '0';
    
    // Perbaikan edge case: jika hanya ada satu angka (tanpa operator)
    if (tokens.length == 1) {
      try {
        double result = double.parse(tokens[0]);
        if (result == result.roundToDouble()) return result.toInt().toString();
        return result.toStringAsFixed(2).replaceFirst(RegExp(r'\.00$'), '');
      } catch (e) {
        return 'ERR';
      }
    }


    try {
      // first pass: handle * and /
      final stack = <String>[];
      var i = 0;
      while (i < tokens.length) {
        final t = tokens[i];
        if (t == '*' || t == '/') {
          final a = double.parse(stack.removeLast());
          final b = double.parse(tokens[i + 1]);
          final r = t == '*' ? a * b : a / b;
          stack.add(r.toString());
          i += 2;
        } else {
          stack.add(t);
          i += 1;
        }
      }

      // second pass: + and -
      var result = double.parse(stack[0]);
      i = 1;
      while (i < stack.length) {
        final op = stack[i];
        final num = double.parse(stack[i + 1]);
        if (op == '+') result = result + num;
        if (op == '-') result = result - num;
        i += 2;
      }

      if (result == result.roundToDouble()) return result.toInt().toString();
      return result.toStringAsFixed(2).replaceFirst(RegExp(r'\.00$'), '');
    } catch (e) {
      return 'ERR';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kWhiteBackground,
      appBar: AppBar(
        leading: const BackButton(),
        // Show both Expense and Income pills; Expense is selected on this screen
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Expense (selected)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: const [
                  Icon(Icons.credit_card, size: 18, color: _kPurpleBackground),
                  SizedBox(width: 6),
                  Text('Expense', style: TextStyle(color: _kPurpleBackground, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Income (tap to navigate)
            GestureDetector(
              onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const IncomeScreen())),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: _kPurpleBackground, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: const [
                    Icon(Icons.savings, size: 18, color: Colors.white),
                    SizedBox(width: 6),
                    Text('Income', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: _kPurpleBackground,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: const [Padding(padding: EdgeInsets.only(right: 12), child: Icon(Icons.check, color: Colors.white))],
      ),
      body: Column(
        children: [
          // small purple band below AppBar
          Container(height: 56, width: double.infinity, color: _kPurpleBackground),
          // White content area with rounded top corners
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: _kWhiteBackground,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Settings pill
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: _kPurpleLight, borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        children: [
                          const Spacer(),
                          GestureDetector(
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => SettingsScreen(categories: labels, icons: icons, title: "Expense Categories"))),
                            child: Row(
                              children: const [
                                Icon(Icons.settings, size: 18, color: Colors.black54),
                                SizedBox(width: 8),
                                Text('Settings', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Categories (scrollable area only)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 18,
                          runSpacing: 18,
                          children: List.generate(labels.length, (i) {
                            final selected = i == _selectedIndex;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedIndex = i),
                              child: SizedBox(
                                width: (MediaQuery.of(context).size.width - 64) / 4,
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: selected ? _kPurpleLight : _kPurpleBackground,
                                        border: Border.all(color: selected ? _kPurpleBackground : Colors.transparent, width: 2),
                                      ),
                                      child: Icon(icons[i], color: selected ? _kPurpleBackground : Colors.white),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(labels[i], textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.black)),
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

                  // Note row (no date/TODAY pill) — opens calculator when tapped
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: GestureDetector(
                      onTap: () => setState(() => _showCalculator = true),
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
                                onTap: () => setState(() => _showCalculator = true),
                                decoration: const InputDecoration(
                                  hintText: 'Note',
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), child: Text(_displayAmount, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Fixed-size keyboard area at bottom of white container
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      key: ValueKey(_showCalculator),
                      height: min(300.0, max(200.0, MediaQuery.of(context).size.height * 0.28)),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _kPurpleBackground,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: _showCalculator
                          ? CalculatorKeyboard(
                              expression: _calcExpression,
                              onKey: _onCalcKey,
                              onClear: _onCalcClear,
                              onBackspace: _onCalcBackspace,
                              onConfirm: _onCalcConfirm,
                              onToday: () => _pickDate(),
                            )
                          : GestureDetector(
                              onTap: () => setState(() => _showCalculator = true),
                              child: const Center(child: Text('Tap Note to open keyboard', style: TextStyle(color: Colors.white, fontSize: 16))),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}