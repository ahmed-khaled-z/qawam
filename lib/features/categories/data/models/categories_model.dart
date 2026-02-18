import '../../domain/entities/categories.dart';

class CategoriesModel extends Categories {
  const CategoriesModel(
      {required String data})
      : super(data: data);

  CategoriesModel copyWith({
    String? data,
  }) {
    return CategoriesModel(
      data: data ?? this.data  ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    "data": data,
  };

  factory CategoriesModel.fromJson(Map<String, dynamic> json) => CategoriesModel(
    data: json["data"],
  );
}

