import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wcr_pmis_mobile/src/app/config/app_config.dart';
import 'package:wcr_pmis_mobile/src/app/config/app_config_provider.dart';
import 'package:wcr_pmis_mobile/src/features/auth/domain/entities/auth_session.dart';
import 'package:wcr_pmis_mobile/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:wcr_pmis_mobile/src/features/auth/presentation/pages/login_page.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/providers/dashboard_message_provider.dart';

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
    final _HomeSection? result = await showModalBottomSheet<_HomeSection>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
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
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Icon(icon),
      title: Text(_titleForSection(section)),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => Navigator.of(context).pop(section),
    );
  }

  String _titleForSection(_HomeSection section) {
    return switch (section) {
      _HomeSection.home => 'Home',
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

    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle),
        actions: <Widget>[
          IconButton(
            tooltip: 'Log out',
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) {
                context.goNamed(LoginPage.routeName);
              }
            },
            icon: const Icon(Icons.logout_rounded),
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onBottomSelected,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_document),
            selectedIcon: Icon(Icons.edit_document),
            label: 'Update Forms',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_rounded),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: 'More',
          ),
        ],
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
