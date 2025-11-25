import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../core/ocr/receipt_scanner.dart';
import 'split_details.dart';
import 'models.dart';

class SplitSelectMembersScreen extends StatefulWidget {
  final ReceiptData receipt;
  const SplitSelectMembersScreen({super.key, required this.receipt});

  @override
  State<SplitSelectMembersScreen> createState() => _SplitSelectMembersScreenState();
}

class _SplitSelectMembersScreenState extends State<SplitSelectMembersScreen> {
  final List<_Contact> _recommended = <_Contact>[
    _Contact(name: 'michel', phone: '+6285359148494'),
    _Contact(name: 'yuna', phone: '+6289509464468'),
    _Contact(name: 'lisa', phone: '+6285370357874'),
  ];

  final Map<String, bool> _selected = <String, bool>{};

  @override
  void initState() {
    super.initState();
    // auto-select "Saya"
    _selected['Saya'] = true;
  }

  void _toggle(String key) => setState(() => _selected[key] = !(_selected[key] ?? false));

  void _confirm() {
    // build SplitParticipant list from selections
    final List<SplitParticipant> participants = <SplitParticipant>[];
    _selected.forEach((k, v) {
      if (v) {
        participants.add(SplitParticipant(id: const Uuid().v4(), name: k, paidAmount: 0.0, shareWeight: 1.0));
      }
    });
    // add recommended selected
    for (final _Contact c in _recommended) {
      if (_selected[c.name] == true) {
        participants.add(SplitParticipant(id: const Uuid().v4(), name: c.name, paidAmount: 0.0, shareWeight: 1.0));
      }
    }

    if (participants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih minimal 1 anggota')));
      return;
    }

    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => SplitDetailsScreen(receipt: widget.receipt, participants: participants),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih anggota'),
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                const Text('Rekomendasi', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ..._recommended.map((c) {
                  final bool checked = _selected[c.name] ?? false;
                  return ListTile(
                    leading: CircleAvatar(child: Text(c.name[0].toUpperCase())),
                    title: Text(c.name),
                    subtitle: Text(c.phone),
                    trailing: Checkbox(value: checked, onChanged: (_) => _toggle(c.name)),
                    onTap: () => _toggle(c.name),
                  );
                }).toList(),
                const SizedBox(height: 20),
                const Text('Cari nama atau no HP', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 12),
                // placeholder search
                TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Cari nama atau no HP')),
                const SizedBox(height: 20),
                const Text('Anggota terpilih', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: const Text('Kamu'),
                  subtitle: const Text('*4884'),
                  trailing: ElevatedButton(onPressed: () {}, child: const Text('Ganti'), style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)))),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _confirm,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF24C35E), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32))),
                  child: const Text('Konfirmasi anggota', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Contact {
  final String name;
  final String phone;
  const _Contact({required this.name, required this.phone});
}
