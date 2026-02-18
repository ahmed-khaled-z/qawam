import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../config/language/language_manager.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/profile.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

class ProfileScreen extends StatelessWidget {
  static const routeName = "/profile";

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProfileCubit>()..loadProfile(),
      child: const _ProfileBody(),
    );
  }
}

class _ProfileBody extends StatefulWidget {
  const _ProfileBody();

  @override
  State<_ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<_ProfileBody>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime? _selectedDate;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );

    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _updateControllers(Profile profile) {
    if (_nameController.text != profile.name) {
      _nameController.text = profile.name;
    }
    if (_phoneController.text != profile.phoneNumber) {
      _phoneController.text = profile.phoneNumber;
    }
    if (_selectedDate != profile.dateOfBirth) {
      _selectedDate = profile.dateOfBirth;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state.status == ProfileStatus.loaded && state.profile != null) {
          _updateControllers(state.profile!);
        }
        if (state.status == ProfileStatus.saved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr('profile_saved_success')),
              backgroundColor: const Color(0xFF0D7377),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.status == ProfileStatus.loading) {
          return const Scaffold(
            backgroundColor: Color(0xFFF7F8FA),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF0D7377)),
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF7F8FA),
          appBar: _buildAppBar(context),
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildProfileHeader(state.profile),
                    const SizedBox(height: 32),
                    _buildFormSection(context, state),
                    const SizedBox(height: 40),
                    _buildDeleteButton(context),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: _buildBottomBar(context, state),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFF7F8FA),
      elevation: 0,
      centerTitle: true,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF2D2D3A),
            size: 18,
          ),
        ),
      ),
      title: Text(
        context.tr('nav_profile'),
        style: const TextStyle(
          color: Color(0xFF2D2D3A),
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _buildProfileHeader(Profile? profile) {
    final photoUrl = profile?.photoUrl;
    final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;

    return Column(
      children: [
        Hero(
          tag: 'profile_avatar',
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0D7377).withValues(alpha: 0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(color: Colors.white, width: 4),
            ),
            child: ClipOval(
              child: hasPhoto
                  ? Image.network(photoUrl, fit: BoxFit.cover)
                  : Container(
                      color: const Color(0xFFF0F2F5),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 64,
                        color: Color(0xFFB0B3C7),
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (profile?.email.isNotEmpty ?? false)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0D7377).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              profile!.email,
              style: const TextStyle(
                color: Color(0xFF0D7377),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFormSection(BuildContext context, ProfileState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, context.tr('basic_info_section')),
        const SizedBox(height: 16),
        _buildModernTextField(
          context: context,
          label: context.tr('profile_name'),
          controller: _nameController,
          icon: Icons.person_outline_rounded,
          onChanged: (v) => context.read<ProfileCubit>().updateField(name: v),
        ),
        const SizedBox(height: 20),
        _buildModernTextField(
          context: context,
          label: context.tr('profile_phone'),
          controller: _phoneController,
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          onChanged: (v) =>
              context.read<ProfileCubit>().updateField(phoneNumber: v),
        ),
        const SizedBox(height: 20),
        _buildDateField(context),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade500,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2D2D3A),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          icon: Icon(icon, color: const Color(0xFF0D7377), size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    final dateText = _selectedDate == null
        ? ''
        : DateFormat.yMMMd(
            languageManager.locale.languageCode,
          ).format(_selectedDate!);

    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime(2000),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFF0D7377),
                  onPrimary: Colors.white,
                  onSurface: Color(0xFF2D2D3A),
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          if (!context.mounted) return;
          setState(() => _selectedDate = picked);
          context.read<ProfileCubit>().updateField(dob: picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_month_rounded,
              color: Color(0xFF0D7377),
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('profile_dob'),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateText.isEmpty ? context.tr('select_date') : dateText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: dateText.isEmpty
                          ? Colors.grey.shade400
                          : const Color(0xFF2D2D3A),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.grey.shade300,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, ProfileState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFF7F8FA).withValues(alpha: 0),
            const Color(0xFFF7F8FA),
          ],
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton(
          onPressed: state.status == ProfileStatus.saving
              ? null
              : () => context.read<ProfileCubit>().saveProfile(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D7377),
            shadowColor: const Color(0xFF0D7377).withValues(alpha: 0.4),
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: state.status == ProfileStatus.saving
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  context.tr('save_changes'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: () => _confirmDelete(context),
        icon: Icon(
          Icons.delete_outline_rounded,
          size: 18,
          color: Colors.red.shade300,
        ),
        label: Text(
          context.tr('delete_account'),
          style: TextStyle(
            color: Colors.red.shade400,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          context.tr('delete_account_confirm_title'),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(
          context.tr('delete_account_confirm_msg'),
          style: TextStyle(color: Colors.grey.shade600, height: 1.5),
        ),
        actionsPadding: const EdgeInsets.all(20),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    context.tr('cancel'),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (context.mounted) {
                      context.read<ProfileCubit>().deleteAccount();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFEBEE),
                    foregroundColor: const Color(0xFFD32F2F),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    context.tr('delete'),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
