import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/domain/utils/project_progress_chart_builder.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/projects/providers/project_progress_provider.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/projects/widgets/progress_segment_style.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/projects/widgets/progress_strip_chart.dart';

class ProjectOverviewTab extends ConsumerWidget {
  const ProjectOverviewTab({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  final String projectId;
  final String projectName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (projectId.trim().isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Project ID is unavailable for this project.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final AsyncValue<ProjectProgressChartModel> progressAsync = ref.watch(
      projectProgressProvider(projectId),
    );

    return progressAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, StackTrace _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Unable to load project overview.\n$error',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () =>
                    ref.invalidate(projectProgressProvider(projectId)),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (ProjectProgressChartModel model) => _content(context, model),
    );
  }

  Widget _content(BuildContext context, ProjectProgressChartModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _CompactLegend(),
        const SizedBox(height: 8),
        Expanded(
          child: model.rows.isEmpty
              ? Center(
                  child: Text(
                    'No progress data available for this project.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                )
              : SingleChildScrollView(
                  child: ProgressStripChart(model: model),
                ),
        ),
      ],
    );
  }
}

class _CompactLegend extends StatelessWidget {
  const _CompactLegend();

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: progressLegendItems()
            .map(
              (ProgressLegendItem item) => Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: item.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    item.label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}
