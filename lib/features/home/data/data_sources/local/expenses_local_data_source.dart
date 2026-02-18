import '../../models/expense_model.dart';

abstract class ExpensesLocalDataSource {
  Future<void> addExpense(ExpenseModel expense);
  Future<void> deleteExpense(String id);
  Future<List<ExpenseModel>> getAllExpenses();
}
