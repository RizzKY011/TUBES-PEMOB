import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'split_screen.dart';
import 'split_custom.dart';
import 'split_scan.dart';
import 'repository.dart';
import '../debt/repository.dart';
import '../debt/models.dart';

class SplitHomeScreen extends StatefulWidget {
  const SplitHomeScreen({super.key});

  @override
  State<SplitHomeScreen> createState() => _SplitHomeScreenState();
}

class _SplitHomeScreenState extends State<SplitHomeScreen> {
  final SplitRepository _splitRepo = SplitRepository();
  final DebtRepository _debtRepo = DebtRepository();

  List<dynamic> _recentSessions = [];
  List<DebtItem> _debts = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _splitRepo.init();
    await _debtRepo.init();
    final sessions = _splitRepo.getAllSessions();
    final debts = _debtRepo.getAll();
    if (!mounted) return;
    setState(() {
      _recentSessions = sessions;
      _debts = debts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FF),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Split Bill', style: TextStyle(color: AppTheme.primary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 8),
            const Text('Pilih Cara Membagi Tagihan', style: TextStyle(color: Color(0xFF7D78B6))),
            const SizedBox(height: 12),

            // Cards
            InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SplitScanScreen())),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.camera_alt, color: Colors.white, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Scan & Split', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                          SizedBox(height: 4),
                          Text('Upload foto struk, biar MONAS hitung otomatis.', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.white),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SplitCustomScreen())),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.grid_view, color: Colors.white, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Custom Split', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                          SizedBox(height: 4),
                          Text('Atur sendiri total dan jumlah orangnya.', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.white),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),
            const Text('Debt Tracker', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),

            // Debt tracker box
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  if (_debts.isEmpty)
                    const SizedBox(height: 8)
                  else
                    ..._debts.take(2).map((d) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(child: Icon(Icons.person)),
                          title: Text('${d.fromName} - Bayar ke ${d.toName}'),
                          subtitle: Text('${d.createdAt.day} ${d.createdAt.month} - Rp ${d.amount.toStringAsFixed(0)}'),
                          trailing: ElevatedButton(onPressed: () {}, child: const Text('Bayar')),
                        )),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text('Lihat selengkapnya', style: TextStyle(color: Colors.white)),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),
            const Text('Riwayat Terakhir', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),

            // Recent history
            Expanded(
              child: ListView(
                children: _recentSessions.take(3).map<Widget>((s) {
                  final created = s.createdAt as DateTime;
                  final title = 'Sesi ${created.day}/${created.month}/${created.year}';
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    color: AppTheme.primary.withOpacity(0.12),
                    child: ListTile(
                      title: Text(title),
                      subtitle: Text('Rp ${_calcTotalFromSession(s).toStringAsFixed(0)}'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {},
                    ),
                  );
                }).toList(),
              ),
            ),

            // Bottom button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SplitCustomScreen())),
                  child: const Text('Buat Split Bill Baru'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calcTotalFromSession(dynamic s) {
    try {
      final List participants = s.participants as List;
      return participants.fold<double>(0, (sum, p) => sum + (p.paidAmount as double));
    } catch (_) {
      return 0.0;
    }
  }
}
