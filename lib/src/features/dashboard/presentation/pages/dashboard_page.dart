import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wcr_pmis_mobile/src/app/config/app_config.dart';
import 'package:wcr_pmis_mobile/src/app/config/app_config_provider.dart';
import 'package:wcr_pmis_mobile/src/app/theme/app_theme.dart';
import 'package:wcr_pmis_mobile/src/features/auth/domain/entities/auth_session.dart';
import 'package:wcr_pmis_mobile/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/providers/dashboard_message_provider.dart';
import 'package:wcr_pmis_mobile/src/features/profile/presentation/pages/profile_page.dart';

enum _HomeSection { home, updateForms, reports, documents, quickLinks, admin, rfi }

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
              _moreItem(_HomeSection.admin, Icons.admin_panel_settings_outlined),
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
    final AppConfig config = ref.watch(appConfigProvider);
    final String message = ref.watch(dashboardMessageProvider);
    final AuthSession? session = ref.watch(authControllerProvider).valueOrNull;
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
          child: Image.asset(
            'assets/app_icon.png',
            fit: BoxFit.contain,
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(29),
              onTap: () => context.pushNamed(ProfilePage.routeName),
              child: CircleAvatar(
                radius: 24,
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
            child: _buildSectionScreen(
              section: _section,
              message: message,
              session: session,
              config: config,
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

  Widget _buildSectionScreen({
    required _HomeSection section,
    required String message,
    required AuthSession? session,
    required AppConfig config,
  }) {
    return switch (section) {
      _HomeSection.home => HomeSectionScreen(
        key: const ValueKey<String>('home-screen'),
        message: message,
        session: session,
        config: config,
      ),
      _HomeSection.updateForms => const ModuleSectionScreen(
        key: ValueKey<String>('update-forms-screen'),
        title: 'Update Forms',
      ),
      _HomeSection.reports => const ModuleSectionScreen(
        key: ValueKey<String>('reports-screen'),
        title: 'Reports',
      ),
      _HomeSection.documents => const ModuleSectionScreen(
        key: ValueKey<String>('documents-screen'),
        title: 'Documents',
      ),
      _HomeSection.quickLinks => const ModuleSectionScreen(
        key: ValueKey<String>('quick-links-screen'),
        title: 'Quick Links',
      ),
      _HomeSection.admin => const ModuleSectionScreen(
        key: ValueKey<String>('admin-screen'),
        title: 'Admin',
      ),
      _HomeSection.rfi => const ModuleSectionScreen(
        key: ValueKey<String>('rfi-screen'),
        title: 'RFI',
      ),
    };
  }

  String _avatarInitial(AuthSession? session) {
    final String source =
        (session?.userName.trim().isNotEmpty ?? false)
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
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
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
