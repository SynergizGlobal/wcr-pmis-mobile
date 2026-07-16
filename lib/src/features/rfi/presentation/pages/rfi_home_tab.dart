import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wcr_pmis_mobile/src/features/auth/domain/entities/auth_session.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/data/repositories/rfi_repository_impl.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/domain/entities/rfi_status_counts.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/domain/rfi_list_kind.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/domain/rfi_log/rfi_log_dashboard_filter.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/domain/utils/rfi_user_role.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/pages/rfi_list_page.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/providers/rfi_providers.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/rfi_theme.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/widgets/rfi_metric_card.dart';
import 'package:wcr_pmis_mobile/src/core/network/user_friendly_error_message.dart';

class RfiHomeTab extends ConsumerWidget {
  const RfiHomeTab({
    super.key,
    required this.role,
    required this.session,
    required this.onRetry,
  });

  final RfiUserRole role;
  final AuthSession? session;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<RfiDashboardSnapshot> dashboard =
        ref.watch(rfiDashboardProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(rfiHandoffProvider);
        ref.invalidate(rfiDashboardProvider);
        await ref.read(rfiHandoffProvider.future);
        await ref.read(rfiDashboardProvider.future);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(
            'Welcome to RFI System',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          if (session != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              session!.userName,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              session!.userRoleNameFk,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 20),
          dashboard.when(
            loading: () => const SizedBox(
              height: 280,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (Object error, StackTrace stack) => RfiHomeError(
              message: userFriendlyErrorMessage(error),
              onRetry: onRetry,
            ),
            data: (RfiDashboardSnapshot snapshot) => _MetricsGrid(
              role: role,
              createdCount: snapshot.createdCount.toString(),
              counts: snapshot.statusCounts,
              onOpenList: (RfiListKind kind) {
                context.pushNamed(
                  RfiListPage.routeName,
                  pathParameters: <String, String>{
                    'kind': kind.routeSegment,
                  },
                );
              },
              onOpenInspection: ({required bool rescheduledOnly}) {
                context.pushNamed(
                  'rfi-inspection',
                  extra: <String, dynamic>{
                    'rescheduledOnly': rescheduledOnly,
                  },
                );
              },
              onOpenRfiLog: (RfiLogDashboardFilter filter) {
                context.pushNamed('rfi-log', extra: filter);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class RfiHomeError extends StatelessWidget {
  const RfiHomeError({
    super.key,
    required this.message,
    required this.onRetry,
    this.title = 'Could not load RFI dashboard.',
  });

  final String title;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Icon(Icons.error_outline, size: 40, color: scheme.error),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({
    required this.role,
    required this.createdCount,
    required this.counts,
    required this.onOpenList,
    required this.onOpenInspection,
    required this.onOpenRfiLog,
  });

  final RfiUserRole role;
  final String createdCount;
  final RfiStatusCounts counts;
  final void Function(RfiListKind kind) onOpenList;
  final void Function({required bool rescheduledOnly}) onOpenInspection;
  final void Function(RfiLogDashboardFilter filter) onOpenRfiLog;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final List<Widget> cards = <Widget>[
      RfiMetricCard(
        count: createdCount,
        label: 'RFI Created',
        icon: Icons.check_circle_outline,
        iconColor: RfiTheme.metricCreated(scheme),
        onTap: () => onOpenList(RfiListKind.created),
      ),
      if (role.canViewScheduledRfi)
        RfiMetricCard(
          count: counts.scheduledCount.toString(),
          label: 'RFI Scheduled',
          icon: Icons.schedule,
          iconColor: RfiTheme.metricScheduled(scheme),
          onTap: () => onOpenInspection(rescheduledOnly: false),
        ),
      if (role.canViewRescheduledRfi)
        RfiMetricCard(
          count: counts.rescheduled.toString(),
          label: 'RFI Rescheduled',
          icon: Icons.calendar_month,
          iconColor: RfiTheme.metricRescheduled(scheme),
          onTap: () => onOpenInspection(rescheduledOnly: true),
        ),
      RfiMetricCard(
        count: counts.inspectedByCon.toString(),
        label: 'RFI Submitted',
        icon: Icons.send,
        iconColor: RfiTheme.metricSubmitted(scheme),
        onTap: () => onOpenList(RfiListKind.submitted),
      ),
      RfiMetricCard(
        count: counts.approved.toString(),
        label: 'RFI Approved',
        icon: Icons.check_circle_outline,
        iconColor: RfiTheme.metricApproved(scheme),
        onTap: () => onOpenRfiLog(RfiLogDashboardFilter.approved),
      ),
      RfiMetricCard(
        count: counts.rejected.toString(),
        label: 'RFI Rejected',
        icon: Icons.cancel_outlined,
        iconColor: RfiTheme.metricRejected(scheme),
        onTap: () => onOpenRfiLog(RfiLogDashboardFilter.rejected),
      ),
      RfiMetricCard(
        count: counts.closed.toString(),
        label: 'RFI Closed',
        icon: Icons.lock_outline,
        iconColor: RfiTheme.metricClosed(scheme),
        onTap: () => onOpenRfiLog(RfiLogDashboardFilter.closed),
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.05,
      children: cards,
    );
  }
}
