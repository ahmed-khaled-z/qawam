import 'package:hive/hive.dart';
import '../../models/expense_model.dart';
import 'expenses_local_data_source.dart';

class ExpensesLocalDataSourceImpl implements ExpensesLocalDataSource {
  static const String BOX_NAME = 'expenses';

  Box<ExpenseModel> get _box => Hive.box<ExpenseModel>(BOX_NAME);

  @override
  Future<void> addExpense(ExpenseModel expense) async {
    await _box.put(expense.id, expense);
  }

  @override
  Future<void> deleteExpense(String id) async {
    await _box.delete(id);
  }

  @override
  Future<List<ExpenseModel>> getAllExpenses() async {
    return _box.values.toList();
  }
}
