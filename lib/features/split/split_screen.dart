import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'models.dart';
import 'payment_helper.dart';
import 'repository.dart';
import 'package:csv/csv.dart';
import '../../core/ocr/receipt_scanner.dart';
import '../debt/repository.dart';
import '../debt/models.dart';

class SplitScreen extends StatefulWidget {
  const SplitScreen({super.key});

  @override
  State<SplitScreen> createState() => _SplitScreenState();
}

class _SplitScreenState extends State<SplitScreen> {
  final List<SplitParticipant> _participants = <SplitParticipant>[];
  bool _equalSplit = true;
  bool _isScanning = false;
  ReceiptData? _scannedReceipt;
  final SplitRepository _repo = SplitRepository();
  final DebtRepository _debtRepo = DebtRepository();

  void _addParticipant() async {
    final SplitParticipant? p = await showDialog<SplitParticipant>(
      context: context,
      builder: (BuildContext context) => _ParticipantDialog(equalMode: _equalSplit),
    );
    if (p != null) {
      setState(() {
        _participants.add(p);
      });
    }
  }

  void _editParticipant(int index) async {
    final SplitParticipant current = _participants[index];
    final SplitParticipant? p = await showDialog<SplitParticipant>(
      context: context,
      builder: (BuildContext context) => _ParticipantDialog(
        equalMode: _equalSplit,
        initial: current,
      ),
    );
    if (p != null) {
      setState(() {
        _participants[index] = p.copyWith(id: current.id);
      });
    }
  }

