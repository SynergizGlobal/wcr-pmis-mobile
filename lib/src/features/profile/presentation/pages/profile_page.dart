import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wcr_pmis_mobile/src/app/theme/app_theme.dart';
import 'package:wcr_pmis_mobile/src/app/theme/theme_mode_provider.dart';
import 'package:wcr_pmis_mobile/src/features/auth/domain/entities/auth_session.dart';
import 'package:wcr_pmis_mobile/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:wcr_pmis_mobile/src/features/auth/presentation/pages/login_page.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  static const String routeName = 'profile';
  static const String routePath = '/profile';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AuthSession? session = ref.watch(authControllerProvider).valueOrNull;
    final ThemeMode themeMode = ref.watch(themeModeProvider);
    final AppPalette palette =
        Theme.of(context).extension<AppPalette>() ?? AppPalette.light;
    final String initial = _resolveInitial(session);

    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  Center(
                    child: CircleAvatar(
                      radius: 34,
                      backgroundColor: palette.avatarFill,
                      child: Text(
                        initial,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: palette.avatarText,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _infoCard(
                    context,
                    title: 'Basic Details',
                    rows: <MapEntry<String, String>>[
                      MapEntry('Name', session?.userName ?? '-'),
                      MapEntry('User ID', session?.userId ?? '-'),
                      MapEntry(
                        'Email',
                        session?.emailId.isNotEmpty == true ? session!.emailId : '-',
                      ),
                      MapEntry(
                        'Role',
                        session?.userRoleNameFk.isNotEmpty == true
                            ? session!.userRoleNameFk
                            : '-',
                      ),
                      MapEntry(
                        'Designation',
                        session?.designation.isNotEmpty == true
                            ? session!.designation
                            : '-',
                      ),
                      MapEntry(
                        'Department',
                        session?.departmentFk.isNotEmpty == true
                            ? session!.departmentFk
                            : '-',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _themeSelector(context, ref, themeMode),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (BuildContext context, AsyncSnapshot<PackageInfo> snap) {
                  final String version = _resolveVersionText(snap);
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () async {
                            await ref.read(authControllerProvider.notifier).logout();
                            if (context.mounted) {
                              context.goNamed(LoginPage.routeName);
                            }
                          },
                          icon: const Icon(Icons.logout_rounded),
                          label: const Text('Log out'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'App Version : $version',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _resolveVersionText(AsyncSnapshot<PackageInfo> snap) {
    if (snap.hasData) {
      final String version = snap.data!.version.trim();
      final String build = snap.data!.buildNumber.trim();
      final String safeVersion = version.isEmpty ? '1.0.0' : version;
      final String safeBuild = build.isEmpty ? '1' : build;
      return '$safeVersion ($safeBuild)';
    }
    return '1.0.0 (1)';
  }

  String _resolveInitial(AuthSession? session) {
    final String source =
        (session?.userName.trim().isNotEmpty ?? false)
            ? session!.userName.trim()
            : (session?.userId.isNotEmpty ?? false)
            ? session!.userId
            : 'U';
    return source.substring(0, 1).toUpperCase();
  }

  Widget _themeSelector(
    BuildContext context,
    WidgetRef ref,
    ThemeMode currentMode,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Theme',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: <Widget>[
                  _themeOption(context, ref, currentMode, ThemeMode.system, 'System'),
                  _themeOption(context, ref, currentMode, ThemeMode.light, 'Light'),
                  _themeOption(context, ref, currentMode, ThemeMode.dark, 'Dark'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _themeOption(
    BuildContext context,
    WidgetRef ref,
    ThemeMode currentMode,
    ThemeMode mode,
    String label,
  ) {
    final bool selected = currentMode == mode;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => ref.read(themeModeProvider.notifier).setMode(mode),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            height: 40,
            decoration: BoxDecoration(
              color: selected ? colorScheme.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(22),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoCard(
    BuildContext context, {
    required String title,
    required List<MapEntry<String, String>> rows,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
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
            ...rows.map((MapEntry<String, String> row) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: 110,
                      child: Text(
                        row.key,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        row.value,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
