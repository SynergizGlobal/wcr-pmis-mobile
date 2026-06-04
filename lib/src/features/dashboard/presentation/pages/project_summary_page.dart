import 'package:flutter/material.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/pages/daily_progress_tab.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/pages/project_overview_tab.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/pages/site_photos_tab.dart';

class ProjectSummaryArgs {
  const ProjectSummaryArgs({
    required this.projectTypeName,
    required this.projectName,
    required this.projectId,
  });

  final String projectTypeName;
  final String projectName;
  final String projectId;
}

enum _SummaryTab {
  projectOverview('Project Overview', Icons.dashboard_rounded),
  dailyProgress('Daily Progress', Icons.trending_up_rounded),
  sitePhotos('Site Photos', Icons.photo_library_rounded),
  executionOverview('Execution Overview', Icons.engineering_rounded),
  progressTable('Progress Table', Icons.table_chart_rounded);

  const _SummaryTab(this.label, this.icon);

  final String label;
  final IconData icon;
}

class ProjectSummaryPage extends StatefulWidget {
  const ProjectSummaryPage({super.key, required this.args});

  static const String routeName = 'project-summary';
  static const String routePath = '/project-summary';

  final ProjectSummaryArgs args;

  @override
  State<ProjectSummaryPage> createState() => _ProjectSummaryPageState();
}

class _ProjectSummaryPageState extends State<ProjectSummaryPage> {
  _SummaryTab _selectedTab = _SummaryTab.projectOverview;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    final String projectName = widget.args.projectName.trim();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Project Summary',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                height: 1.15,
              ),
            ),
            if (projectName.isNotEmpty) ...<Widget>[
              const SizedBox(height: 4),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      projectName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        height: 1.15,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _tabStrip(context),
          Divider(
            height: 1,
            thickness: 1,
            color: cs.outlineVariant.withValues(alpha: isDark ? 0.35 : 0.45),
          ),
          Expanded(child: _tabBody()),
        ],
      ),
    );
  }

  Widget _tabStrip(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isDark
              ? cs.surfaceContainerHighest.withValues(alpha: 0.45)
              : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: isDark ? 0.35 : 0.55),
          ),
          boxShadow: isDark
              ? null
              : <BoxShadow>[
                  BoxShadow(
                    color: cs.shadow.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List<Widget>.generate(_SummaryTab.values.length, (
                int index,
              ) {
                final _SummaryTab tab = _SummaryTab.values[index];
                final bool selected = tab == _selectedTab;
                return Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 0 : 4,
                    right: index == _SummaryTab.values.length - 1 ? 0 : 4,
                  ),
                  child: _SummaryTabPill(
                    label: tab.label,
                    icon: tab.icon,
                    selected: selected,
                    onTap: () => setState(() => _selectedTab = tab),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tabBody() {
    return switch (_selectedTab) {
      _SummaryTab.projectOverview => Padding(
        padding: const EdgeInsets.all(12),
        child: ProjectOverviewTab(
          projectId: widget.args.projectId,
          projectName: widget.args.projectName,
        ),
      ),
      _SummaryTab.dailyProgress => Padding(
        padding: const EdgeInsets.all(12),
        child: DailyProgressTab(
          projectId: widget.args.projectId,
          projectName: widget.args.projectName,
        ),
      ),
      _SummaryTab.sitePhotos => Padding(
        padding: const EdgeInsets.all(12),
        child: SitePhotosTab(projectId: widget.args.projectId),
      ),
      _ => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            '${_selectedTab.label} will be available in a future update.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
    };
  }
}

class _SummaryTabPill extends StatelessWidget {
  const _SummaryTabPill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    final Color selectedBackground = cs.primary;
    final Color selectedForeground = cs.onPrimary;
    final Color unselectedForeground = isDark
        ? cs.onSurface.withValues(alpha: 0.78)
        : cs.onSurface.withValues(alpha: 0.72);
    final Color unselectedIcon = isDark
        ? cs.onSurfaceVariant.withValues(alpha: 0.95)
        : cs.onSurface.withValues(alpha: 0.58);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? selectedBackground
                : (isDark ? cs.surface.withValues(alpha: 0.35) : cs.surface),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? selectedBackground.withValues(alpha: 0.9)
                  : cs.outlineVariant.withValues(alpha: isDark ? 0.4 : 0.65),
            ),
            boxShadow: selected && !isDark
                ? <BoxShadow>[
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.22),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                icon,
                size: 16,
                color: selected ? selectedForeground : unselectedIcon,
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: selected ? selectedForeground : unselectedForeground,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  fontSize: 13,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
