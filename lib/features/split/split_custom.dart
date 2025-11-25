import 'package:flutter/material.dart';
import 'split_select_members.dart';
import '../../core/ocr/receipt_scanner.dart';

class SplitCustomScreen extends StatefulWidget {
  const SplitCustomScreen({super.key});

  @override
  State<SplitCustomScreen> createState() => _SplitCustomScreenState();
}

class _SplitCustomScreenState extends State<SplitCustomScreen> {
  double _amount = 100000; // placeholder

  void _pickMembers() async {
    // navigate to member selection; the selection flow will push details screen
  final ReceiptData receipt = ReceiptData(merchant: 'Custom Split', total: _amount, items: <String>[], rawText: '');
  Navigator.push(context, MaterialPageRoute(builder: (_) => SplitSelectMembersScreen(receipt: receipt)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FF),
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: const Text('Split Bill'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                child: Column(children: [
                  const Text('Rp', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text('Rp${_amount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: const Text('Nama split bill', style: TextStyle(fontSize: 12, color: Colors.grey)),
                subtitle: const Text('Split bill: audrey - 29 Okt 2025', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Row(mainAxisSize: MainAxisSize.min, children: const [CircleAvatar(child: Icon(Icons.person)), SizedBox(width: 8), CircleAvatar(child: Icon(Icons.person))]),
                title: const Text('Pilih anggota'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: _pickMembers,
              ),
            ),
            const Spacer(),
            SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _pickMembers,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF24C35E), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32))),
                  child: const Text('Kirim ke anggota', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// no local ReceiptData - using core/ocr/receipt_scanner.ReceiptData
