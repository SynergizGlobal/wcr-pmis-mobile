import 'package:flutter/material.dart';

class RfiBottomNavDestination {
  const RfiBottomNavDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

class RfiBottomNavigationBar extends StatelessWidget {
  const RfiBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    required this.destinations,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final List<RfiBottomNavDestination> destinations;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant.withValues(
                alpha: Theme.of(context).brightness == Brightness.dark
                    ? 0.45
                    : 0.55,
              ),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withValues(
                  alpha: Theme.of(context).brightness == Brightness.dark
                      ? 0.26
                      : 0.10,
                ),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withValues(
                  alpha: Theme.of(context).brightness == Brightness.dark
                      ? 0.10
                      : 0.06,
                ),
                blurRadius: 26,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: Theme.of(context).brightness == Brightness.dark
                      ? <Color>[
                          Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.78),
                          Theme.of(context)
                              .colorScheme
                              .surfaceContainer
                              .withValues(alpha: 0.72),
                        ]
                      : <Color>[
                          Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.94),
                          Theme.of(context)
                              .colorScheme
                              .surface
                              .withValues(alpha: 0.96),
                        ],
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: List<Widget>.generate(destinations.length, (int index) {
                  return Expanded(
                    child: _NavItem(
                      selected: selectedIndex == index,
                      destination: destinations[index],
                      onTap: () => onSelected(index),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.selected,
    required this.destination,
    required this.onTap,
  });

  final bool selected;
  final RfiBottomNavDestination destination;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color selectedBackground = isDark
        ? colorScheme.primary.withValues(alpha: 0.42)
        : colorScheme.primary.withValues(alpha: 0.14);
    final Color selectedIconColor =
        isDark ? colorScheme.onPrimary : colorScheme.primary;
    final Color selectedTextColor =
        isDark ? colorScheme.onSurface : colorScheme.primary;
    final Color unselectedIconColor = colorScheme.onSurfaceVariant.withValues(
      alpha: isDark ? 0.96 : 0.86,
    );
    final Color unselectedTextColor = colorScheme.onSurfaceVariant.withValues(
      alpha: isDark ? 0.90 : 0.78,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
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
                color: selected ? selectedBackground : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: selected
                    ? Border.all(
                        color: isDark
                            ? colorScheme.primary.withValues(alpha: 0.46)
                            : colorScheme.primary.withValues(alpha: 0.28),
                      )
                    : null,
                boxShadow: selected
                    ? <BoxShadow>[
                        BoxShadow(
                          color: colorScheme.primary.withValues(
                            alpha: isDark ? 0.28 : 0.14,
                          ),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                selected ? destination.selectedIcon : destination.icon,
                color: selected ? selectedIconColor : unselectedIconColor,
                size: selected ? 23 : 22,
              ),
            ),
            const SizedBox(height: 7),
            SizedBox(
              height: 18,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  destination.label,
                  maxLines: 1,
                  style: TextStyle(
                    color: selected ? selectedTextColor : unselectedTextColor,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    letterSpacing: selected ? 0.15 : 0.0,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
