import '../../domain/entities/statistics.dart';

class StatisticsModel extends Statistics {
  const StatisticsModel(
      {required String data})
      : super(data: data);

  StatisticsModel copyWith({
    String? data,
  }) {
    return StatisticsModel(
      data: data ?? this.data  ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    "data": data,
  };

  factory StatisticsModel.fromJson(Map<String, dynamic> json) => StatisticsModel(
    data: json["data"],
  );
}

