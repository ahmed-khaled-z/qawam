import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/category.dart';
import '../../domain/use_cases/add_category_use_case.dart';
import '../../domain/use_cases/delete_category_use_case.dart';
import '../../domain/use_cases/get_categories_use_case.dart';
import '../../domain/use_cases/update_category_use_case.dart';
import 'categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  final GetCategoriesUseCase getCategoriesUseCase;
  final AddCategoryUseCase addCategoryUseCase;
  final UpdateCategoryUseCase updateCategoryUseCase;
  final DeleteCategoryUseCase deleteCategoryUseCase;

  CategoriesCubit({
    required this.getCategoriesUseCase,
    required this.addCategoryUseCase,
    required this.updateCategoryUseCase,
    required this.deleteCategoryUseCase,
  }) : super(const CategoriesState());

  Future<void> loadCategories() async {
    emit(state.copyWith(status: CategoriesStatus.loading));
    final result = await getCategoriesUseCase.call();
    result.fold(
      (error) => emit(
        state.copyWith(
          status: CategoriesStatus.error,
          errorMessage: error.toString(),
        ),
      ),
      (categories) {
        if (categories.isEmpty) {
          emit(state.copyWith(status: CategoriesStatus.empty, categories: []));
        } else {
          emit(
            state.copyWith(
              status: CategoriesStatus.loaded,
              categories: categories,
            ),
          );
        }
      },
    );
  }

  Future<void> addCategory({
    required String name,
    required int iconCode,
    required int color,
  }) async {
    emit(state.copyWith(isAdding: true));
    final newCategory = Category(
      id: DateTime.now().millisecondsSinceEpoch
          .toString(), // Simple ID generation
      name: name,
      iconCode: iconCode,
      color: color,
    );
    final result = await addCategoryUseCase.call(newCategory);
    result.fold(
      (error) => emit(
        state.copyWith(isAdding: false, errorMessage: error.toString()),
      ), // Ideally show error via listener
      (_) {
        // Emit added state to trigger UI feedback
        emit(state.copyWith(status: CategoriesStatus.added, isAdding: false));
        // Then reload
        loadCategories();
      },
    );
  }

  Future<void> updateCategory(Category category) async {
    emit(state.copyWith(isAdding: true));
    final result = await updateCategoryUseCase.call(category);
    result.fold(
      (error) => emit(
        state.copyWith(
          isAdding: false,
          errorMessage: error.toString(),
          status: CategoriesStatus.error,
        ),
      ),
      (_) {
        emit(state.copyWith(status: CategoriesStatus.updated, isAdding: false));
        loadCategories();
      },
    );
  }

  Future<void> deleteCategory(String id) async {
    final result = await deleteCategoryUseCase.call(id);
    result.fold(
      (error) => emit(
        state.copyWith(
          errorMessage: 'Failed to delete',
          status: CategoriesStatus.error,
        ),
      ),
      (_) {
        emit(state.copyWith(status: CategoriesStatus.deleted));
        loadCategories();
      },
    );
  }
}
