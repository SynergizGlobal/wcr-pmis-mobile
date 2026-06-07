import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wcr_pmis_mobile/src/core/auth/wcr_unauthorized.dart';
import 'package:wcr_pmis_mobile/src/features/auth/domain/entities/auth_session.dart';
import 'package:wcr_pmis_mobile/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:wcr_pmis_mobile/src/features/auth/presentation/pages/login_page.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/core/utils/rfi_dio_error_message.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/domain/rfi_list_kind.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/domain/utils/rfi_user_role.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/pages/create_rfi_page.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/pages/rfi_home_tab.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/pages/rfi_list_page.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/providers/rfi_providers.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/widgets/rfi_bottom_navigation_bar.dart';

enum _RfiShellSection { home, create, more }

class _RfiNavEntry {
  const _RfiNavEntry({
    required this.section,
    required this.destination,
    this.opensMenu = false,
  });

  final _RfiShellSection section;
  final RfiBottomNavDestination destination;
  final bool opensMenu;
}

class RfiDashboardPage extends ConsumerStatefulWidget {
  const RfiDashboardPage({super.key});

  static const String routeName = 'rfi-dashboard';
  static const String routePath = '/rfi/dashboard';

  @override
  ConsumerState<RfiDashboardPage> createState() => _RfiDashboardPageState();
}

class _RfiDashboardPageState extends ConsumerState<RfiDashboardPage> {
  int _selectedIndex = 0;

  void _refreshAll() {
    ref.invalidate(rfiHandoffProvider);
    ref.invalidate(rfiDashboardProvider);
  }

  List<_RfiNavEntry> _navEntries(RfiUserRole role) {
    final List<_RfiNavEntry> entries = <_RfiNavEntry>[
      const _RfiNavEntry(
        section: _RfiShellSection.home,
        destination: RfiBottomNavDestination(
          label: 'Home',
          icon: Icons.home_outlined,
          selectedIcon: Icons.home_rounded,
        ),
      ),
    ];
    if (role.canCreateRfi) {
      entries.add(
        const _RfiNavEntry(
          section: _RfiShellSection.create,
          destination: RfiBottomNavDestination(
            label: 'Create',
            icon: Icons.add_circle_outline,
            selectedIcon: Icons.add_circle,
          ),
        ),
      );
    }
    if (role.hasMoreMenuItems) {
      entries.add(
        const _RfiNavEntry(
          section: _RfiShellSection.more,
          destination: RfiBottomNavDestination(
            label: 'More',
            icon: Icons.grid_view_rounded,
            selectedIcon: Icons.grid_view_rounded,
          ),
          opensMenu: true,
        ),
      );
    }
    return entries;
  }

  String _titleForSection(_RfiShellSection section) {
    return switch (section) {
      _RfiShellSection.home => 'RFI System',
      _RfiShellSection.create => 'Create RFI',
      _RfiShellSection.more => 'RFI System',
    };
  }

  void _onNavSelected(int index, List<_RfiNavEntry> entries) {
    final _RfiNavEntry entry = entries[index];
    if (entry.opensMenu) {
      _openMoreMenu(ref.read(authControllerProvider).valueOrNull);
      return;
    }
    setState(() => _selectedIndex = index);
  }

