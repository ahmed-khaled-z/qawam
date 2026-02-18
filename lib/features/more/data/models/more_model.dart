import '../../domain/entities/more.dart';

class MoreModel extends More {
  const MoreModel(
      {required String data})
      : super(data: data);

  MoreModel copyWith({
    String? data,
  }) {
    return MoreModel(
      data: data ?? this.data  ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    "data": data,
  };

  factory MoreModel.fromJson(Map<String, dynamic> json) => MoreModel(
    data: json["data"],
  );
}

