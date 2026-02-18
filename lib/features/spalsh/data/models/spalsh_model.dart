import '../../domain/entities/spalsh.dart';

class SpalshModel extends Spalsh {
  const SpalshModel(
      {required String data})
      : super(data: data);

  SpalshModel copyWith({
    String? data,
  }) {
    return SpalshModel(
      data: data ?? this.data  ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    "data": data,
  };

  factory SpalshModel.fromJson(Map<String, dynamic> json) => SpalshModel(
    data: json["data"],
  );
}

