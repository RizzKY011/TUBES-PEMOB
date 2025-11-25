import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class GoalProgressScreen extends StatefulWidget {
  final String goalName;
  final double goalAmount;
  final double initialCurrentAmount;

  const GoalProgressScreen({
    super.key,
    required this.goalName,
    required this.goalAmount,
    this.initialCurrentAmount = 0.0,
  });

  @override
  State<GoalProgressScreen> createState() => _GoalProgressScreenState();
}

class _GoalProgressScreenState extends State<GoalProgressScreen> {
  // --- STATE LOKAL ---
  late double _currentAmount;
  late double _newGoalAmount; // Menyimpan nilai goal yang bisa diubah
  final double _savingAmountPerDay = 100000.0;
  final NumberFormat _moneyFormatter =
      NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);

  // Controller untuk Modal Edit Goal
  final TextEditingController _goalController = TextEditingController();

  // STATE BARU: Untuk menyimpan riwayat transaksi manual (Save/Withdraw)
  List<Map<String, dynamic>> _manualTransactions = []; 

  List<Map<String, dynamic>> dates = [
    {"date": "24 Nov", "saved": false, "index": 0},
    {"date": "25 Nov", "saved": false, "index": 1},
    {"date": "26 Nov", "saved": false, "index": 2},
    {"date": "27 Nov", "saved": false, "index": 3},
    {"date": "28 Nov", "saved": false, "index": 4},
    {"date": "29 Nov", "saved": false, "index": 5},
    {"date": "30 Nov", "saved": false, "index": 6},
    {"date": "01 Dec", "saved": false, "index": 7},
    {"date": "02 Dec", "saved": false, "index": 8},
    {"date": "03 Dec", "saved": false, "index": 9},
    {"date": "04 Dec", "saved": false, "index": 10},
    {"date": "05 Dec", "saved": false, "index": 11},
    {"date": "06 Dec", "saved": false, "index": 12},
  ];
  // --------------------

  @override
  void initState() {
    super.initState();
    _currentAmount = widget.initialCurrentAmount;
    _newGoalAmount = widget.goalAmount;
    _goalController.text = _newGoalAmount.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  // --- WIDGET HELPER ---

  Widget _buildModalRow(String label, String value, {bool isOptional = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          isOptional
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                )
              : Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
        ],
      ),
    );
  }

  // --- LOGIKA GRID SAVING (AUTO) ---

  void _saveAmount(String date) {
    final int itemIndex = dates.indexWhere((d) => d["date"] == date);
    final int nextUnsavedIndex = dates.indexWhere((d) => !d["saved"]);

    if (itemIndex == nextUnsavedIndex && itemIndex != -1) {
      setState(() {
        dates[itemIndex]["saved"] = true;
        _currentAmount += _savingAmountPerDay;
      });
      Navigator.pop(context);
    } else if (itemIndex != nextUnsavedIndex) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Harap selesaikan tabungan ${dates[nextUnsavedIndex]["date"]} terlebih dahulu.")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Jadwal tidak ditemukan/sudah tersimpan.")),
      );
      Navigator.pop(context);
    }
  }

  void _openSavingModal(String date) {
    final DateTime scheduledDate = DateTime(2025, 11, 24)
        .add(Duration(days: dates.indexWhere((d) => d["date"] == date)));
    final String dateDisplay = DateFormat('yyyy-MM-dd').format(scheduledDate);
    final isAlreadySaved = dates.firstWhere((d) => d["date"] == date)['saved'];

    if (isAlreadySaved) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Tabungan untuk $date sudah tersimpan.")),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Saving Schedule",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              
              _buildModalRow("Amount", _moneyFormatter.format(_savingAmountPerDay)),
              _buildModalRow("Date", dateDisplay),
              
              const SizedBox(height: 10),
              
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [                
                  const SizedBox(width: 16),
                  
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      minimumSize: const Size(120, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => _saveAmount(date),
                    child: const Text("Confirm Save", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // --- FUNGSI GLOBAL (EDIT GOAL & SAVE/WITHDRAW MANUAL) ---

  // FUNGSI BARU: Untuk menyimpan/mencatat nominal dan tanggal manual
  void _handleManualSave(double amount, DateTime date, {String? note}) {
    setState(() {
      _currentAmount += amount;
      _manualTransactions.add({
        "type": "Save",
        "amount": amount,
        "date": date,
        "note": note, // Simpan catatan
      });
      // Urutkan transaksi berdasarkan tanggal (terbaru di atas)
      _manualTransactions.sort((a, b) => b["date"].compareTo(a["date"]));
    });
    // Feedback disimpan di dalam modal agar pop-up snackbar lebih smooth
  }
  
  // FUNGSI BARU: Untuk mencatat nominal dan tanggal penarikan manual
  void _handleManualWithdraw(double amount, DateTime date, {String? note}) {
    if (amount > _currentAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nominal penarikan melebihi saldo tabungan saat ini.")),
      );
      return;
    }
    
    setState(() {
      _currentAmount -= amount;
      _manualTransactions.add({
        "type": "Withdraw",
        "amount": amount,
        "date": date,
        "note": note, // Simpan catatan
      });
      // Urutkan transaksi berdasarkan tanggal (terbaru di atas)
      _manualTransactions.sort((a, b) => b["date"].compareTo(a["date"]));
    });
  }

  void _openEditGoalModal() {
    _goalController.text = _newGoalAmount.toStringAsFixed(0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Edit Goal Amount",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              const Text("Nominal Goal Baru:", style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 8),

              TextField(
                controller: _goalController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixText: "Rp ",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (value) {
                  String cleanValue = value.replaceAll(RegExp(r'[^0-9]'), '');
                  _newGoalAmount = double.tryParse(cleanValue) ?? 0.0;
                },
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  if (_newGoalAmount > 0 && _newGoalAmount >= _currentAmount) {
                    setState(() {
                      // Update state lokal
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Goal Amount diperbarui menjadi ${_moneyFormatter.format(_newGoalAmount)}.")),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Nominal Goal tidak valid atau kurang dari tabungan saat ini.")),
                    );
                  }
                },
                child: const Text("Update Goal", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openActionModal(String action) {
    if (action == "Edit Goal") {
      _openEditGoalModal();
      return;
    }
    
    // Modal untuk Save/Withdraw Manual
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        if (action == "Save") {
          return ManualSavingModal(
            moneyFormatter: _moneyFormatter,
            onConfirm: _handleManualSave,
            initialAmount: _savingAmountPerDay, // Default jumlah per hari
          );
        } else if (action == "Withdraw") {
          return ManualWithdrawalModal(
            moneyFormatter: _moneyFormatter,
            onConfirm: _handleManualWithdraw,
            maxAmount: _currentAmount, // Batasan penarikan
          );
        }
        return Container();
      },
    );
  }
  
  // WIDGET BARU: Menampilkan daftar riwayat transaksi manual
  Widget _buildManualTransactionList() {
    if (_manualTransactions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Text(
          "Belum ada transaksi manual.",
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _manualTransactions.length,
      itemBuilder: (context, index) {
        final transaction = _manualTransactions[index];
        final formattedDate = DateFormat('yyyy-MM-dd').format(transaction["date"]);
        final isSave = transaction["type"] == "Save";
        
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
          elevation: 0.5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            leading: Icon(
              isSave ? Icons.add_circle : Icons.remove_circle,
              color: isSave ? Colors.green : Colors.red,
            ),
            title: Text(
              isSave ? "Manual Save" : "Manual Withdraw",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formattedDate, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                if (transaction["note"] != null && transaction["note"].isNotEmpty)
                  Text("Note: ${transaction["note"]}", style: TextStyle(color: Colors.grey[700], fontSize: 12)),
              ],
            ),
            trailing: Text(
              (isSave ? "+" : "-") + _moneyFormatter.format(transaction["amount"]),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSave ? Colors.green : Colors.red,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double progress = (_currentAmount / _newGoalAmount).clamp(0.0, 1.0);
    final String progressPercent = (progress * 100).toStringAsFixed(0);
    final int remainingDays = 12;

    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(widget.goalName, style: const TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.black),
            onPressed: () => _openActionModal("Edit Goal"),
          )
        ],
      ),

      body: SingleChildScrollView( // Memastikan seluruh konten bisa di-scroll
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Kartu Utama (Progress Header) ---
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.yellow[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(widget.goalName, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      const Icon(Icons.account_balance_wallet_outlined, size: 18),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Text(
                    _moneyFormatter.format(_currentAmount),
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "${_moneyFormatter.format(_currentAmount)} / ${_moneyFormatter.format(_newGoalAmount)} - Ends in $remainingDays days",
                    style: const TextStyle(fontSize: 14),
                  ),

                  const SizedBox(height: 10),

                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 7,
                          backgroundColor: Colors.white,
                          color: Colors.yellow[800],
                        ),
                      ),
                      Align(
                          alignment: Alignment.centerRight,
                          child: progress > 0.01 
                              ? Padding(
                                  padding: const EdgeInsets.only(right: 5),
                                  child: Text("$progressPercent%",
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: progress > 0.1 ? Colors.white : Colors.black54)),
                                )
                              : Container()
                          )
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // --- 2. Tombol Aksi (Save & Withdraw) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _openActionModal("Save"), // Memanggil Save Manual
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text("Save"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _openActionModal("Withdraw"), // Memanggil Withdraw Manual
                      icon: const Icon(Icons.remove, size: 20),
                      label: const Text("Withdraw"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // --- 3. Grid Jadwal Saving ---
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.0),
              child: Text(
                "Auto Saving Schedule",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: GridView.builder(
                shrinkWrap: true, // WAJIB: Agar GridView berfungsi dalam SingleChildScrollView
                physics: const NeverScrollableScrollPhysics(), // WAJIB: Agar tidak terjadi double scroll
                padding: const EdgeInsets.only(bottom: 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.9,
                ),
                itemCount: dates.length,
                itemBuilder: (context, index) {
                  final d = dates[index];
                  bool saved = d["saved"];
                  return GestureDetector(
                    onTap: () => _openSavingModal(d["date"]),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: saved ? const Color(0xFF5CB85C) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: saved ? const Color(0xFF5CB85C) : Colors.grey.shade300),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _moneyFormatter.format(_savingAmountPerDay),
                              style: TextStyle(
                                  fontSize: 12,
                                  color: saved ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              d["date"],
                              style: TextStyle(
                                fontSize: 12,
                                color: saved ? Colors.white : Colors.grey[700],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // --- 4. Riwayat Manual Saving ---
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.0),
              child: Text(
                "Manual Transactions History",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
              child: _buildManualTransactionList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

//WIDGET BARU: Manual Saving Modal (Digunakan oleh tombol "Save" Global)

class ManualSavingModal extends StatefulWidget {
  final NumberFormat moneyFormatter;
  final Function(double amount, DateTime date, {String? note}) onConfirm;
  final double initialAmount;

  const ManualSavingModal({
    super.key,
    required this.moneyFormatter,
    required this.onConfirm,
    required this.initialAmount,
  });

  @override
  State<ManualSavingModal> createState() => _ManualSavingModalState();
}

class _ManualSavingModalState extends State<ManualSavingModal> {
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller dengan nominal awal
    _amountController.text = widget.initialAmount.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Widget _buildInputRow(String label, {required Widget inputWidget}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          inputWidget,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Manual Saving",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // 1. INPUT AMOUNT
          _buildInputRow(
            "Amount",
            inputWidget: SizedBox(
              width: 150,
              child: TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  prefixText: "Rp ",
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ),

          // 2. INPUT DATE
          _buildInputRow(
            "Date",
            inputWidget: TextButton(
              onPressed: () => _selectDate(context),
              child: Text(
                DateFormat('yyyy-MM-dd').format(_selectedDate),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // 3. INPUT NOTE
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Note:", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  hintText: "Tambahkan catatan (opsional)...",
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                maxLines: 2,
              ),
            ],
          ),
          
          const SizedBox(height: 20),

          // Tombol Confirm
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  minimumSize: const Size(120, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  final double amount = double.tryParse(_amountController.text) ?? 0.0;
                  final String note = _noteController.text.trim();
                  if (amount > 0) {
                    widget.onConfirm(amount, _selectedDate, note: note.isEmpty ? null : note); 
                    Navigator.pop(context); // Pop modal
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Berhasil menabung ${_amountController.text} secara manual.")),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Nominal tabungan harus lebih dari Rp0.")),
                    );
                  }
                },
                child: const Text("Confirm Save", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// WIDGET BARU: Manual Withdrawal Modal (Digunakan oleh tombol "Withdraw" Global)

class ManualWithdrawalModal extends StatefulWidget {
  final NumberFormat moneyFormatter;
  final Function(double amount, DateTime date, {String? note}) onConfirm;
  final double maxAmount;

  const ManualWithdrawalModal({
    super.key,
    required this.moneyFormatter,
    required this.onConfirm,
    required this.maxAmount,
  });

  @override
  State<ManualWithdrawalModal> createState() => _ManualWithdrawalModalState();
}

class _ManualWithdrawalModalState extends State<ManualWithdrawalModal> {
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  
  Widget _buildInputRow(String label, {required Widget inputWidget}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          inputWidget,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Manual Withdrawal",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          
          Text(
            "Max Withdrawal: ${widget.moneyFormatter.format(widget.maxAmount)}",
            style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // 1. INPUT AMOUNT
          _buildInputRow(
            "Amount",
            inputWidget: SizedBox(
              width: 150,
              child: TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  prefixText: "Rp ",
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ),

          // 2. INPUT DATE
          _buildInputRow(
            "Date",
            inputWidget: TextButton(
              onPressed: () => _selectDate(context),
              child: Text(
                DateFormat('yyyy-MM-dd').format(_selectedDate),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // 3. INPUT NOTE
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Note:", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  hintText: "Tambahkan catatan alasan penarikan (opsional)...",
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                maxLines: 2,
              ),
            ],
          ),
          
          const SizedBox(height: 20),

          // Tombol Confirm
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(120, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  final double amount = double.tryParse(_amountController.text) ?? 0.0;
                  final String note = _noteController.text.trim();
                  
                  if (amount > 0 && amount <= widget.maxAmount) {
                    widget.onConfirm(amount, _selectedDate, note: note.isEmpty ? null : note); 
                    Navigator.pop(context); // Pop modal
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Berhasil menarik ${_amountController.text} secara manual.")),
                    );
                  } else if (amount > widget.maxAmount) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Nominal penarikan melebihi saldo tabungan.")),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Nominal penarikan harus lebih dari Rp0.")),
                    );
                  }
                },
                child: const Text("Confirm Withdraw", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}