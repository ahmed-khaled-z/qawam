import 'package:flutter/material.dart';

/// All category icons allowed in the app. Used to resolve icon codes to
/// constant [IconData] so Flutter can tree-shake icon fonts.
const List<IconData> kCategoryIcons = [
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

final Map<int, IconData> _iconCodeToIcon = {
  for (final icon in kCategoryIcons) icon.codePoint: icon,
};

/// Returns the [IconData] for the given icon code, or [Icons.category] as fallback.
/// Use this instead of IconData(code, fontFamily: 'MaterialIcons') so icon fonts can be tree-shaken.
IconData getCategoryIcon(int iconCode) {
  return _iconCodeToIcon[iconCode] ?? Icons.category;
}
