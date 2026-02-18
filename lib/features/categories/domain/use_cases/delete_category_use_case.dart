import 'package:dartz/dartz.dart';
import '../repositories/categories_repository.dart';

class DeleteCategoryUseCase {
  final CategoriesRepository repository;

  DeleteCategoryUseCase(this.repository);

  Future<Either<Exception, void>> call(String categoryId) async {
    return repository.deleteCategory(categoryId);
  }
}
