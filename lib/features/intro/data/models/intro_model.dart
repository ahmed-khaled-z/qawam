import '../../domain/entities/intro.dart';

class IntroModel extends Intro {
  const IntroModel(
      {required String data})
      : super(data: data);

  IntroModel copyWith({
    String? data,
  }) {
    return IntroModel(
      data: data ?? this.data  ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    "data": data,
  };

  factory IntroModel.fromJson(Map<String, dynamic> json) => IntroModel(
    data: json["data"],
  );
}

