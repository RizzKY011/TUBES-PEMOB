import 'package:flutter/material.dart';

class SplitFinalizeScreen extends StatelessWidget {
  const SplitFinalizeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Bill')),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                const Text('Bill Date: 17/04/2025 10:23', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                const Text('IDR 280,500', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                // Example per-person totals
                Card(child: ListTile(leading: const CircleAvatar(backgroundImage: NetworkImage('https://picsum.photos/40')), title: const Text("lisy's total"), subtitle: const Text('IDR 28,875'))),
                const SizedBox(height: 12),
                Card(child: ListTile(leading: const CircleAvatar(backgroundImage: NetworkImage('https://picsum.photos/40')), title: const Text("audrey's total"), subtitle: const Text('IDR 43,542'))),
              ],
            ),
          ),
          SafeArea(
            child: Row(
              children: <Widget>[
                Expanded(child: TextButton(onPressed: () {}, style: TextButton.styleFrom(backgroundColor: const Color(0xFF24C35E), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 18)), child: const Text('Copy link'))),
                Expanded(child: TextButton(onPressed: () {}, style: TextButton.styleFrom(backgroundColor: const Color(0xFF24C35E), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 18)), child: const Text('Share'))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
