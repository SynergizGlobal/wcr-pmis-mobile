import 'package:flutter/material.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/rfi_theme.dart';

/// Dialog shell with themed surface and primary header (light + dark).
class RfiThemedDialog extends StatelessWidget {
  const RfiThemedDialog({
    super.key,
    required this.title,
    required this.icon,
    required this.body,
    this.actions,
    this.maxHeightFactor = 0.85,
  });

  final String title;
  final IconData icon;
  final Widget body;
  final Widget? actions;
  final double maxHeightFactor;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Dialog(
      elevation: 8,
      backgroundColor: scheme.surface,
      surfaceTintColor: scheme.surfaceTint,
      shape: RfiTheme.dialogShape(),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * maxHeightFactor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            RfiTheme.dialogHeader(context, title: title, icon: icon),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: body,
              ),
            ),
            if (actions != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                color: scheme.surface,
                child: actions,
              ),
          ],
        ),
      ),
    );
  }
}
