import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wcr_pmis_mobile/src/app/config/app_config.dart';
import 'package:wcr_pmis_mobile/src/app/theme/app_theme.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_action_card.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_dialog.dart';
import 'package:wcr_pmis_mobile/src/features/auth/domain/entities/auth_session.dart';
import 'package:wcr_pmis_mobile/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/domain/entities/home_dashboard_data.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/domain/entities/update_form_item.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/pages/project_details_page.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/providers/home_dashboard_provider.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/providers/update_forms_provider.dart';
import 'package:wcr_pmis_mobile/src/features/profile/presentation/pages/profile_page.dart';
import 'package:wcr_pmis_mobile/src/features/settings/presentation/providers/dashboard_view_mode_provider.dart';

enum _HomeSection {
  home,
  updateForms,
  reports,
  documents,
  quickLinks,
  admin,
  rfi,
}

class _DashboardCardSpec {
  const _DashboardCardSpec({
    required this.title,
    this.icon,
    this.leftPlaceholder,
    this.rightPlaceholder,
    this.payload,
  });

  final String title;
  final IconData? icon;
  final Widget? leftPlaceholder;
  final Widget? rightPlaceholder;
  final Object? payload;
}

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  static const String routeName = 'dashboard';
  static const String routePath = '/';

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int _selectedIndex = 0;
  _HomeSection _section = _HomeSection.home;

  void _onBottomSelected(int index) {
    if (index == 3) {
      _openMoreMenu();
      return;
    }
    setState(() {
      _selectedIndex = index;
      _section = switch (index) {
        0 => _HomeSection.home,
        1 => _HomeSection.updateForms,
        _ => _HomeSection.reports,
      };
    });
  }

  Future<void> _openMoreMenu() async {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final _HomeSection? result = await showModalBottomSheet<_HomeSection>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: colorScheme.surface,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _moreItem(_HomeSection.documents, Icons.description_outlined),
              _moreItem(_HomeSection.quickLinks, Icons.link_rounded),
              _moreItem(
                _HomeSection.admin,
                Icons.admin_panel_settings_outlined,
              ),
              _moreItem(_HomeSection.rfi, Icons.support_agent_outlined),
            ],
          ),
        );
      },
    );
    if (result == null || !mounted) {
      return;
    }
    setState(() {
      _section = result;
      _selectedIndex = 3;
    });
  }

  Widget _moreItem(_HomeSection section, IconData icon) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Icon(icon, color: colorScheme.onSurface),
      title: Text(_titleForSection(section)),
      trailing: Icon(Icons.chevron_right_rounded, color: colorScheme.onSurface),
      onTap: () => Navigator.of(context).pop(section),
    );
  }

  String _titleForSection(_HomeSection section) {
    return switch (section) {
      _HomeSection.home => 'Western Central Railways',
      _HomeSection.updateForms => 'Update Forms',
      _HomeSection.reports => 'Reports',
      _HomeSection.documents => 'Documents',
      _HomeSection.quickLinks => 'Quick Links',
      _HomeSection.admin => 'Admin',
      _HomeSection.rfi => 'RFI',
    };
  }

  @override
  Widget build(BuildContext context) {
    final AuthSession? session = ref.watch(authControllerProvider).valueOrNull;
    final AsyncValue<HomeDashboardData> homeDataAsync = ref.watch(
      homeDashboardProvider,
    );
    final AsyncValue<List<UpdateFormItem>> updateFormsAsync = ref.watch(
      updateFormsProvider,
    );
    final DashboardViewMode viewMode = ref.watch(dashboardViewModeProvider);
    final String pageTitle = _titleForSection(_section);
    final AppPalette palette =
        Theme.of(context).extension<AppPalette>() ?? AppPalette.light;
    final String initial = _avatarInitial(session);

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 64,
        title: Text(
          pageTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 10, top: 8, bottom: 8, right: 4),
          child: Image.asset('assets/app_icon.png', fit: BoxFit.contain),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(29),
              onTap: () => context.pushNamed(ProfilePage.routeName),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: palette.avatarFill,
                child: Text(
                  initial,
                  style: TextStyle(
                    fontSize: 22,
                    color: palette.avatarText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: _section == _HomeSection.home
                ? _buildHomeSection(
                    viewKey: ValueKey<String>('home-${viewMode.name}'),
                    homeDataAsync: homeDataAsync,
                    viewMode: viewMode,
                  )
                : _section == _HomeSection.updateForms
                ? _buildUpdateFormsSection(
                    viewKey: ValueKey<String>('update-forms-${viewMode.name}'),
                    updateFormsAsync: updateFormsAsync,
                    viewMode: viewMode,
                  )
                : _sectionCardsScreen(
                    viewKey: ValueKey<String>(
                      '${_section.name}-${viewMode.name}',
                    ),
                    cards: _cardsForSection(_section),
                    viewMode: viewMode,
                  ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.20),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Container(
                color: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: <Widget>[
                    _bottomItem(
                      index: 0,
                      label: 'Home',
                      icon: Icons.home_outlined,
                      selectedIcon: Icons.home_rounded,
                    ),
                    _bottomItem(
                      index: 1,
                      label: 'Update Forms',
                      icon: Icons.edit_document,
                      selectedIcon: Icons.edit_document,
                    ),
                    _bottomItem(
                      index: 2,
                      label: 'Reports',
                      icon: Icons.bar_chart_rounded,
                      selectedIcon: Icons.bar_chart_rounded,
                    ),
                    _bottomItem(
                      index: 3,
                      label: 'More',
                      icon: Icons.grid_view_rounded,
                      selectedIcon: Icons.grid_view_rounded,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<_DashboardCardSpec> _cardsForSection(_HomeSection section) {
    return switch (section) {
      _HomeSection.home => const <_DashboardCardSpec>[],
      _HomeSection.updateForms => const <_DashboardCardSpec>[],
      _HomeSection.reports => <_DashboardCardSpec>[
        _DashboardCardSpec(
          title: 'Monthly Summary',
          icon: Icons.summarize_rounded,
        ),
        _DashboardCardSpec(
          title: 'Section Analytics',
          icon: Icons.analytics_outlined,
        ),
        _DashboardCardSpec(
          title: 'Exception Report',
          rightPlaceholder: const Icon(Icons.warning_amber_rounded),
        ),
        _DashboardCardSpec(title: 'Export Data', icon: Icons.download_rounded),
      ],
      _HomeSection.documents => <_DashboardCardSpec>[
        _DashboardCardSpec(title: 'Circulars', icon: Icons.article_outlined),
        _DashboardCardSpec(
          title: 'Technical Docs',
          icon: Icons.menu_book_rounded,
        ),
        _DashboardCardSpec(title: 'Approvals', icon: Icons.approval_rounded),
      ],
      _HomeSection.quickLinks => <_DashboardCardSpec>[
        _DashboardCardSpec(
          title: 'Emergency Contacts',
          icon: Icons.call_outlined,
        ),
        _DashboardCardSpec(title: 'HQ Portal', icon: Icons.language_rounded),
        _DashboardCardSpec(
          title: 'Live Tracking',
          icon: Icons.location_searching,
        ),
      ],
      _HomeSection.admin => <_DashboardCardSpec>[
        _DashboardCardSpec(
          title: 'User Management',
          icon: Icons.manage_accounts_rounded,
        ),
        _DashboardCardSpec(
          title: 'Access Control',
          icon: Icons.lock_person_outlined,
        ),
        _DashboardCardSpec(
          title: 'Audit Logs',
          icon: Icons.fact_check_outlined,
        ),
      ],
      _HomeSection.rfi => <_DashboardCardSpec>[
        _DashboardCardSpec(
          title: 'Open RFIs',
          icon: Icons.mark_email_unread_outlined,
        ),
        _DashboardCardSpec(
          title: 'Closed RFIs',
          icon: Icons.mark_email_read_outlined,
        ),
        _DashboardCardSpec(
          title: 'Escalations',
          icon: Icons.trending_up_rounded,
        ),
      ],
    };
  }

  Widget _buildHomeSection({
    Key? viewKey,
    required AsyncValue<HomeDashboardData> homeDataAsync,
    required DashboardViewMode viewMode,
  }) {
    return homeDataAsync.when(
      data: (HomeDashboardData data) {
        final int derivedProjectsCount = data.projectTypes.fold<int>(
          0,
          (int sum, HomeProjectType type) => sum + type.cumulativeCount,
        );
        final int totalProjects = data.overview.projectsCount > 0
            ? data.overview.projectsCount
            : derivedProjectsCount;
        return Column(
          key: viewKey,
          children: <Widget>[
            _homeSummaryStats(
              projectsCount: totalProjects,
              totalLength: data.overview.totalLength,
              commissionedLength: data.overview.commissionedLength,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Stack(
                children: <Widget>[
                  IgnorePointer(
                    child: Center(
                      child: Opacity(
                        opacity: 0.10,
                        child: Image.asset(
                          'assets/wcr_watermark.png',
                          width: 220,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  _sectionCardsScreen(
                    cards: _homeTypeCardsFromData(data),
                    viewMode: viewMode,
                  ),
                ],
              ),
            ),
          ],
        );
      },
      loading: () => ListView(
        key: viewKey,
        children: const <Widget>[
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      ),
      error: (Object error, StackTrace _) => ListView(
        key: viewKey,
        children: <Widget>[
          AppActionCard(
            title: 'Unable to load home data (tap for error)',
            icon: Icons.wifi_off_rounded,
            rightPlaceholder: const Icon(Icons.refresh_rounded),
            onTap: () async {
              debugPrint('[DashboardUI] homeDashboardProvider error: $error');
              await AppDialog.show(
                context: context,
                title: 'Home Load Error',
                message: error.toString(),
                type: AppDialogType.error,
                actions: <AppDialogAction>[
                  AppDialogAction(
                    label: 'Retry',
                    isPrimary: true,
                    onPressed: () => ref.invalidate(homeDashboardProvider),
                  ),
                  const AppDialogAction(label: 'Close'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateFormsSection({
    Key? viewKey,
    required AsyncValue<List<UpdateFormItem>> updateFormsAsync,
    required DashboardViewMode viewMode,
  }) {
    return updateFormsAsync.when(
      data: (List<UpdateFormItem> forms) {
        final List<_DashboardCardSpec> cards = forms
            .map(
              (UpdateFormItem item) => _DashboardCardSpec(
                title: item.formName,
                payload: item,
                icon: null,
                leftPlaceholder: _updateFormAssetIcon(item),
              ),
            )
            .toList();
        if (cards.isEmpty) {
          return ListView(
            key: viewKey,
            children: const <Widget>[
              AppActionCard(title: 'No update forms available right now.'),
            ],
          );
        }
        return _sectionCardsScreen(
          viewKey: viewKey,
          cards: cards,
          viewMode: viewMode,
        );
      },
      loading: () => ListView(
        key: viewKey,
        children: const <Widget>[
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      ),
      error: (Object error, StackTrace _) => ListView(
        key: viewKey,
        children: <Widget>[
          AppActionCard(
            title: 'Unable to load update forms',
            icon: Icons.wifi_off_rounded,
            rightPlaceholder: const Icon(Icons.refresh_rounded),
            onTap: () => ref.invalidate(updateFormsProvider),
          ),
        ],
      ),
    );
  }

  List<_DashboardCardSpec> _homeTypeCardsFromData(HomeDashboardData data) {
    final List<_DashboardCardSpec> cards = <_DashboardCardSpec>[];
    for (final HomeProjectType type in data.projectTypes) {
      cards.add(
        _DashboardCardSpec(title: '${type.name} (${type.cumulativeCount})'),
      );
    }
    return cards;
  }

  Widget _homeSummaryStats({
    required int projectsCount,
    required double totalLength,
    required double commissionedLength,
  }) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _summaryStatCard(
            label: 'Projects',
            value: projectsCount.toString(),
            icon: Icons.approval_rounded,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _summaryStatCard(
            label: 'Length',
            value: '${totalLength.toStringAsFixed(2)} km',
            icon: Icons.straighten_rounded,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _summaryStatCard(
            label: 'Commissioned',
            value: '${commissionedLength.toStringAsFixed(2)} km',
            icon: Icons.track_changes_rounded,
          ),
        ),
      ],
    );
  }

  Widget _summaryStatCard({
    required String label,
    required String value,
    required IconData icon,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCardsScreen({
    Key? viewKey,
    required List<_DashboardCardSpec> cards,
    required DashboardViewMode viewMode,
  }) {
    if (viewMode == DashboardViewMode.list) {
      return ListView.separated(
        key: viewKey,
        itemCount: cards.length,
        separatorBuilder: (BuildContext context, int index) =>
            const SizedBox(height: 10),
        itemBuilder: (BuildContext context, int index) {
          final _DashboardCardSpec card = cards[index];
          return AppActionCard(
            title: card.title,
            icon: card.icon,
            leftPlaceholder: card.leftPlaceholder,
            rightPlaceholder: card.rightPlaceholder,
            showLeading:
                _section != _HomeSection.home &&
                (card.leftPlaceholder != null || card.icon != null),
            onTap: () => _onCardTap(card),
          );
        },
      );
    }
    return GridView.builder(
      key: viewKey,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: cards.length,
      itemBuilder: (BuildContext context, int index) {
        final _DashboardCardSpec card = cards[index];
        return AppActionCard(
          title: card.title,
          icon: card.icon,
          leftPlaceholder: card.leftPlaceholder,
          rightPlaceholder: card.rightPlaceholder,
          showLeading:
              _section != _HomeSection.home &&
              (card.leftPlaceholder != null || card.icon != null),
          titleMaxLines: 2,
          onTap: () => _onCardTap(card),
        );
      },
    );
  }

  Future<void> _onCardTap(_DashboardCardSpec card) async {
    final String title = card.title;
    if (_section == _HomeSection.home) {
      final String projectTypeName = title.replaceFirst(
        RegExp(r'\s*\(\d+\)$'),
        '',
      );
      context.pushNamed(ProjectDetailsPage.routeName, extra: projectTypeName);
      return;
    }
    if (_section == _HomeSection.updateForms &&
        card.payload is UpdateFormItem) {
      await _onUpdateFormTap(card.payload! as UpdateFormItem);
      return;
    }
    await AppDialog.show(
      context: context,
      title: title,
      message: '$title action will be connected shortly.',
      type: AppDialogType.info,
    );
  }

  Future<void> _onUpdateFormTap(UpdateFormItem form) async {
    final List<UpdateFormSubItem> subMenus = form.orderedSubMenus;
    if (subMenus.isEmpty) {
      await AppDialog.show(
        context: context,
        title: form.formName,
        message: '${form.formName} navigation will be connected next.',
        type: AppDialogType.info,
      );
      return;
    }

    final UpdateFormSubItem? selected =
        await showModalBottomSheet<UpdateFormSubItem>(
          context: context,
          useSafeArea: true,
          showDragHandle: true,
          builder: (BuildContext context) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 18),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: subMenus.length,
                separatorBuilder: (BuildContext context, int _) => Divider(
                  height: 1,
                  thickness: 0.8,
                  color: Theme.of(
                    context,
                  ).colorScheme.outlineVariant.withValues(alpha: 0.55),
                ),
                itemBuilder: (BuildContext context, int index) {
                  final UpdateFormSubItem sub = subMenus[index];
                  return ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    title: Text(sub.formName),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.of(context).pop(sub),
                  );
                },
              ),
            );
          },
        );
    if (!mounted || selected == null) {
      return;
    }
    await AppDialog.show(
      context: context,
      title: selected.formName,
      message: '${selected.formName} navigation will be connected next.',
      type: AppDialogType.info,
    );
  }

  Widget? _updateFormAssetIcon(UpdateFormItem item) {
    final String formId = item.formId.trim();
    final String key = _normalizeFormKey(item.formName);
    final String? assetPath = switch (formId) {
      '38' => 'assets/update_forms_icons/projects.png',
      '9' => 'assets/update_forms_icons/works.png',
      '10' => 'assets/update_forms_icons/contracts_tenders.png',
      '17' => 'assets/update_forms_icons/design_drawing.png',
      '6' => 'assets/update_forms_icons/issues.png',
      '1391' => 'assets/update_forms_icons/dms.png',
      '43' => 'assets/update_forms_icons/land_acquisition.png',
      '1240' => 'assets/update_forms_icons/utility_shifting.png',
      '40' => 'assets/update_forms_icons/validate_data.png',
      _ => _assetPathFromFormNameKey(key),
    };
    if (assetPath == null) {
      return null;
    }
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        color: colorScheme.surface,
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.9),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Image.asset(
          assetPath,
          fit: BoxFit.contain,
          errorBuilder:
              (BuildContext context, Object error, StackTrace? trace) {
                return Icon(Icons.widgets_outlined, color: colorScheme.primary);
              },
        ),
      ),
    );
  }

  String _normalizeFormKey(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('&', ' ')
        .replaceAll('/', ' ')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  String? _assetPathFromFormNameKey(String key) {
    if (key.contains('execution') && (key.contains('monitor') || key.contains('moniter'))) {
      return 'assets/update_forms_icons/execution_monitoring.png';
    }
    if (key.contains('projects')) {
      return 'assets/update_forms_icons/projects.png';
    }
    if (key.contains('works')) {
      return 'assets/update_forms_icons/works.png';
    }
    if (key.contains('contracts') || key.contains('tenders')) {
      return 'assets/update_forms_icons/contracts_tenders.png';
    }
    if (key.contains('design') || key.contains('drawing')) {
      return 'assets/update_forms_icons/design_drawing.png';
    }
    if (key.contains('issues')) {
      return 'assets/update_forms_icons/issues.png';
    }
    if (key.contains('dms')) {
      return 'assets/update_forms_icons/dms.png';
    }
    if (key.contains('land') && key.contains('acquisition')) {
      return 'assets/update_forms_icons/land_acquisition.png';
    }
    if (key.contains('utility') && key.contains('shifting')) {
      return 'assets/update_forms_icons/utility_shifting.png';
    }
    if (key.contains('validate') && key.contains('data')) {
      return 'assets/update_forms_icons/validate_data.png';
    }
    return null;
  }

  String _avatarInitial(AuthSession? session) {
    final String source = (session?.userName.trim().isNotEmpty ?? false)
        ? session!.userName.trim()
        : (session?.userId.isNotEmpty ?? false)
        ? session!.userId
        : 'U';
    return source.substring(0, 1).toUpperCase();
  }

  Widget _bottomItem({
    required int index,
    required String label,
    required IconData icon,
    required IconData selectedIcon,
  }) {
    final bool selected = _selectedIndex == index;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _onBottomSelected(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? colorScheme.onPrimary.withValues(alpha: 0.22)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  selected ? selectedIcon : icon,
                  color: colorScheme.onPrimary,
                  size: 22,
                ),
              ),
              const SizedBox(height: 7),
              SizedBox(
                height: 18,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
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

class HomeSectionScreen extends StatelessWidget {
  const HomeSectionScreen({
    super.key,
    required this.message,
    required this.session,
    required this.config,
  });

  final String message;
  final AuthSession? session;
  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        _sectionCard(context, title: 'WCR PMIS', subtitle: message),
        const SizedBox(height: 12),
        if (session != null)
          _sectionCard(
            context,
            title: session!.userName,
            subtitle: [
              if (session!.designation.isNotEmpty) session!.designation,
              if (session!.userRoleNameFk.isNotEmpty) session!.userRoleNameFk,
              if (session!.emailId.isNotEmpty) session!.emailId,
            ].join('\n'),
          ),
        const SizedBox(height: 12),
        _sectionCard(context, title: 'Environment', subtitle: config.appName),
      ],
    );
  }
}

class ModuleSectionScreen extends StatelessWidget {
  const ModuleSectionScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _sectionCard(
        context,
        title: title,
        subtitle: '$title module UI is ready for feature integration.',
      ),
    );
  }
}

Widget _sectionCard(
  BuildContext context, {
  required String title,
  required String subtitle,
}) {
  return Card(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    ),
  );
}
