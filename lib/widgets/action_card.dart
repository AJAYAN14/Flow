import "package:flow/data/flow_icon.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons_flow/symbols.dart";

class ActionCard extends StatelessWidget {
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  final FlowIconData? icon;
  final Widget? customIcon;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  final BorderRadius borderRadius;

  const ActionCard({
    super.key,
    this.onTap,
    this.onLongPress,
    this.borderRadius = const BorderRadius.all(Radius.circular(24.0)),
    required this.title,
    this.icon,
    this.customIcon,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Surface(
        margin: EdgeInsets.zero,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        builder: (context) => InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (icon != null || customIcon != null) ...[
                  customIcon ?? FlowIcon(
                    icon!,
                    size: 24.0,
                    plated: true,
                    color: const Color(0xFF2563EB), // ui-ux-pro-max Blue
                    plateColor: const Color(0xFFEFF6FF), // Light Blue
                    platePadding: const EdgeInsets.all(8.0),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  const SizedBox(width: 16.0),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: context.textTheme.titleMedium!.semi(context).copyWith(
                              color: const Color(0xFF0F172A), // Slate 900
                            ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2.0),
                        Text(
                          subtitle!,
                          style: context.textTheme.bodyMedium!.copyWith(
                            color: const Color(0xFF475569), // Slate 600
                            height: 1.2,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 16.0),
                  trailing!,
                ] else if (onTap != null) ...[
                  const SizedBox(width: 16.0),
                  Icon(
                    Symbols.chevron_right_rounded,
                    fill: 0,
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
