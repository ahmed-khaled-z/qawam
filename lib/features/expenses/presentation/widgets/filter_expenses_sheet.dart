import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../config/language/language_manager.dart';
import '../../../categories/presentation/cubit/categories_cubit.dart';
import '../../../categories/presentation/cubit/categories_state.dart';
import '../../domain/entities/expense_filters.dart';
import '../../../../features/settings/presentation/cubit/settings_cubit.dart';

class FilterExpensesSheet extends StatefulWidget {
  final ExpenseFilters currentFilters;
  final Function(ExpenseFilters) onApply;

  const FilterExpensesSheet({
    super.key,
    required this.currentFilters,
    required this.onApply,
  });

  @override
  State<FilterExpensesSheet> createState() => _FilterExpensesSheetState();
}

class _FilterExpensesSheetState extends State<FilterExpensesSheet> {
  late DateTime? _startDate;
  late DateTime? _endDate;
  late List<String> _selectedCategoryIds;
  late RangeValues _amountRange;
  static const double _maxAmount = 1000000.0;

  @override
  void initState() {
    super.initState();
    _startDate = widget.currentFilters.startDate;
    _endDate = widget.currentFilters.endDate;
    _selectedCategoryIds = List.from(widget.currentFilters.categoryIds);
    _amountRange = RangeValues(
      widget.currentFilters.minAmount ?? 0.0,
      widget.currentFilters.maxAmount ?? _maxAmount,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _applyFilters() {
    final filters = ExpenseFilters(
      startDate: _startDate,
      endDate: _endDate,
      categoryIds: _selectedCategoryIds,
      minAmount: _amountRange.start == 0.0 ? null : _amountRange.start,
      maxAmount: _amountRange.end == _maxAmount ? null : _amountRange.end,
    );

    widget.onApply(filters);
    Navigator.pop(context);
  }

  void _resetFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _selectedCategoryIds = [];
      _amountRange = RangeValues(0.0, _maxAmount);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyCode = context.select<SettingsCubit, String>(
      (cubit) => cubit.state.settings.currency,
    );

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildDateRangeSection(),
              const SizedBox(height: 24),
              _buildCategorySection(),
              const SizedBox(height: 24),
              _buildAmountSection(currencyCode),
              const SizedBox(height: 32),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          context.tr('filter_expenses'),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D3A),
          ),
        ),
        TextButton.icon(
          onPressed: _resetFilters,
          icon: const Icon(Icons.refresh, size: 18),
          label: Text(context.tr('reset')),
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF0D7377)),
        ),
      ],
    );
  }

  Widget _buildDateRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('date_range'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D2D3A),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _DatePickerButton(
                label: context.tr('start_date'),
                date: _startDate,
                onDateSelected: (date) => setState(() => _startDate = date),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DatePickerButton(
                label: context.tr('end_date'),
                date: _endDate,
                onDateSelected: (date) => setState(() => _endDate = date),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('categories'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D2D3A),
          ),
        ),
        const SizedBox(height: 12),
        BlocBuilder<CategoriesCubit, CategoriesState>(
          builder: (context, state) {
            if (state.categories.isEmpty) {
              return Text(
                context.tr('no_categories'),
                style: TextStyle(color: Colors.grey.shade500),
              );
            }

            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: state.categories.map((category) {
                final isSelected = _selectedCategoryIds.contains(category.id);
                return FilterChip(
                  label: Text(category.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedCategoryIds.add(category.id);
                      } else {
                        _selectedCategoryIds.remove(category.id);
                      }
                    });
                  },
                  selectedColor: Color(category.color).withOpacity(0.2),
                  checkmarkColor: Color(category.color),
                  side: BorderSide(
                    color: isSelected
                        ? Color(category.color)
                        : Colors.grey.shade300,
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAmountSection(String currencyCode) {
    final formatter = NumberFormat.simpleCurrency(
      locale: AppLocalizations.of(context)?.locale.toString(),
      name: currencyCode,
      decimalDigits: 0,
    );
    final sliderFormatter = NumberFormat('#,###');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('amount_range'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D2D3A),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              formatter.format(_amountRange.start.round()),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0D7377),
              ),
            ),
            Text(
              formatter.format(_amountRange.end.round()),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0D7377),
              ),
            ),
          ],
        ),
        RangeSlider(
          values: _amountRange,
          min: 0.0,
          max: _maxAmount,
          divisions: 1000,
          activeColor: const Color(0xFF0D7377),
          inactiveColor: const Color(0xFF0D7377).withOpacity(0.2),
          labels: RangeLabels(
            sliderFormatter.format(_amountRange.start.round()),
            sliderFormatter.format(_amountRange.end.round()),
          ),
          onChanged: (RangeValues values) {
            setState(() {
              _amountRange = values;
            });
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Color(0xFF0D7377)),
            ),
            child: Text(
              context.tr('cancel'),
              style: const TextStyle(
                color: Color(0xFF0D7377),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _applyFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D7377),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              context.tr('apply_filters'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DatePickerButton extends StatelessWidget {
  final String label;
  final DateTime? date;
  final Function(DateTime?) onDateSelected;

  const _DatePickerButton({
    required this.label,
    required this.date,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        final selected = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        onDateSelected(selected);
      },
      icon: const Icon(Icons.calendar_today, size: 16),
      label: Text(
        date != null ? '${date!.day}/${date!.month}/${date!.year}' : label,
        style: TextStyle(
          fontSize: 14,
          color: date != null ? const Color(0xFF2D2D3A) : Colors.grey.shade500,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        side: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }
}
