import '../../domain/entities/expenses.dart';

class ExpensesModel extends Expenses {
  const ExpensesModel(
      {required String data})
      : super(data: data);

  ExpensesModel copyWith({
    String? data,
  }) {
    return ExpensesModel(
      data: data ?? this.data  ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    "data": data,
  };

  factory ExpensesModel.fromJson(Map<String, dynamic> json) => ExpensesModel(
    data: json["data"],
  );
}

