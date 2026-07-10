import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons_flow/symbols.dart";

/// A single tile in the Stats bento dashboard.
///
/// A tappable [Surface] with an optional header (icon + uppercase label and a
/// trailing chevron) and a [child] body. Tiles size to a fixed [height] so the
/// bento grid stays predictable across content and locales; previews are
/// expected to fit, not scroll.
class BentoTile extends StatelessWidget {
  /// Short header text, e.g. "Net worth". Rendered uppercase next to [icon].
  final String label;

  final IconData icon;

  /// Tints the icon. Defaults to the theme primary color.
  final Color? accent;

  /// Fixed tile height. Paired tiles in a row should share the same value.
  final double height;

  /// Whether the body is still loading; shows a centered spinner instead.
  final bool busy;

  /// Navigation target. When non-null a chevron is shown and the tile ripples.
  final VoidCallback? onTap;

  final Widget child;

  const BentoTile({
    super.key,
    required this.label,
    required this.icon,
    required this.height,
    required this.child,
    this.accent,
    this.busy = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color resolvedAccent = accent ?? context.colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withAlpha(0x0A),
            blurRadius: 16.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(24.0)),
          onTap: onTap,
          child: SizedBox(
            height: height,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32.0,
                        height: 32.0,
                        decoration: BoxDecoration(
                          color: resolvedAccent.withAlpha(0x26),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: resolvedAccent, size: 18.0),
                      ),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.titleSmall?.copyWith(
                            color: const Color(0xFF374151), // HTML text-gray-700
                            fontWeight: FontWeight.w600, // HTML font-semibold
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                      if (onTap != null)
                        const Icon(
                          Symbols.chevron_right_rounded,
                          size: 18.0,
                          color: Color(0xFF9CA3AF), // HTML text-gray-400
                        ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  Expanded(
                    child: busy
                        ? const Spinner.center()
                        : child,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
