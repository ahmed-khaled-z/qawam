import '../../domain/entities/bottom_nav.dart';

class BottomNavModel extends BottomNav {
  const BottomNavModel({required String data}) : super(data: data);

  BottomNavModel copyWith({String? data}) {
    return BottomNavModel(data: data ?? this.data ?? '');
  }

  Map<String, dynamic> toJson() => {"data": data};

  factory BottomNavModel.fromJson(Map<String, dynamic> json) =>
      BottomNavModel(data: json["data"]);
}
