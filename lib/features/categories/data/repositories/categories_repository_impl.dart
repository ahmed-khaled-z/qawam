import 'package:dartz/dartz.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/categories_repository.dart';
import '../data_sources/local/categories_local_data_source.dart';
import '../models/category_model.dart';
import '../../../../../../core/error/exceptions.dart';
import '../../../../../../core/sync/sync_repository.dart';

class CategoriesRepositoryImpl implements CategoriesRepository {
  final CategoriesLocalDataSource localDataSource;
  final SyncRepository syncRepository;

  CategoriesRepositoryImpl({
    required this.localDataSource,
    required this.syncRepository,
  });

  @override
  Future<Either<Exception, List<Category>>> getCategories() async {
    try {
      final categories = await localDataSource.getCategories();
      return Right(categories);
    } catch (e) {
      return Left(CacheException());
    }
  }

  @override
  Future<Either<Exception, void>> addCategory(Category category) async {
    try {
      final categoryModel = CategoryModel.fromEntity(category);
      final unsyncedModel = CategoryModel(
        id: categoryModel.id,
        name: categoryModel.name,
        iconCode: categoryModel.iconCode,
        color: categoryModel.color,
        isSyncedToFirebase: false,
        lastSyncedAt: categoryModel.lastSyncedAt,
      );
      await localDataSource.addCategory(unsyncedModel);
      // Attempt immediate sync
      syncRepository.syncCategories();
      return const Right(null);
    } catch (e) {
      return Left(CacheException());
    }
  }

  @override
  Future<Either<Exception, void>> updateCategory(Category category) async {
    try {
      final categoryModel = CategoryModel.fromEntity(category);
      final unsyncedModel = CategoryModel(
        id: categoryModel.id,
        name: categoryModel.name,
        iconCode: categoryModel.iconCode,
        color: categoryModel.color,
        isSyncedToFirebase: false,
        lastSyncedAt: categoryModel.lastSyncedAt,
      );
      await localDataSource.updateCategory(unsyncedModel);
      syncRepository.syncCategories();
      return const Right(null);
    } catch (e) {
      return Left(CacheException());
    }
  }

  @override
  Future<Either<Exception, void>> deleteCategory(String categoryId) async {
    try {
      await localDataSource.deleteCategory(categoryId);
      await syncRepository.addPendingDeletion(categoryId, 'categories');
      syncRepository.processPendingDeletions();
      return const Right(null);
    } catch (e) {
      return Left(CacheException());
    }
  }
}
