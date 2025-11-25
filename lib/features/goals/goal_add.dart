import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewGoalData {
  final String name;
  final IconData icon;
  final Color color;
  final String currencySymbol; // Menyimpan simbol mata uang (atau nama negara)
  final double goalAmount;
  final double defaultAmount;
  final String savingCycle;
  final int endsInDays;

  NewGoalData({
    required this.name,
    required this.icon,
    required this.color,
    required this.currencySymbol, // Diperbarui
    required this.goalAmount,
    required this.defaultAmount,
    required this.savingCycle,
    required this.endsInDays,
  });
}

// ================= Screen Stateful =================
class CreateSavingGoalScreen extends StatefulWidget {
  final Function(NewGoalData) onGoalCreated;

  const CreateSavingGoalScreen({super.key, required this.onGoalCreated});

  @override
  State<CreateSavingGoalScreen> createState() => _CreateSavingGoalScreenState();
}

class _CreateSavingGoalScreenState extends State<CreateSavingGoalScreen> {
  final _formKey = GlobalKey<FormState>();

  // ====== State Variables ======
  String _name = '';
  IconData _icon = Icons.arrow_upward;
  Color _color = Colors.amber;
  // Diperbarui untuk menyimpan mata uang yang dipilih
  String _currencySymbol = 'Rp'; 
  String _currencyCountry = 'Indonesia (IDR)';
  
  double _savingGoal = 0.0;
  double _defaultAmount = 0.0;
  
  String _sourceAccount = 'Optional'; 
  String _destAccount = 'Optional'; 
  
  // Pilihan siklus tabungan
  String _savingCycle = 'Daily'; 
  
  DateTime? _startDate;
  DateTime? _endDate;

  // ====== Controllers ======
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _defaultAmountController = TextEditingController();

