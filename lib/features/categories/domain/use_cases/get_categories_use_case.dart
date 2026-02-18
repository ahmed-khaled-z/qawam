import 'package:dartz/dartz.dart';
import '../entities/category.dart';
import '../repositories/categories_repository.dart';

class GetCategoriesUseCase {
  final CategoriesRepository repository;

  GetCategoriesUseCase(this.repository);

  Future<Either<Exception, List<Category>>> call() async {
    return repository.getCategories();
  }
}
