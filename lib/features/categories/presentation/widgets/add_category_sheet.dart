import 'package:flutter/material.dart';
import '../../../../config/language/language_manager.dart';
import '../../domain/entities/category.dart';

class AddCategorySheet extends StatefulWidget {
  final Category? categoryToEdit;
  final Function(String name, int iconCode, int color) onSave;

  const AddCategorySheet({
    super.key,
    required this.onSave,
    this.categoryToEdit,
  });

  @override
  State<AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<AddCategorySheet> {
  final _nameController = TextEditingController();
  int _selectedIconCode = 0xe25a; // Default fastfood
  int _selectedColor = 0xFF2196F3; // Default blue

  final List<IconData> _icons = [
    Icons.fastfood,
    Icons.shopping_cart,
    Icons.directions_car,
    Icons.home,
    Icons.movie,
    Icons.healing,
    Icons.school,
    Icons.flight,
    Icons.pets,
    Icons.fitness_center,
    Icons.work,
    Icons.card_giftcard,
    Icons.local_cafe,
    Icons.local_gas_station,
    Icons.shopping_bag,
    Icons.sports_esports,
  ];

  final List<Color> _colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.categoryToEdit != null) {
      _nameController.text = widget.categoryToEdit!.name;
      _selectedIconCode = widget.categoryToEdit!.iconCode;
      _selectedColor = widget.categoryToEdit!.color;
    } else {
      _selectedIconCode = _icons[0].codePoint;
      _selectedColor = _colors[0].value;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.categoryToEdit != null;
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isEditing
                ? context.tr('edit_category')
                : context.tr('add_category'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: context.tr('category_name'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: Icon(
                IconData(_selectedIconCode, fontFamily: 'MaterialIcons'),
                color: Color(_selectedColor),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            context.tr('select_icon'),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _icons.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final icon = _icons[index];
                final isSelected = icon.codePoint == _selectedIconCode;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedIconCode = icon.codePoint),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Color(_selectedColor).withOpacity(0.2)
                          : Colors.grey.shade100,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Color(_selectedColor), width: 2)
                          : null,
                    ),
                    child: Icon(
                      icon,
                      color: isSelected ? Color(_selectedColor) : Colors.grey,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Text(
            context.tr('select_color'),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _colors.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final color = _colors[index];
                final isSelected = color.value == _selectedColor;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedColor = color.value);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.black, width: 2)
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.isNotEmpty) {
                widget.onSave(
                  _nameController.text,
                  _selectedIconCode,
                  _selectedColor,
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D7377), // Teal from app theme
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Text(
              isEditing
                  ? "Save"
                  : context.tr('add_category'), // TODO: Localize Save
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