  // Currency Formatter disesuaikan
  NumberFormat _currencyFormatter(String symbol) =>
      NumberFormat.currency(locale: 'id', symbol: symbol, decimalDigits: 0);

  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    _defaultAmountController.dispose();
    super.dispose();
  }

  // ================= FUNCTIONS =================
  void _confirmGoal() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      int endsInDays = 365;
      if (_startDate != null && _endDate != null) {
        if (_endDate!.isAfter(_startDate!)) {
          endsInDays = _endDate!.difference(_startDate!).inDays.clamp(1, 9999);
        } else {
          endsInDays = 0;
        }
      }

      final newGoal = NewGoalData(
        name: _name.isEmpty ? 'New Goal' : _name,
        icon: _icon,
        color: _color,
        currencySymbol: _currencySymbol,
        goalAmount: _savingGoal,
        defaultAmount: _defaultAmount,
        savingCycle: _savingCycle,
        endsInDays: endsInDays,
      );

      widget.onGoalCreated(newGoal);
      Navigator.of(context).pop();
    }
  }

  Future<void> _selectDate(bool isStart) async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = isStart
        ? (_startDate ?? now)
        : (_endDate ?? now.add(const Duration(days: 30)));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _pickIcon() {
    setState(() {
      if (_icon == Icons.arrow_upward) {
        _icon = Icons.directions_car_outlined;
        _color = Colors.green;
      } else if (_icon == Icons.directions_car_outlined) {
        _icon = Icons.home;
        _color = Colors.lightBlue;
      } else {
        _icon = Icons.arrow_upward;
        _color = Colors.amber;
      }
    });
  }

  void _pickColor() {
    setState(() {
      _color = (_color == Colors.amber) ? Colors.pink : Colors.amber;
    });
  }

  void _pickCurrency() {
    // Implementasi Dummy untuk memilih mata uang/negara
    setState(() {
      if (_currencySymbol == 'Rp') {
        _currencySymbol = '\$';
        _currencyCountry = 'USA (USD)';
      } else {
        _currencySymbol = 'Rp';
        _currencyCountry = 'Indonesia (IDR)';
      }
    });
  }

  Future<void> _selectCycle(BuildContext context) async {
    final List<String> cycles = ['Daily', 'Weekly', 'Monthly', 'Yearly'];
    final String? selected = await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: cycles.map((cycle) {
            return ListTile(
              title: Text(cycle),
              onTap: () => Navigator.of(context).pop(cycle),
            );
          }).toList(),
        );
      },
    );

    if (selected != null) {
      setState(() {
        _savingCycle = selected;
      });
    }
  }

  // ================= WIDGET BUILDERS =================

  // Widget untuk baris input teks (Name, Goal, Amount)
  Widget _buildTextInputRow(String label, TextEditingController controller, String hint, Function(String) onSaved, {bool isOptional = false, bool isCurrency = false}) {
    // Gunakan formatter mata uang jika diperlukan
    final formatter = isCurrency ? _currencyFormatter(_currencySymbol) : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: isOptional && controller.text.isEmpty && !label.contains('Goal') && !label.contains('Amount')
                  ? Text(hint, style: TextStyle(color: Colors.grey[400]))
                  : SizedBox(
                      width: 150,
                      child: TextFormField(
                        controller: controller,
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          hintText: hint,
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          prefixText: isCurrency ? '$_currencySymbol' : null,
                          prefixStyle: TextStyle(color: Colors.grey[700]),
                        ),
                        keyboardType: isCurrency ? TextInputType.number : TextInputType.text,
                        onChanged: (value) {
                          if (label == 'Name') {
                            _name = value;
                            return;
                          }
                          
                          if (isCurrency) {
                            String clean = value.replaceAll(RegExp(r'[^0-9]'), '');
                            double numeric = double.tryParse(clean) ?? 0.0;
                            
                            if (label == 'Saving Goal') _savingGoal = numeric;
                            if (label == 'Default Amount') _defaultAmount = numeric;

                            if (numeric > 0) {
                              // Formatter harus disesuaikan untuk input
                              final formatted = NumberFormat('#,##0', 'id_ID').format(numeric);
                              
                              controller.value = controller.value.copyWith(
                                text: formatted,
                                selection: TextSelection.collapsed(offset: formatted.length),
                              );
                            } else if (value.isNotEmpty) {
                              // Ini untuk menangani penghapusan jika input bukan angka
                              controller.value = controller.value.copyWith(
                                text: '',
                                selection: TextSelection.collapsed(offset: 0),
                              );
                            }
                          } 
                        },
                        onSaved: (value) {
                          if (label == 'Name') {
                            _name = value ?? '';
                          } else if (isCurrency) {
                            String clean = value!.replaceAll(RegExp(r'[^0-9]'), '');
                            double numeric = double.tryParse(clean) ?? 0.0;
                            if (label == 'Saving Goal') _savingGoal = numeric;
                            if (label == 'Default Amount') _defaultAmount = numeric;
                          }
                        },
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk baris picker (Icon, Color, Currency, Cycle, Date)
  Widget _buildPickerRow(String label, String displayValue, {Widget? suffix, VoidCallback? onTap, bool showArrow = true, bool isOptional = false}) {
    // Tentukan warna teks untuk nilai yang dipilih (Optional vs Chosen)
    final TextStyle textStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: isOptional && displayValue == 'Optional' ? Colors.grey[400] : Colors.black,
    );
    
    // Nilai default untuk ditampilkan
    final String valueToShow = displayValue;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 16)),
            Row(
              children: [
                if (suffix != null) suffix,
                
                // Tampilkan nilai jika tidak menggunakan suffix untuk nilai itu sendiri (seperti Icon/Color)
                if (suffix == null) 
                  Text(valueToShow, style: textStyle),

                if (showArrow && onTap != null) const SizedBox(width: 8),
                
                // Panah hanya untuk item yang bisa diklik/dipilih
                if (showArrow && onTap != null) const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Circle Saving',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 120.0),
              children: [
                // === Bagian 1: Basic Info (Name, Icon, Color) ===
                _buildTextInputRow('Name', _nameController, 'Enter name here', (val) => _name = val),
                
                // Icon Picker
                _buildPickerRow(
                  'Icon', '',
                  suffix: CircleAvatar(
                    radius: 12,
                    backgroundColor: _color,
                    child: Icon(_icon, size: 16, color: Colors.white),
                  ),
                  onTap: _pickIcon,
                  showArrow: false, 
                ),
                
                // Color Picker
                _buildPickerRow(
                  'Color', '',
                  suffix: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                          color: _color, shape: BoxShape.circle)),
                  onTap: _pickColor,
                  showArrow: false, 
                ),
                
                const Divider(height: 32),

                // === Bagian 2: Amount & Account (Currency, Goal, Source, Dest) ===
                // Currency Picker (Memilih negara/simbol)
                _buildPickerRow(
                  'Currency', _currencyCountry,
                  isOptional: false,
                  onTap: _pickCurrency,
                  showArrow: false, 
                  suffix: Text(_currencyCountry, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                
                // Saving Goal (Dapat ditulis sendiri)
                _buildTextInputRow('Saving Goal', _goalController, 'Optional', (val) => _savingGoal = double.tryParse(val) ?? 0.0, isOptional: true, isCurrency: true),
                
                // Source Account (Opsional)
                _buildPickerRow('Source Account', _sourceAccount,
                  isOptional: true,
                  onTap: () { /* TODO: Pilih Source Account */ },
                  showArrow: false,
                ),

                // Dest Account (Opsional)
                _buildPickerRow('Dest Account', _destAccount,
                  isOptional: true,
                  onTap: () { /* TODO: Pilih Dest Account */ },
                  showArrow: false,
                ),
                
                const Divider(height: 32),

                // === Bagian 3: Cycle & Date (Cycle, Amount, Start, End) ===
                // Saving Cycle (Pilihan Daily, Weekly, Monthly, Yearly)
                _buildPickerRow('Saving Cycle', _savingCycle,
                  suffix: Text(_savingCycle,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black)),
                  onTap: () => _selectCycle(context), 
                  showArrow: false,
                ),
                
                // Default Amount (Dapat diisi sendiri)
                _buildTextInputRow('Default Amount', _defaultAmountController, 'Optional', (val) => _defaultAmount = double.tryParse(val) ?? 0.0, isOptional: true, isCurrency: true),
                
                // Start Date
                _buildPickerRow('Start Date', _startDate != null ? DateFormat('dd MMM yyyy').format(_startDate!) : 'Optional',
                  onTap: () => _selectDate(true), 
                  isOptional: true,
                  showArrow: true,
                ),
                
                // End Date
                _buildPickerRow('End Date', _endDate != null ? DateFormat('dd MMM yyyy').format(_endDate!) : 'Optional',
                  onTap: () => _selectDate(false), 
                  isOptional: true,
                  showArrow: true,
                ),
              ],
            ),
          ),
          // Floating Confirm Button di bawah
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                  left: 16, right: 16, top: 16, bottom: MediaQuery.of(context).padding.bottom > 0 ? MediaQuery.of(context).padding.bottom + 8 : 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))
                ],
              ),
              child: ElevatedButton(
                onPressed: _confirmGoal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: const Text('Confirm',
                    style: TextStyle(color: Colors.black, fontSize: 18)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}