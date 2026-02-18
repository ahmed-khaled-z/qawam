import 'package:dartz/dartz.dart';
import '../entities/category.dart';
import '../repositories/categories_repository.dart';

class AddCategoryUseCase {
  final CategoriesRepository repository;

  AddCategoryUseCase(this.repository);

  Future<Either<Exception, void>> call(Category category) async {
    return repository.addCategory(category);
  }
}
