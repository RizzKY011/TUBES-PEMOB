import 'package:flutter/material.dart';

const Color _kPurpleBackground = Color(0xFF6B4BD6);
const Color _kPurpleLight = Color(0xFFEEEAFF);

class CategoryEditorScreen extends StatefulWidget {
  final String? initialTitle;
  final IconData? initialIcon;
  final bool isEdit;

  const CategoryEditorScreen({super.key, this.initialTitle, this.initialIcon, this.isEdit = false});

  @override
  State<CategoryEditorScreen> createState() => _CategoryEditorScreenState();
}

class _CategoryEditorScreenState extends State<CategoryEditorScreen> {
  final TextEditingController _nameController = TextEditingController();
  IconData? _selectedIcon;

  final Map<String, List<IconData>> _groups = {
    'Food': [Icons.restaurant, Icons.local_cafe, Icons.local_drink, Icons.emoji_food_beverage],
    'Daily': [Icons.store, Icons.shopping_cart, Icons.local_grocery_store, Icons.kitchen],
    'Transport': [Icons.local_taxi, Icons.directions_bus, Icons.train, Icons.pedal_bike],
    'Others': [Icons.card_giftcard, Icons.work, Icons.pets, Icons.more_horiz],
  };

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialTitle != null) _nameController.text = widget.initialTitle!;
    if (widget.initialIcon != null) _selectedIcon = widget.initialIcon;
  }

  void _confirm() {
    if (_nameController.text.trim().isEmpty || _selectedIcon == null) return;
    Navigator.of(context).pop({
      'title': _nameController.text.trim(),
      'iconCodePoint': _selectedIcon!.codePoint,
      'fontFamily': _selectedIcon!.fontFamily,
      'fontPackage': _selectedIcon!.fontPackage,
    });
  }

  void _delete() {
    Navigator.of(context).pop({'delete': true});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kPurpleLight,
      appBar: AppBar(
        backgroundColor: _kPurpleBackground,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
        title: Text(widget.isEdit ? 'Edit Category' : 'New Category'),
        centerTitle: true,
        actions: [
          if (widget.isEdit)
            IconButton(icon: const Icon(Icons.delete_outline), onPressed: _delete),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _confirm,
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: _kPurpleBackground,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      decoration: const InputDecoration.collapsed(hintText: 'Enter category name', hintStyle: TextStyle(color: Colors.white70)),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                children: _groups.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(color: _kPurpleLight, borderRadius: BorderRadius.circular(6)),
                        child: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 92,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: entry.value.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, idx) {
                            final icon = entry.value[idx];
                            final selected = _selectedIcon == icon;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedIcon = icon),
                              child: Container(
                                width: 76,
                                decoration: BoxDecoration(
                                  color: selected ? Colors.white : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: selected ? _kPurpleBackground : Colors.grey.shade300, width: selected ? 2 : 1),
                                ),
                                child: Center(
                                  child: Icon(icon, color: _kPurpleBackground, size: 34),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
