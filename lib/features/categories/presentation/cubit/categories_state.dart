import '../../domain/entities/category.dart';

enum CategoriesStatus {
  initial,
  loading,
  loaded,
  empty,
  error,
  added,
  updated,
  deleted,
}

class CategoriesState {
  final CategoriesStatus status;
  final List<Category> categories;
  final String? errorMessage;
  final bool isAdding;

  const CategoriesState({
    this.status = CategoriesStatus.initial,
    this.categories = const [],
    this.errorMessage,
    this.isAdding = false,
  });

  CategoriesState copyWith({
    CategoriesStatus? status,
    List<Category>? categories,
    String? errorMessage,
    bool? isAdding,
  }) {
    return CategoriesState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      errorMessage: errorMessage ?? this.errorMessage,
      isAdding: isAdding ?? this.isAdding,
    );
  }
}
