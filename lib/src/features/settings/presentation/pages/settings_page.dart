import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wcr_pmis_mobile/src/app/theme/theme_mode_provider.dart';
import 'package:wcr_pmis_mobile/src/core/constants/legal_constants.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_action_card.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_dialog.dart';
import 'package:wcr_pmis_mobile/src/features/settings/presentation/providers/dashboard_view_mode_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  static const String routeName = 'settings';
  static const String routePath = '/settings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode themeMode = ref.watch(themeModeProvider);
    final DashboardViewMode viewMode = ref.watch(dashboardViewModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _sectionTitle(context, 'Appearance'),
          const SizedBox(height: 8),
          _themeSelector(context, ref, themeMode),
          const SizedBox(height: 12),
          _viewModeSelector(context, ref, viewMode),
          const SizedBox(height: 18),
          _sectionTitle(context, 'General'),
          const SizedBox(height: 8),
          AppActionCard(
            title: 'Rate this app',
            icon: Icons.star_rate_rounded,
            onTap: () => _rateApp(context),
          ),
          AppActionCard(
            title: 'Privacy Policy',
            icon: Icons.privacy_tip_outlined,
            onTap: () => _openPrivacyPolicy(context),
          ),
          AppActionCard(
            title: 'Contact us',
            icon: Icons.support_agent_rounded,
            onTap: () => _contactUs(context),
          ),
          Builder(
            builder: (BuildContext shareContext) {
              return AppActionCard(
                title: 'Share app',
                icon: Icons.ios_share_rounded,
                onTap: () => _shareApp(shareContext),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }

  Widget _themeSelector(BuildContext context, WidgetRef ref, ThemeMode currentMode) {
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
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            _capsuleSelector<ThemeMode>(
              context,
              selected: currentMode,
              values: const <ThemeMode>[
                ThemeMode.system,
                ThemeMode.light,
                ThemeMode.dark,
              ],
              labelBuilder: (ThemeMode mode) => switch (mode) {
                ThemeMode.system => 'System',
                ThemeMode.light => 'Light',
                ThemeMode.dark => 'Dark',
              },
              onSelect: (ThemeMode mode) {
                ref.read(themeModeProvider.notifier).setMode(mode);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _viewModeSelector(
    BuildContext context,
    WidgetRef ref,
    DashboardViewMode viewMode,
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
              'Card View Type',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            _capsuleSelector<DashboardViewMode>(
              context,
              selected: viewMode,
              values: const <DashboardViewMode>[
                DashboardViewMode.grid,
                DashboardViewMode.list,
              ],
              labelBuilder: (DashboardViewMode mode) =>
                  mode == DashboardViewMode.grid ? 'Grid' : 'List',
              onSelect: (DashboardViewMode mode) {
                ref.read(dashboardViewModeProvider.notifier).setMode(mode);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _capsuleSelector<T>(
    BuildContext context, {
    required T selected,
    required List<T> values,
    required String Function(T) labelBuilder,
    required ValueChanged<T> onSelect,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: values.map((T value) {
          final bool isSelected = selected == value;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => onSelect(value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected ? colorScheme.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    labelBuilder(value),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(growable: false),
      ),
    );
  }

  Future<void> _rateApp(BuildContext context) async {
    final InAppReview review = InAppReview.instance;
    await review.openStoreListing(
      appStoreId: LegalConstants.iosAppStoreId,
    );
  }

  Future<void> _openPrivacyPolicy(BuildContext context) async {
    final Uri url = Uri.parse(LegalConstants.privacyPolicyUrl);
    final bool launched = await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
    if (launched) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    await AppDialog.show(
      context: context,
      title: 'Info',
      message:
          'Could not open the privacy policy. Visit:\n${LegalConstants.privacyPolicyUrl}',
      type: AppDialogType.info,
    );
  }

  Future<void> _contactUs(BuildContext context) async {
    final Uri mail = Uri(
      scheme: 'mailto',
      path: LegalConstants.supportEmail,
      queryParameters: <String, String>{
        'subject': '${LegalConstants.onDeviceAppName} Support',
      },
    );
    final bool launched = await launchUrl(mail);
    if (launched) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    await AppDialog.show(
      context: context,
      title: 'Info',
      message:
          'Could not open mail app. Please contact:\n${LegalConstants.supportEmail}',
      type: AppDialogType.info,
    );
  }

  Future<void> _shareApp(BuildContext context) async {
    await SharePlus.instance.share(
      ShareParams(
        text:
            'Try ${LegalConstants.storeListingName} — ${LegalConstants.storeTagline}\n\n'
            '${LegalConstants.platformStoreUrl}',
        sharePositionOrigin: _sharePositionOrigin(context),
      ),
    );
  }

  Rect _sharePositionOrigin(BuildContext context) {
    final RenderObject? renderObject = context.findRenderObject();
    if (renderObject is RenderBox && renderObject.hasSize) {
      final Offset origin = renderObject.localToGlobal(Offset.zero);
      final Size size = renderObject.size;
      if (size.width > 0 && size.height > 0) {
        return origin & size;
      }
    }
    final Size screen = MediaQuery.sizeOf(context);
    return Rect.fromCenter(
      center: Offset(screen.width / 2, screen.height * 0.85),
      width: 2,
      height: 2,
    );
  }
}
