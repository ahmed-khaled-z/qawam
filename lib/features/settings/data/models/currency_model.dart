import '../../domain/entities/currency.dart';

class CurrencyModel extends Currency {
  const CurrencyModel({
    required super.code,
    required super.name,
    required super.flag,
  });

  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
    return CurrencyModel(
      code: json['code'] as String,
      name: json['name'] as String,
      flag: json['flag'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'code': code, 'name': name, 'flag': flag};
  }
}
