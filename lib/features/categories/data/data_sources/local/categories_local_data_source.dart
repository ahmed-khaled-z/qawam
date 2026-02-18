import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../../models/category_model.dart';
import '../../../../../../core/error/exceptions.dart';

abstract class CategoriesLocalDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<void> addCategory(CategoryModel category);
  Future<void> updateCategory(CategoryModel category);
  Future<void> deleteCategory(String categoryId);
}

class CategoriesLocalDataSourceImpl implements CategoriesLocalDataSource {
  static const String BOX_NAME = 'categories';

  CategoriesLocalDataSourceImpl();

  Box<CategoryModel> get _box => Hive.box<CategoryModel>(BOX_NAME);

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      if (!_box.isOpen) {
        // Should be open from init, but safeguard
        await Hive.openBox<CategoryModel>(BOX_NAME);
      }
      return _box.values.toList();
    } catch (e) {
      debugPrint("Categories Hive error: $e");
      throw CacheException();
    }
  }

  @override
  Future<void> addCategory(CategoryModel category) async {
    try {
      await _box.put(category.id, category);
    } catch (e) {
      debugPrint("Categories Hive Add error: $e");
      throw CacheException();
    }
  }

  @override
  Future<void> updateCategory(CategoryModel category) async {
    try {
      await _box.put(category.id, category);
    } catch (e) {
      debugPrint("Categories Hive Update error: $e");
      throw CacheException();
    }
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _box.delete(categoryId);
    } catch (e) {
      debugPrint("Categories Hive Delete error: $e");
      throw CacheException();
    }
  }
}
