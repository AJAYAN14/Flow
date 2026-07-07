import "package:flow/theme/theme.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons_flow/symbols.dart";

/// A grouped container for PremiumListTile items.
class PremiumListGroup extends StatelessWidget {
  final List<Widget> children;

  const PremiumListGroup({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withAlpha(0x0A), // Slate 900 4%
            blurRadius: 16.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: children,
        ),
      ),
    );
  }
}

/// A premium list tile with a tinted circular icon background.
class PremiumListTile extends StatelessWidget {
  final Widget title;
  final IconData leading;
  final Color accent;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget? trailing;
  final bool showChevron;

  const PremiumListTile({
    super.key,
    required this.title,
    required this.leading,
    required this.accent,
    this.onTap,
    this.onLongPress,
    this.trailing,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: accent.withAlpha(0x26), // 15% opacity
                shape: BoxShape.circle,
              ),
              child: Icon(leading, color: accent, size: 20.0),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: DefaultTextStyle(
                style: context.textTheme.bodyLarge!.copyWith(
                  color: const Color(0xFF1E293B), // Slate 800
                  fontWeight: FontWeight.w500,
                ),
                child: title,
              ),
            ),
            if (trailing != null) trailing!,
            if (trailing != null && showChevron) const SizedBox(width: 8.0),
            if (showChevron && onTap != null)
              const Icon(
                Symbols.chevron_right_rounded,
                color: Color(0xFF94A3B8), // Slate 400
                size: 20.0,
              ),
          ],
        ),
      ),
    );
  }
}
