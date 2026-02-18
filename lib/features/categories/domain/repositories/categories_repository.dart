import 'package:dartz/dartz.dart';
import '../entities/category.dart';

abstract class CategoriesRepository {
  Future<Either<Exception, List<Category>>> getCategories();
  Future<Either<Exception, void>> addCategory(Category category);
  Future<Either<Exception, void>> updateCategory(Category category);
  Future<Either<Exception, void>> deleteCategory(String categoryId);
}
