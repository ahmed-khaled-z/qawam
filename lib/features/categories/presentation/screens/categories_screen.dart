import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/category.dart';
import '../cubit/categories_cubit.dart';
import '../cubit/categories_state.dart';
import '../widgets/add_category_sheet.dart';
import '../../../../config/language/language_manager.dart';

class CategoriesScreen extends StatefulWidget {
  static const routeName = "/categories";

  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    // CategoriesCubit is provided in BottomNavScreen
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: Text(
          context.tr('nav_categories'),
          style: const TextStyle(
            color: Color(0xFF2D2D3A),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFF7F8FA),
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButton: Builder(
        builder: (ctx) => FloatingActionButton.extended(
          onPressed: () => _showCategorySheet(ctx, null),
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: Text(
            context.tr('add_category'),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF0D7377),
        ),
      ),
      body: const CategoriesView(),
    );
  }

  void _showCategorySheet(BuildContext context, Category? category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddCategorySheet(
        categoryToEdit: category,
        onSave: (name, iconCode, color) {
          if (category == null) {
            context.read<CategoriesCubit>().addCategory(
              name: name,
              iconCode: iconCode,
              color: color,
            );
          } else {
            final updated = Category(
              id: category.id,
              name: name,
              iconCode: iconCode,
              color: color,
              isSyncedToFirebase: category.isSyncedToFirebase,
            );
            context.read<CategoriesCubit>().updateCategory(updated);
          }
        },
      ),
    );
  }
}

class CategoriesView extends StatelessWidget {
  const CategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CategoriesCubit, CategoriesState>(
      listener: (context, state) {
        if (state.errorMessage != null &&
            state.status == CategoriesStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
        if (state.status == CategoriesStatus.added) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr('category_added_success')),
              backgroundColor: const Color(0xFF0D7377),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
        if (state.status == CategoriesStatus.updated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr('category_updated_success')),
              backgroundColor: const Color(0xFF0D7377),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
        if (state.status == CategoriesStatus.deleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr('category_deleted_success')),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.status == CategoriesStatus.loading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF0D7377)),
          );
        }

        if (state.status == CategoriesStatus.empty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.category_outlined,
                  size: 80,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  context.tr('no_categories_title'),
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr('no_categories_desc'),
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (state.status == CategoriesStatus.loaded ||
            state.status == CategoriesStatus.added ||
            state.status == CategoriesStatus.updated ||
            state.status == CategoriesStatus.deleted) {
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            itemCount: state.categories.length,
            itemBuilder: (context, index) {
              final category = state.categories[index];
              return _CategoryCard(
                category: category,
                onTap: () => _showOptions(context, category),
              );
            },
            physics: const BouncingScrollPhysics(),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _showOptions(BuildContext context, Category category) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: Text(context.tr('edit_category')),
              onTap: () {
                Navigator.pop(ctx);
                // Call _showCategorySheet from here?
                // But _showCategorySheet is in _CategoriesScreenState.
                // I need to access it.
                // Or I can duplicate logic or make it static or extract it.
                // Extracted below.
                _showCategorySheet(context, category);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(
                context.tr('delete'), // Ensure 'delete' key exists
                style: const TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDelete(context, category);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCategorySheet(BuildContext context, Category? category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddCategorySheet(
        categoryToEdit: category,
        onSave: (name, iconCode, color) {
          if (category == null) {
            context.read<CategoriesCubit>().addCategory(
              name: name,
              iconCode: iconCode,
              color: color,
            );
          } else {
            final updated = Category(
              id: category.id,
              name: name,
              iconCode: iconCode,
              color: color,
              isSyncedToFirebase: category.isSyncedToFirebase,
            );
            context.read<CategoriesCubit>().updateCategory(updated);
          }
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.tr('delete')),
        content: Text(context.tr('delete_category_confirm')),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              context.tr('cancel'),
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<CategoriesCubit>().deleteCategory(category.id);
              Navigator.pop(context);
            },
            child: Text(
              context.tr('delete'),
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;

  const _CategoryCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(category.color).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  category.isSyncedToFirebase
                      ? Icons.check_circle
                      : Icons.cloud_off,
                  size: 18,
                  color: category.isSyncedToFirebase
                      ? Colors.green
                      : Colors.grey.shade400,
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(category.color).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        IconData(
                          category.iconCode,
                          fontFamily: 'MaterialIcons',
                        ),
                        color: Color(category.color),
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        category.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF2D2D3A),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
