import 'package:flutter/material.dart';
import '../../core/ocr/receipt_scanner.dart';
import 'models.dart';
import 'split_finalize.dart';
import 'package:intl/intl.dart';

class SplitDetailsScreen extends StatefulWidget {
  final ReceiptData receipt;
  final List<SplitParticipant> participants;
  const SplitDetailsScreen({super.key, required this.receipt, required this.participants});

  @override
  State<SplitDetailsScreen> createState() => _SplitDetailsScreenState();
}

class _SplitDetailsScreenState extends State<SplitDetailsScreen> {
  final Map<int, bool> _itemSelected = <int, bool>{};
  bool _equal = true;
  final NumberFormat _numFmt = NumberFormat.decimalPattern('id_ID');

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.receipt.items.length; i++) {
      _itemSelected[i] = true;
    }
  }

  void _toggleItem(int idx) => setState(() => _itemSelected[idx] = !(_itemSelected[idx] ?? true));

  void _continue() {
    Navigator.push<void>(context, MaterialPageRoute<void>(builder: (_) => const SplitFinalizeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final double total = widget.receipt.total > 0 ? widget.receipt.total : 0.0;
    final int count = widget.participants.length > 0 ? widget.participants.length : 1;
    final double per = _equal ? (total / count) : 0.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Pembagian split bill')),
      body: Column(
        children: <Widget>[
          // header card with total and name
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('Rp${_numFmt.format(total)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Nama split bill', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 6),
                Text('Split bill: ${widget.participants.isNotEmpty ? widget.participants.first.name : 'Audrey'} - ${DateTime.now().day} Okt ${DateTime.now().year}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
          ),

          // Rincian card
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(14)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Text('Rincian split bill', style: TextStyle(fontWeight: FontWeight.w700)),
                      TextButton.icon(onPressed: () {}, icon: const Icon(Icons.edit), label: const Text('Ubah anggota')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(children: <Widget>[
                    ElevatedButton(onPressed: () => setState(() => _equal = true), style: ElevatedButton.styleFrom(backgroundColor: _equal ? const Color(0xFF24C35E) : Colors.white, foregroundColor: _equal ? Colors.white : Theme.of(context).colorScheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), child: const Text('Bagi rata')),
                    const SizedBox(width: 8),
                    OutlinedButton(onPressed: () => setState(() => _equal = false), style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), child: const Text('Tentuin nominal')),
                  ]),
                  const SizedBox(height: 12),
                  const Divider(),

                  // participants list
                  ...widget.participants.map((p) {
                    final String formatted = per > 0 ? _numFmt.format(per.round()) : '0';
                    return ListTile(
                      leading: CircleAvatar(child: Text(p.name.isNotEmpty ? p.name[0].toUpperCase() : 'P')),
                      title: Text('${p.name} ${p.name == widget.participants.first.name ? '(Kamu)' : ''}'),
                      subtitle: Text(p.name == widget.participants.first.name ? 'Kamu' : ''),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                        child: Text('Rp ${formatted}'),
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 12),
                  // summary green box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.green.shade200), color: Colors.green.shade50),
                    child: Column(
                      children: <Widget>[
                        Text('Rp${_numFmt.format(total)} dari Rp${_numFmt.format(total)}', style: const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        const Text('Semua biaya udah masuk itungan', style: TextStyle(color: Colors.green)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // bottom button (Lanjutkan)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _continue,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF24C35E), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32))),
                  child: const Text('Lanjutkan', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
