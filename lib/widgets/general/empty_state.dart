import "package:flow/data/flow_icon.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flutter/widgets.dart";

class EmptyState extends StatelessWidget {
  final Widget? leading;
  final Widget? trailing;
  final FlowIconData? icon;
  final Widget? title;
  final Widget? subtitle;

  const EmptyState({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .all(32.0),
      child: Center(
        child: Column(
          spacing: 12.0,
          mainAxisSize: MainAxisSize.min,
          children: [
            ?leading,
            if (icon != null)
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF), // Blue 50
                  shape: BoxShape.circle,
                ),
                child: FlowIcon(icon!, size: 64.0, color: const Color(0xFF3B82F6)), // Blue 500
              ),
            if (title != null)
              DefaultTextStyle(
                textAlign: TextAlign.center,
                style: context.textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B), // Slate 800
                ),
                child: title!,
              ),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: DefaultTextStyle(
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium!.copyWith(
                    color: const Color(0xFF64748B), // Slate 500
                  ),
                  child: subtitle!,
                ),
              ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
