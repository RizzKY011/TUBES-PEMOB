import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'models.dart';
import '../../core/ocr/receipt_scanner.dart';
import 'split_select_members.dart';

class SplitScreen extends StatefulWidget {
  final ReceiptData? initialReceipt;
  const SplitScreen({super.key, this.initialReceipt});

  @override
  State<SplitScreen> createState() => _SplitScreenState();
}

class _SplitScreenState extends State<SplitScreen> {
  final List<SplitParticipant> _participants = <SplitParticipant>[];
  bool _equalSplit = true;
  ReceiptData? _scannedReceipt;

  final NumberFormat _numFmt = NumberFormat.decimalPattern('id_ID');

  Future<void> _uploadAgain() async {
    try {
      final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;
  final ReceiptData? receipt = await ReceiptScanner.scanReceiptFromXFile(image);
      if (receipt != null) {
        setState(() {
          // attach image path on returned receipt (scanReceipt already sets imagePath)
          _scannedReceipt = receipt;
          _participants.clear();
          _participants.add(SplitParticipant(id: const Uuid().v4(), name: 'Saya', paidAmount: receipt.total, shareWeight: 1.0));
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tidak dapat membaca struk')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Map<String, String?> _parseItemLine(String line) {
  // Find last number in the string
    final Iterable<RegExpMatch> matches = RegExp(r'([0-9]+[.,0-9]*)').allMatches(line);
    if (matches.isEmpty) return {'name': line, 'price': null};
    final RegExpMatch m = matches.last;
    String numStr = m.group(0) ?? '';
    final String name = line.substring(0, m.start).trim();
    // normalize numeric string to integer-like
    final String digits = numStr.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return {'name': line, 'price': null};
    final double value = double.tryParse(digits) ?? 0.0;
    final String formatted = _numFmt.format(value);
    return {'name': name, 'price': formatted};
  }

  @override
  void initState() {
    super.initState();
    // If screen opened with an initial scanned receipt, prefill
    if (widget.initialReceipt != null) {
      _scannedReceipt = widget.initialReceipt;
      _participants.clear();
      _participants.add(SplitParticipant(
        id: const Uuid().v4(),
        name: 'Saya',
        paidAmount: _scannedReceipt!.total,
        shareWeight: 1.0,
      ));
    }
  }

  // Note: scan/add/edit participant flows removed to keep this screen trimmed to the post-scan UI.

  @override
  Widget build(BuildContext context) {
    // ensure initial receipt is picked up

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
                  // Post-scan UI (show detailed mockup-style layout) - trimmed to only show until Confirm button
                  if (_scannedReceipt != null) ...[
                    // Name input
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Nama split bill', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: TextEditingController(text: _scannedReceipt!.merchant),
                            decoration: const InputDecoration(
                              hintText: 'Sinar Utama',
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Uploaded receipt card (purple)
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Struk berhasil diupload!', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(height: 8),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Klik gambar di bawah agar tampilan struk lebih jelas.', style: TextStyle(color: Colors.white70)),
                          ),
                          const SizedBox(height: 12),
                          if (_scannedReceipt!.imagePath != null)
                            Container(
                              width: 92,
                              height: 92,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white,
                                image: DecorationImage(image: FileImage(File(_scannedReceipt!.imagePath!)), fit: BoxFit.cover),
                              ),
                            )
                          else
                            Container(
                              width: 92,
                              height: 92,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.white24),
                              child: const Icon(Icons.receipt_long, color: Colors.white70, size: 48),
                            ),
                          const SizedBox(height: 12),
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Theme.of(context).colorScheme.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            onPressed: _uploadAgain,
                            icon: const Icon(Icons.upload_file, size: 16),
                            label: const Text('Upload ulang'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Itemized details card (compact)
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ..._scannedReceipt!.items.map((line) {
                            final parsed = _parseItemLine(line);
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: Text(parsed['name'] ?? line, style: const TextStyle(color: Colors.white))),
                                    const SizedBox(width: 8),
                                    Text(parsed['price'] != null ? 'Rp ${parsed['price']}' : '', style: const TextStyle(color: Colors.white)),
                                  ],
                                ),
                                const Divider(color: Colors.white24),
                              ],
                            );
                          }).toList(),

                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Subtotal', style: TextStyle(color: Colors.white70)),
                              Text('Rp ${_scannedReceipt!.total.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Edit detail button (no-op)
                          Center(
                            child: TextButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.edit, color: Colors.white70),
                              label: const Text('Edit Detail', style: TextStyle(color: Colors.white70)),
                              style: TextButton.styleFrom(backgroundColor: Colors.white24, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Confirm button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF24C35E), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
                        onPressed: () async {
                          // Navigate to member selection for this scanned receipt
                          if (_scannedReceipt == null) return;
                          Navigator.push(context, MaterialPageRoute(builder: (_) => SplitSelectMembersScreen(receipt: _scannedReceipt!)));
                        },
                        child: const Text('Konfirmasi'),
                      ),
                    ),

                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Participant dialog removed because this trimmed screen only shows scanned receipt -> confirm flow.

