import 'package:flutter/material.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/rfi_theme.dart';

class RfiActionItem {
  const RfiActionItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}

class RfiActionMenu extends StatelessWidget {
  const RfiActionMenu({super.key, required this.actions});

  final List<RfiActionItem> actions;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    if (actions.isEmpty) {
      return Text(
        '-',
        style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
      );
    }

    if (actions.length == 1) {
      final RfiActionItem action = actions.first;
      return SizedBox(
        width: 36,
        height: 36,
        child: IconButton(
          padding: EdgeInsets.zero,
          style: IconButton.styleFrom(
            backgroundColor: action.color,
            foregroundColor: RfiTheme.foregroundOnAccent(scheme, action.color),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          icon: Icon(action.icon, size: 20),
          onPressed: action.onTap,
          tooltip: action.title,
        ),
      );
    }

    return PopupMenuButton<RfiActionItem>(
      tooltip: 'Actions',
      padding: EdgeInsets.zero,
      offset: const Offset(0, 40),
      color: RfiTheme.actionMenuBackground(scheme),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      icon: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: RfiTheme.actionMenuIconBackground(scheme),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: RfiTheme.actionMenuIconBorder(scheme)),
        ),
        child: Icon(Icons.more_vert, color: scheme.onSurface, size: 20),
      ),
      onSelected: (RfiActionItem action) => action.onTap(),
      itemBuilder: (BuildContext context) {
        return actions
            .map(
              (RfiActionItem action) => PopupMenuItem<RfiActionItem>(
                value: action,
                height: 48,
                child: Row(
                  children: <Widget>[
                    Icon(action.icon, color: action.color, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        action.title,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList();
      },
    );
  }
}
