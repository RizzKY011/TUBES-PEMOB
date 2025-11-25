import 'package:flutter/material.dart';
import 'category_editor_screen.dart';

const Color _kPurpleBackground = Color(0xFF6B4BD6);
const Color _kPurpleLight = Color(0xFFEEEAFF);

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required List<String> categories, required List<IconData> icons, required String title});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // SESUAIKAN DENGAN LABEL-LABEL INCOME
  final List<_CategoryItem> _items = [
    _CategoryItem('Salary', Icons.payments),
    _CategoryItem('Bonus', Icons.card_giftcard),
    _CategoryItem('Interest', Icons.savings),
    _CategoryItem('Investment', Icons.trending_up),
    _CategoryItem('Gift', Icons.redeem),
    _CategoryItem('Allowance', Icons.account_balance_wallet),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kPurpleLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black54),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            // SETTINGS pill
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: _kPurpleBackground,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.settings, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('Settings',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // LIST
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18)),
                ),
                child: Stack(
                  children: [
                    ReorderableListView.builder(
                      padding: const EdgeInsets.only(top: 12, bottom: 88),
                      itemCount: _items.length,
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) newIndex -= 1;
                          final item = _items.removeAt(oldIndex);
                          _items.insert(newIndex, item);
                        });
                      },
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return ListTile(
                          key: ValueKey(item.title),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _kPurpleLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(item.icon, color: _kPurpleBackground),
                          ),
                          title: Text(
                            item.title,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // EDIT BUTTON
                              IconButton(
                                icon: const Icon(Icons.drag_handle, color: Colors.black26),
                                onPressed: () async {
                                  final result = await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => CategoryEditorScreen(
                                        initialTitle: item.title,
                                        initialIcon: item.icon,
                                        isEdit: true,
                                      ),
                                    ),
                                  );

                                  if (result != null && result is Map) {
                                    if (result['delete'] == true) {
                                      setState(() => _items.removeAt(index));
                                    } else {
                                      final title = result['title'] as String? ?? item.title;

                                      final code = result['iconCodePoint'] as int? ??
                                          item.icon.codePoint;
                                      final family = result['fontFamily'] as String?;
                                      final pkg = result['fontPackage'] as String?;
                                      final newIcon = IconData(code,
                                          fontFamily: family, fontPackage: pkg);

                                      setState(() {
                                        _items[index] =
                                            _CategoryItem(title, newIcon);
                                      });
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    /// ADD NEW CATEGORY BUTTON
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: FloatingActionButton(
                        backgroundColor: _kPurpleBackground,
                        onPressed: () async {
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const CategoryEditorScreen(),
                            ),
                          );

                          if (result != null && result is Map) {
                            final title = result['title'] as String? ?? 'New';
                            final code = result['iconCodePoint'] as int? ??
                                Icons.more_horiz.codePoint;
                            final family = result['fontFamily'] as String?;
                            final pkg = result['fontPackage'] as String?;
                            final icon = IconData(code,
                                fontFamily: family, fontPackage: pkg);

                            setState(() {
                              _items.add(_CategoryItem(title, icon));
                            });
                          }
                        },
                        child: const Icon(Icons.add),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryItem {
  final String title;
  final IconData icon;

  _CategoryItem(this.title, this.icon);
}