  Future<void> _openMoreMenu(AuthSession? session) async {
    final RfiUserRole role = RfiUserRole.fromSession(session);
    final List<_RfiMoreAction> actions = _moreActions(role);
    if (actions.isEmpty) {
      return;
    }

    final _RfiMoreAction? picked = await showModalBottomSheet<_RfiMoreAction>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (BuildContext context) {
        final ColorScheme scheme = Theme.of(context).colorScheme;
        final TextTheme textTheme = Theme.of(context).textTheme;
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: actions
                .map(
                  (_RfiMoreAction action) => ListTile(
                    leading: Icon(action.icon, color: scheme.primary),
                    title: Text(
                      action.label,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: scheme.onSurfaceVariant,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onTap: () => Navigator.pop(context, action),
                  ),
                )
                .toList(),
          ),
        );
      },
    );

    if (!mounted || picked == null) {
      return;
    }
    picked.handle(context);
  }

  List<_RfiMoreAction> _moreActions(RfiUserRole role) {
    final List<_RfiMoreAction> actions = <_RfiMoreAction>[];
    if (role.canViewUpdatedRfi) {
      actions.add(
        _RfiMoreAction(
          label: 'Updated RFI',
          icon: Icons.edit_outlined,
          onSelect: (BuildContext context) => context.pushNamed(
            RfiListPage.routeName,
            pathParameters: <String, String>{
              'kind': RfiListKind.updated.name,
            },
          ),
        ),
      );
    }
    if (role.canViewInspection) {
      actions.add(
        _RfiMoreAction(
          label: 'Inspection',
          icon: Icons.assignment_outlined,
          onSelect: (BuildContext context) =>
              context.pushNamed('rfi-inspection'),
        ),
      );
    }
    if (role.canViewValidation) {
      actions.add(
        _RfiMoreAction(
          label: 'Validation',
          icon: Icons.verified_user_outlined,
          onSelect: (BuildContext context) =>
              context.pushNamed('rfi-validation'),
        ),
      );
    }
    if (role.canViewRfiLog) {
      actions.add(
        _RfiMoreAction(
          label: 'RFI Log',
          icon: Icons.history,
          onSelect: (BuildContext context) => context.pushNamed('rfi-log'),
        ),
      );
    }
    if (role.canChangeExecutive('')) {
      actions.add(
        _RfiMoreAction(
          label: 'Assign Executive',
          icon: Icons.person_add_alt_outlined,
          onSelect: (BuildContext context) =>
              context.pushNamed('rfi-assign-executive'),
        ),
      );
    }
    if (role.canViewInspectionReferenceForm) {
      actions.add(
        _RfiMoreAction(
          label: 'Inspection Reference Form',
          icon: Icons.description_outlined,
          onSelect: (BuildContext context) =>
              context.pushNamed('rfi-inspection-reference'),
        ),
      );
    }
    return actions;
  }

  @override
  Widget build(BuildContext context) {
    final AuthSession? session = ref.watch(authControllerProvider).valueOrNull;
    final RfiUserRole role = RfiUserRole.fromSession(session);
    final AsyncValue<void> handoff = ref.watch(rfiHandoffProvider);
    final List<_RfiNavEntry> entries = _navEntries(role);
    if (_selectedIndex >= entries.length) {
      _selectedIndex = 0;
    }
    final _RfiShellSection section = entries[_selectedIndex].section;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back to PMIS',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: Text(_titleForSection(section)),
      ),
      body: handoff.when(
        loading: () => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Connecting to RFI…'),
            ],
          ),
        ),
        error: (Object error, StackTrace stack) {
          if (isWcrUnauthorizedError(error)) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: RfiHomeError(
                  title: 'Session expired',
                  message: sessionExpiredLoginMessage,
                  onRetry: () {
                    if (context.mounted) {
                      context.go(LoginPage.routePath);
                    }
                  },
                ),
              ),
            );
          }
          final String message = error is DioException
              ? rfiDioErrorMessage(error)
              : error.toString();
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: RfiHomeError(
                title: 'Could not connect to RFI.',
                message: message,
                onRetry: _refreshAll,
              ),
            ),
          );
        },
        data: (_) => AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: _buildSectionBody(
            key: ValueKey<String>(section.name),
            section: section,
            role: role,
            session: session,
          ),
        ),
      ),
      bottomNavigationBar: handoff.hasValue
          ? RfiBottomNavigationBar(
              selectedIndex: _selectedIndex,
              onSelected: (int index) => _onNavSelected(index, entries),
              destinations: entries
                  .map((_RfiNavEntry e) => e.destination)
                  .toList(),
            )
          : null,
    );
  }

  Widget _buildSectionBody({
    required Key key,
    required _RfiShellSection section,
    required RfiUserRole role,
    required AuthSession? session,
  }) {
    return switch (section) {
      _RfiShellSection.home => RfiHomeTab(
          key: key,
          role: role,
          session: session,
          onRetry: _refreshAll,
        ),
      _RfiShellSection.create => CreateRfiPage(key: key, embedded: true),
      _RfiShellSection.more => const SizedBox.shrink(),
    };
  }
}

class _RfiMoreAction {
  const _RfiMoreAction({
    required this.label,
    required this.icon,
    required this.onSelect,
  });

  final String label;
  final IconData icon;
  final void Function(BuildContext context) onSelect;

  void handle(BuildContext context) => onSelect(context);
}
