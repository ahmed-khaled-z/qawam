import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../config/language/language_manager.dart';
import '../../../../features/categories/domain/entities/category.dart';
import '../../../../features/categories/presentation/cubit/categories_cubit.dart';
import '../../../../features/categories/presentation/cubit/categories_state.dart';
import '../../domain/entities/expense.dart';
import '../cubit/home_cubit.dart';
import '../../../../features/settings/presentation/cubit/settings_cubit.dart';

class AddExpenseSheet extends StatefulWidget {
  final Expense? expenseToEdit;

  const AddExpenseSheet({super.key, this.expenseToEdit});

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  Category? _selectedCategory;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.expenseToEdit != null) {
      _amountController.text = widget.expenseToEdit!.amount.toStringAsFixed(2);
      _noteController.text = widget.expenseToEdit!.note;
      // Category initial selection handled in didChangeDependencies and BlocListener
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pre-select category if editing and categories are already loaded
    if (widget.expenseToEdit != null && _selectedCategory == null) {
      final state = context.read<CategoriesCubit>().state;
      if (state.categories.isNotEmpty) {
        try {
          _selectedCategory = state.categories.firstWhere(
            (c) => c.id == widget.expenseToEdit!.categoryId,
          );
        } catch (_) {}
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      final amount = double.parse(_amountController.text);
      final expense = Expense(
        id: widget.expenseToEdit?.id ?? const Uuid().v4(),
        amount: amount,
        date: widget.expenseToEdit?.date ?? DateTime.now(),
        categoryId: _selectedCategory!.id,
        note: _noteController.text,
        isSyncedToFirebase: widget.expenseToEdit?.isSyncedToFirebase ?? false,
      );

      if (widget.expenseToEdit != null) {
        try {
          context.read<HomeCubit>().addExpense(expense);
        } catch (e) {
          // Ignore
        }
      } else {
        context.read<HomeCubit>().addExpense(expense);
      }

      Navigator.pop(context);
    } else {
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('select_category_error'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyCode = context.select<SettingsCubit, String>(
      (cubit) => cubit.state.settings.currency,
    );
    final currencySymbol = NumberFormat.simpleCurrency(
      name: currencyCode,
    ).currencySymbol;

    return BlocListener<CategoriesCubit, CategoriesState>(
      listener: (context, state) {
        // Handle case where categories finish loading while sheet is open
        if (widget.expenseToEdit != null &&
            _selectedCategory == null &&
            state.categories.isNotEmpty) {
          try {
            final category = state.categories.firstWhere(
              (c) => c.id == widget.expenseToEdit!.categoryId,
            );
            setState(() {
              _selectedCategory = category;
            });
          } catch (_) {}
        }
      },
      child: Container(
        padding: EdgeInsets.only(
          top: 24,
          left: 24,
          right: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.expenseToEdit != null
                    ? context.tr('edit_expense')
                    : context.tr('add_new_expense'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2D3A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Amount
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: context.tr('amount'),
                  prefixIcon: SizedBox(
                    width: 50,
                    child: Center(
                      child: Text(
                        currencySymbol,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF0D7377),
                        ),
                      ),
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return context.tr('enter_amount_error');
                  }
                  if (double.tryParse(value) == null) {
                    return context.tr('enter_amount_error');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Category Selection
              Text(
                context.tr('nav_categories'),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 90,
                child: BlocBuilder<CategoriesCubit, CategoriesState>(
                  builder: (context, state) {
                    if (state.status == CategoriesStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.categories.isEmpty) {
                      return Center(
                        child: Text(context.tr('no_categories_desc')),
                      );
                    }

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: state.categories.length,
                      itemBuilder: (context, index) {
                        final category = state.categories[index];
                        final isSelected = _selectedCategory?.id == category.id;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          child: Container(
                            width: 70,
                            margin: const EdgeInsets.only(right: 12),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF0D7377)
                                        : Color(
                                            category.color,
                                          ).withOpacity(0.1),
                                    shape: BoxShape.circle,
                                    border: isSelected
                                        ? Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          )
                                        : null,
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: const Color(
                                                0xFF0D7377,
                                              ).withOpacity(0.4),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Icon(
                                    IconData(
                                      category.iconCode,
                                      fontFamily: 'MaterialIcons',
                                    ),
                                    color: isSelected
                                        ? Colors.white
                                        : Color(category.color),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  category.name,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isSelected
                                        ? const Color(0xFF0D7377)
                                        : Colors.grey,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Note
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: context.tr('notes'),
                  prefixIcon: const Icon(Icons.note),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D7377),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  widget.expenseToEdit != null
                      ? context.tr('save_changes')
                      : context.tr('add_new_expense'),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
