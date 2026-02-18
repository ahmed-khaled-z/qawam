import 'package:dartz/dartz.dart';
import '../entities/category.dart';
import '../repositories/categories_repository.dart';

class UpdateCategoryUseCase {
  final CategoriesRepository repository;

  UpdateCategoryUseCase(this.repository);

  Future<Either<Exception, void>> call(Category category) async {
    return repository.updateCategory(category);
  }
}
