import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flutter/material.dart";

class Section extends StatelessWidget {
  final String? title;
  final Widget child;
  final Widget? titleOverride;
  final EdgeInsetsGeometry padding;

  const Section({
    super.key,
    this.title,
    this.titleOverride,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null || titleOverride != null)
          Padding(
            padding: EdgeInsets.only(
              left: padding.horizontal / 2 + 8.0,
              right: padding.horizontal / 2 + 8.0,
              bottom: 8.0,
            ),
            child: DefaultTextStyle(
              style: context.textTheme.labelMedium!.semi(context).copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              child: titleOverride ?? Text(title ?? ""),
            ),
          ),
        Padding(
          padding: padding,
          child: Container(
            decoration: BoxDecoration(
              color: context.colorScheme.brightness == Brightness.light ? const Color(0xFFFFFFFF) : context.colorScheme.secondary,
              borderRadius: BorderRadius.circular(24.0),
              boxShadow: context.colorScheme.brightness == Brightness.light ? [
                BoxShadow(
                  color: const Color(0xFF0F172A).withAlpha(0x0A), // Slate 900 4%
                  blurRadius: 16.0,
                  offset: const Offset(0, 4),
                ),
              ] : null,
            ),
            clipBehavior: Clip.antiAlias,
            child: Material(
              color: Colors.transparent,
              child: Theme(
                data: Theme.of(context).copyWith(
                  listTileTheme: ListTileThemeData(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
                ),
                child: child,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
