import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_select_sheet_field.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/domain/entities/home_dashboard_data.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/pages/project_summary_page.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/providers/project_details_provider.dart';

class ProjectDetailsPage extends ConsumerStatefulWidget {
  const ProjectDetailsPage({super.key, required this.projectTypeName});

  static const String routeName = 'project-details';
  static const String routePath = '/project-details';

  final String projectTypeName;

  @override
  ConsumerState<ProjectDetailsPage> createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends ConsumerState<ProjectDetailsPage>
    with SingleTickerProviderStateMixin {
  String? _selectedProject;
  final ScrollController _horizontalScrollController = ScrollController();
  late final AnimationController _arrowBounceController;
  bool _isAtTableEnd = false;

  @override
  void initState() {
    super.initState();
    _horizontalScrollController.addListener(_handleHorizontalScroll);
    _arrowBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleHorizontalScroll();
    });
  }

  @override
  void dispose() {
    _horizontalScrollController.removeListener(_handleHorizontalScroll);
    _horizontalScrollController.dispose();
    _arrowBounceController.dispose();
    super.dispose();
  }

  void _handleHorizontalScroll() {
    if (!_horizontalScrollController.hasClients) {
      return;
    }
    final bool atEnd =
        _horizontalScrollController.position.pixels >=
        _horizontalScrollController.position.maxScrollExtent - 1;
    if (atEnd != _isAtTableEnd && mounted) {
      setState(() {
        _isAtTableEnd = atEnd;
      });
    }
  }

  Future<void> _toggleTableSide() async {
    if (!_horizontalScrollController.hasClients) {
      return;
    }
    final double target = _isAtTableEnd
        ? 0
        : _horizontalScrollController.position.maxScrollExtent;
    await _horizontalScrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  void _openProjectSummary(ProjectDetailsData data) {
    final String? projectName = _selectedProject;
    if (projectName == null) {
      return;
    }
    final String projectId = data.projectIdsByName[projectName]?.trim() ?? '';
    context.pushNamed(
      ProjectSummaryPage.routeName,
      extra: ProjectSummaryArgs(
        projectTypeName: widget.projectTypeName,
        projectName: projectName,
        projectId: projectId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<ProjectDetailsData> detailsAsync = ref.watch(
      projectDetailsProvider(widget.projectTypeName),
    );
    final String heading =
        'Overall Status of Major Items in ${widget.projectTypeName} Projects';

    return Scaffold(
      appBar: AppBar(title: const Text('Project Details')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: detailsAsync.when(
            data: (ProjectDetailsData data) => _content(context, heading, data),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (Object error, StackTrace _) => Center(
              child: Text(
                'Unable to load project details.\n$error',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(
    BuildContext context,
    String heading,
    ProjectDetailsData data,
  ) {
    final bool hasProjects = data.projectNames.isNotEmpty;
    final List<String> dropdownItems = hasProjects
        ? data.projectNames
        : <String>[];
    if (!hasProjects) {
      _selectedProject = null;
    } else if (_selectedProject == null ||
        !dropdownItems.contains(_selectedProject)) {
      _selectedProject = dropdownItems.first;
    }

    final List<ProjectMajorItem> visibleItems =
        !hasProjects || _selectedProject == null
        ? <ProjectMajorItem>[]
        : data.items
              .where(
                (ProjectMajorItem item) => item.projectName == _selectedProject,
              )
              .toList();

    final bool showBounceArrowHint = !kIsWeb && defaultTargetPlatform != TargetPlatform.iOS;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          heading,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        AppSelectSheetField<String>(
          key: ValueKey<String?>(
            dropdownItems.contains(_selectedProject) ? _selectedProject : null,
          ),
          label: 'Project',
          title: 'Select Project',
          leadingIcon: Icons.work_outline_rounded,
          items: dropdownItems,
          value: dropdownItems.contains(_selectedProject)
              ? _selectedProject
              : null,
          itemLabelBuilder: (String value) => value,
          enabled: hasProjects,
          placeholderText: hasProjects
              ? 'Select project'
              : 'No projects available',
          onChanged: (String value) => setState(() => _selectedProject = value),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: FilledButton.tonalIcon(
            onPressed: _selectedProject == null
                ? null
                : () => _openProjectSummary(data),
            icon: const Icon(Icons.analytics_outlined),
            label: const Text('Project Summary'),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double tableWidth = constraints.maxWidth < 760
                  ? 760
                  : constraints.maxWidth;
              final _TableWidths widths = _resolveTableWidths(tableWidth);

              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Theme.of(context).colorScheme.surface,
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: <Widget>[
                    Scrollbar(
                      controller: _horizontalScrollController,
                      thumbVisibility: true,
                      trackVisibility: true,
                      interactive: true,
                      notificationPredicate: (ScrollNotification notification) =>
                          notification.metrics.axis == Axis.horizontal,
                      child: SingleChildScrollView(
                        controller: _horizontalScrollController,
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: tableWidth,
                          child: ListView(
                            children: <Widget>[
                              _headerRow(context, widths),
                              ...visibleItems.asMap().entries.map(
                                (MapEntry<int, ProjectMajorItem> entry) =>
                                    _itemRow(entry.value, entry.key, widths),
                              ),
                              if (visibleItems.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Text(
                                    'No data available for selected project.',
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (visibleItems.isNotEmpty && showBounceArrowHint)
                      Positioned.fill(
                        child: Align(
                          alignment: _isAtTableEnd
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: AnimatedBuilder(
                              animation: _arrowBounceController,
                              builder: (BuildContext context, Widget? child) {
                                final double bounceOffset =
                                    _arrowBounceController.value * 8;
                                return Transform.translate(
                                  offset: Offset(
                                    _isAtTableEnd ? bounceOffset : -bounceOffset,
                                    0,
                                  ),
                                  child: child,
                                );
                              },
                              child: Material(
                                elevation: 4,
                                shape: const CircleBorder(),
                                color: Theme.of(context).colorScheme.primary,
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: _toggleTableSide,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Icon(
                                      _isAtTableEnd
                                          ? Icons.arrow_back_ios_new_rounded
                                          : Icons.arrow_forward_ios_rounded,
                                      size: 16,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  _TableWidths _resolveTableWidths(double totalWidth) {
    const double horizontalRowPadding = 20;
    final double contentWidth = (totalWidth - horizontalRowPadding).clamp(
      0,
      double.infinity,
    );
    const double unit = 70;
    const double scope = 120;
    const double completed = 110;
    const double progress = 110;
    const double tdc = 120;
    final double item =
        (contentWidth - (unit + scope + completed + progress + tdc))
        .clamp(170, double.infinity);
    return _TableWidths(
      item: item,
      unit: unit,
      scope: scope,
      completed: completed,
      progress: progress,
      tdc: tdc,
    );
  }

  Widget _headerRow(BuildContext context, _TableWidths widths) {
    final Color headerColor = Theme.of(context).colorScheme.primary;
    const TextStyle textStyle = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w700,
    );
    return Container(
      color: headerColor,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      child: Row(
        children: <Widget>[
          SizedBox(width: widths.item, child: const Text('Item', style: textStyle)),
          SizedBox(width: widths.unit, child: const Text('Unit', style: textStyle)),
          SizedBox(width: widths.scope, child: const Text('Scope', style: textStyle)),
          SizedBox(
            width: widths.completed,
            child: const Text('Completed', style: textStyle),
          ),
          SizedBox(
            width: widths.progress,
            child: const Text('Progress %', style: textStyle),
          ),
          SizedBox(width: widths.tdc, child: const Text('TDC', style: textStyle)),
        ],
      ),
    );
  }

  Widget _itemRow(ProjectMajorItem item, int index, _TableWidths widths) {
    const TextStyle style = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
    );
    final Color rowColor = index.isEven
        ? Colors.transparent
        : Theme.of(context).colorScheme.primary.withValues(alpha: 0.12);
    return Container(
      color: rowColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(width: widths.item, child: Text(item.item, style: style)),
            SizedBox(width: widths.unit, child: Text(item.unit, style: style)),
            SizedBox(width: widths.scope, child: Text(item.scope, style: style)),
            SizedBox(
              width: widths.completed,
              child: Text(item.completed, style: style),
            ),
            SizedBox(
              width: widths.progress,
              child: Text(item.progressPercent, style: style),
            ),
            SizedBox(width: widths.tdc, child: Text(item.tdc, style: style)),
          ],
        ),
      ),
    );
  }
}

class _TableWidths {
  const _TableWidths({
    required this.item,
    required this.unit,
    required this.scope,
    required this.completed,
    required this.progress,
    required this.tdc,
  });

  final double item;
  final double unit;
  final double scope;
  final double completed;
  final double progress;
  final double tdc;
}
