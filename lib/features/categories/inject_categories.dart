import '../../injection_container.dart';
import 'data/data_sources/local/categories_local_data_source.dart';
import 'data/repositories/categories_repository_impl.dart';
import 'domain/repositories/categories_repository.dart';
import 'domain/use_cases/add_category_use_case.dart';
import 'domain/use_cases/delete_category_use_case.dart';
import 'domain/use_cases/get_categories_use_case.dart';
import 'domain/use_cases/update_category_use_case.dart';
import 'presentation/cubit/categories_cubit.dart';

//call this function in ServiceLocator.setup() function
void injectCategories() {
  // DataSources
  getIt.registerLazySingleton<CategoriesLocalDataSource>(
    () => CategoriesLocalDataSourceImpl(),
  );

  // Repository
  getIt.registerLazySingleton<CategoriesRepository>(
    () => CategoriesRepositoryImpl(
      localDataSource: getIt(),
      syncRepository: getIt(),
    ),
  );

  // UseCases
  getIt.registerLazySingleton(() => GetCategoriesUseCase(getIt()));
  getIt.registerLazySingleton(() => AddCategoryUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateCategoryUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteCategoryUseCase(getIt()));

  // Cubit
  getIt.registerFactory(
    () => CategoriesCubit(
      getCategoriesUseCase: getIt(),
      addCategoryUseCase: getIt(),
      updateCategoryUseCase: getIt(),
      deleteCategoryUseCase: getIt(),
    ),
  );
}