  Future<void> _scanReceipt() async {
    setState(() => _isScanning = true);
    
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      
      if (image != null) {
        final ReceiptData? receipt = await ReceiptScanner.scanReceipt(image.path);
        if (receipt != null) {
          setState(() {
            _scannedReceipt = receipt;
            _participants.clear();
            // Auto-add the person who paid
            _participants.add(SplitParticipant(
              id: const Uuid().v4(),
              name: 'Saya',
              paidAmount: receipt.total,
              shareWeight: 1.0,
            ));
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error scanning receipt: $e')),
        );
      }
    } finally {
      setState(() => _isScanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final SplitResult result = SplitCalculator.calculate(
      participants: _participants,
      equalSplit: _equalSplit,
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            title: const Text('MONAS Split Bill'),
            backgroundColor: Theme.of(context).colorScheme.surface,
            foregroundColor: Theme.of(context).colorScheme.primary,
            actions: <Widget>[
              IconButton(
                tooltip: _equalSplit ? 'Ubah ke porsi' : 'Ubah ke rata',
                icon: Icon(_equalSplit ? Icons.pie_chart : Icons.format_align_center),
                onPressed: () => setState(() => _equalSplit = !_equalSplit),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Receipt Scanner Card
                  if (_scannedReceipt != null) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.receipt, color: Theme.of(context).colorScheme.primary),
                                const SizedBox(width: 8),
                                Text(
                                  'Receipt Scanned',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Merchant: ${_scannedReceipt!.merchant}'),
                            Text('Total: Rp ${_scannedReceipt!.total.toStringAsFixed(0)}'),
                            if (_scannedReceipt!.items.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text('Items: ${_scannedReceipt!.items.length} items found'),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Action Buttons
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isScanning ? null : _scanReceipt,
                          icon: _isScanning 
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.camera_alt),
                          label: Text(_isScanning ? 'Scanning...' : 'Scan Receipt'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _addParticipant,
                          icon: const Icon(Icons.person_add),
                          label: const Text('Add Person'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _equalSplit ? 'Mode: Equal Split' : 'Mode: Custom Portions',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      const Spacer(),
                      IconButton(
                        tooltip: 'Simpan Sesi',
                        icon: const Icon(Icons.save),
                        onPressed: () async {
                          if (_participants.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Belum ada peserta')));
                            return;
                          }
                          final SplitSession session = SplitSession(
                            id: const Uuid().v4(),
                            createdAt: DateTime.now(),
                            equalSplit: _equalSplit,
                            participants: List<SplitParticipant>.from(_participants),
                          );
                          await _repo.saveSession(session);
                          // Auto-create debts from current settlements
                          await _debtRepo.init();
                          for (final Settlement s in result.settlements) {
                            final String from = _participants.firstWhere((p) => p.id == s.fromParticipantId).name;
                            final String to = _participants.firstWhere((p) => p.id == s.toParticipantId).name;
                            final DebtItem d = DebtItem(
                              id: const Uuid().v4(),
                              fromName: from,
                              toName: to,
                              amount: s.amount,
                              createdAt: DateTime.now(),
                            );
                            await _debtRepo.add(d);
                          }
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sesi tersimpan & utang dibuat')));
                        },
                      ),
                      IconButton(
                        tooltip: 'Riwayat',
                        icon: const Icon(Icons.history),
                        onPressed: () async {
                          final List<SplitSession> sessions = _repo.getAllSessions();
                          if (!context.mounted) return;
                          await showModalBottomSheet<void>(
                            context: context,
                            builder: (BuildContext context) {
                              return ListView(
                                children: sessions.map((SplitSession s) {
                                  return Dismissible(
                                    key: ValueKey<String>(s.id),
                                    background: Container(color: Colors.red),
                                    onDismissed: (_) async => _repo.deleteSession(s.id),
                                    child: ListTile(
                                      title: Text('Sesi ${s.createdAt}'),
                                      subtitle: Text(s.equalSplit ? 'Bagi Rata' : 'Bobot'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        setState(() {
                                          _equalSplit = s.equalSplit;
                                          _participants
                                            ..clear()
                                            ..addAll(s.participants);
                                        });
                                      },
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          );
                        },
                      ),
                      IconButton(
                        tooltip: 'Export CSV',
                        icon: const Icon(Icons.file_download),
                        onPressed: () async {
                          if (_participants.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Belum ada data untuk diexport')));
                            return;
                          }
                          final List<List<dynamic>> rows = <List<dynamic>>[
                            <dynamic>['Nama', 'Sudah Bayar', 'Bobot', 'Owed', 'Net'],
                            ..._participants.map((SplitParticipant p) {
                              final double owed = result.owedByParticipant[p.id] ?? 0.0;
                              final double net = result.netByParticipant[p.id] ?? 0.0;
                              return <dynamic>[p.name, p.paidAmount, p.shareWeight, owed, net];
                            }),
                            <dynamic>[],
                            <dynamic>['Settlement: from', 'to', 'amount'],
                            ...result.settlements.map((s) {
                              final String from = _participants.firstWhere((p) => p.id == s.fromParticipantId).name;
                              final String to = _participants.firstWhere((p) => p.id == s.toParticipantId).name;
                              return <dynamic>[from, to, s.amount];
                            }),
                          ];
                          final String csv = const ListToCsvConverter().convert(rows);
                          await Share.share(csv, subject: 'Split Bill Export');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._participants.asMap().entries.map((entry) {
                    final int idx = entry.key;
                    final SplitParticipant p = entry.value;
                    return Card(
                      child: ListTile(
                        title: Text(p.name),
                        subtitle: Text('Bayar: ${p.paidAmount.toStringAsFixed(2)} | Bobot: ${p.shareWeight.toStringAsFixed(2)}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editParticipant(idx),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  Text('Total Bayar: ${_participants.fold<double>(0, (s, p) => s + p.paidAmount).toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  Text('Hutang-Piutang (Net):', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...result.netByParticipant.entries.map((e) {
                    final SplitParticipant? p = _participants.firstWhere((x) => x.id == e.key);
                    final String name = p?.name ?? e.key;
                    final double v = e.value;
                    final String desc = v >= 0 ? 'Terima' : 'Bayar';
                    return ListTile(
                      dense: true,
                      leading: Icon(v >= 0 ? Icons.arrow_downward : Icons.arrow_upward, color: v >= 0 ? Colors.green : Colors.red),
                      title: Text(name),
                      trailing: Text('$desc ${v.abs().toStringAsFixed(2)}'),
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                  Text('Saran Pelunasan:', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (result.settlements.isEmpty)
                    const Text('Semua sudah seimbang.')
                  else
                    ...result.settlements.map((s) {
                      final String from = _participants.firstWhere((p) => p.id == s.fromParticipantId).name;
                      final String to = _participants.firstWhere((p) => p.id == s.toParticipantId).name;
                      final String message = PaymentHelper.settlementMessage(fromName: from, toName: to, amount: s.amount);
                      return Card(
                        child: ListTile(
                          dense: false,
                          leading: const Icon(Icons.payments),
                          title: Text('$from ➜ $to'),
                          subtitle: Text(s.amount.toStringAsFixed(2)),
                          trailing: Wrap(
                            spacing: 8,
                            children: <Widget>[
                              IconButton(
                                tooltip: 'Buat Utang',
                                icon: const Icon(Icons.add_task),
                                onPressed: () async {
                                  await _debtRepo.init();
                                  final DebtItem d = DebtItem(
                                    id: const Uuid().v4(),
                                    fromName: from,
                                    toName: to,
                                    amount: s.amount,
                                    createdAt: DateTime.now(),
                                  );
                                  await _debtRepo.add(d);
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Utang dibuat dari settlement')));
                                },
                              ),
                              IconButton(
                                tooltip: 'QR',
                                icon: const Icon(Icons.qr_code),
                                onPressed: () {
                                  showDialog<void>(
                                    context: context,
                                    builder: (BuildContext context) => AlertDialog(
                                      title: const Text('QR Pembayaran (stub)'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          QrImageView(
                                            data: message,
                                            version: QrVersions.auto,
                                            size: 180,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(message, textAlign: TextAlign.center),
                                          const SizedBox(height: 8),
                                          QrImageView(
                                            data: 'QRIS:$to:${s.amount.toStringAsFixed(2)}',
                                            version: QrVersions.auto,
                                            size: 180,
                                          ),
                                          const Text('QRIS (stub)'),
                                        ],
                                      ),
                                      actions: <Widget>[
                                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                tooltip: 'Share',
                                icon: const Icon(Icons.ios_share),
                                onPressed: () => Share.share(message),
                              ),
                              PopupMenuButton<String>(
                                tooltip: 'E-Wallet',
                                onSelected: (String provider) async {
                                  final Uri uri = PaymentHelper.buildStubEwalletUri(provider: provider, toName: to, amount: s.amount);
                                  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Tidak bisa buka $provider')),
                                    );
                                  }
                                },
                                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                  const PopupMenuItem<String>(value: 'ovo', child: Text('Bayar via OVO (stub)')),
                                  const PopupMenuItem<String>(value: 'dana', child: Text('Bayar via DANA (stub)')),
                                  const PopupMenuItem<String>(value: 'linkaja', child: Text('Bayar via LinkAja (stub)')),
                                ],
                                icon: const Icon(Icons.account_balance_wallet),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticipantDialog extends StatefulWidget {
  final bool equalMode;
  final SplitParticipant? initial;

  const _ParticipantDialog({required this.equalMode, this.initial});

  @override
  State<_ParticipantDialog> createState() => _ParticipantDialogState();
}

class _ParticipantDialogState extends State<_ParticipantDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _paidController = TextEditingController(text: '0');
  final TextEditingController _weightController = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    final SplitParticipant? init = widget.initial;
    if (init != null) {
      _nameController.text = init.name;
      _paidController.text = init.paidAmount.toString();
      _weightController.text = init.shareWeight.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Tambah Orang' : 'Ubah Data'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nama'),
          ),
          TextField(
            controller: _paidController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Sudah Bayar'),
          ),
          if (!widget.equalMode)
            TextField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Bobot Porsi'),
            ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () {
            final String name = _nameController.text.trim().isEmpty ? 'Orang' : _nameController.text.trim();
            final double paid = double.tryParse(_paidController.text.replaceAll(',', '.')) ?? 0.0;
            final double weight = widget.equalMode ? 1.0 : (double.tryParse(_weightController.text.replaceAll(',', '.')) ?? 1.0);
            final SplitParticipant p = SplitParticipant(
              id: widget.initial?.id ?? const Uuid().v4(),
              name: name,
              paidAmount: paid < 0 ? 0 : paid,
              shareWeight: weight <= 0 ? 1.0 : weight,
            );
            Navigator.pop(context, p);
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}

