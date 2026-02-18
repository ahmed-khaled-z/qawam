import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/language/language_manager.dart';
import '../../../../config/router/app_router.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/feature_request.dart';
import '../cubit/feature_request_cubit.dart';
import '../cubit/feature_request_state.dart';

class SuggestFeatureScreen extends StatelessWidget {
  static const routeName = '/suggest_feature';

  const SuggestFeatureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<FeatureRequestCubit>(),
      child: const _SuggestFeatureBody(),
    );
  }
}

class _SuggestFeatureBody extends StatefulWidget {
  const _SuggestFeatureBody();

  @override
  State<_SuggestFeatureBody> createState() => _SuggestFeatureBodyState();
}

class _SuggestFeatureBodyState extends State<_SuggestFeatureBody> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final _notesController = TextEditingController();

  static const _teal = Color(0xFF0D7377);
  static const _bg = Color(0xFFF7F8FA);

  @override
  void dispose() {
    _messageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context, isRTL),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildFormCard(context),
                      const SizedBox(height: 24),
                      Text(
                        context.tr('suggest_my_requests'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 12),
                      BlocBuilder<FeatureRequestCubit, FeatureRequestState>(
                        buildWhen: (a, b) =>
                            a.requests != b.requests || a.submitStatus != b.submitStatus,
                        builder: (context, state) {
                          if (state.requests.isEmpty &&
                              state.submitStatus != FeatureRequestSubmitStatus.loading) {
                            return _buildEmptyRequests(context);
                          }
                          return _buildRequestsList(context, state.requests);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isRTL) {
    return SliverAppBar(
      backgroundColor: _bg,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          isRTL ? Icons.arrow_forward_ios_rounded : Icons.arrow_back_ios_rounded,
          color: const Color(0xFF1A1A2E),
          size: 20,
        ),
        onPressed: () => AppRouter.pop(null),
      ),
      title: Text(
        context.tr('more_suggest'),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A1A2E),
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildFormCard(BuildContext context) {
    return BlocConsumer<FeatureRequestCubit, FeatureRequestState>(
      listenWhen: (a, b) => a.submitStatus != b.submitStatus,
      listener: (context, state) {
        if (state.submitStatus == FeatureRequestSubmitStatus.success) {
          _messageController.clear();
          _notesController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr('suggest_submitted')),
              behavior: SnackBarBehavior.floating,
              backgroundColor: _teal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(20),
            ),
          );
          context.read<FeatureRequestCubit>().clearSubmitState();
        }
        if (state.submitStatus == FeatureRequestSubmitStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.submitError ?? context.tr('error_occurred')),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(20),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.submitStatus == FeatureRequestSubmitStatus.loading;
        final canSubmit = state.canSubmit && !isLoading;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.tr('suggest_form_title'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _messageController,
                  maxLines: 3,
                  maxLength: 500,
                  decoration: InputDecoration(
                    hintText: context.tr('suggest_message_hint'),
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _teal, width: 2),
                    ),
                    filled: true,
                    fillColor: _bg,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return context.tr('suggest_message_required');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  maxLines: 2,
                  maxLength: 300,
                  decoration: InputDecoration(
                    hintText: context.tr('suggest_notes_hint'),
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _teal, width: 2),
                    ),
                    filled: true,
                    fillColor: _bg,
                  ),
                ),
                const SizedBox(height: 20),
                AnimatedOpacity(
                  opacity: canSubmit ? 1 : 0.7,
                  duration: const Duration(milliseconds: 200),
                  child: SizedBox(
                    height: 52,
                    child: FilledButton(
                      onPressed: canSubmit
                          ? () {
                              if (_formKey.currentState?.validate() ?? false) {
                                context.read<FeatureRequestCubit>().submit(
                                      message: _messageController.text,
                                      additionalNotes:
                                          _notesController.text.trim().isEmpty
                                              ? null
                                              : _notesController.text,
                                    );
                              }
                            }
                          : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: _teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              context.tr('suggest_submit'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyRequests(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            context.tr('suggest_no_requests'),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsList(BuildContext context, List<FeatureRequest> requests) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: requests.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final request = requests[index];
        return _RequestCard(request: request);
      },
    );
  }
}

class _RequestCard extends StatelessWidget {
  final FeatureRequest request;

  const _RequestCard({required this.request});

  static const _teal = Color(0xFF0D7377);

  Color _statusColor(FeatureRequestStatus status) {
    switch (status) {
      case FeatureRequestStatus.pending:
        return const Color(0xFFFFA726); // Yellow/Orange
      case FeatureRequestStatus.approved:
        return const Color(0xFF2196F3); // Blue
      case FeatureRequestStatus.rejected:
        return const Color(0xFFE53935); // Red
      case FeatureRequestStatus.implemented:
        return const Color(0xFF43A047); // Green
    }
  }

  String _statusLabel(BuildContext context, FeatureRequestStatus status) {
    switch (status) {
      case FeatureRequestStatus.pending:
        return context.tr('suggest_status_pending');
      case FeatureRequestStatus.approved:
        return context.tr('suggest_status_approved');
      case FeatureRequestStatus.rejected:
        return context.tr('suggest_status_rejected');
      case FeatureRequestStatus.implemented:
        return context.tr('suggest_status_implemented');
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(request.status);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    request.message,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1A2E),
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    _statusLabel(context, request.status),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            if (request.additionalNotes != null &&
                request.additionalNotes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                request.additionalNotes!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 8),
            Text(
              _formatDate(request.createdAt),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 0) return '${date.day}/${date.month}/${date.year}';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}
