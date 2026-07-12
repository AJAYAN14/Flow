import "package:flow/theme/theme.dart";
import "package:flutter/material.dart";

class ListHeader extends StatelessWidget {
  final String title;
  final EdgeInsets padding;

  final TextStyle? style;

  const ListHeader(
    this.title, {
    super.key,
    this.style,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding.copyWith(bottom: 8.0, top: 12.0),
      child: Text(
        title.toUpperCase(), 
        style: style ?? context.textTheme.titleSmall?.copyWith(
          color: context.colorScheme.onSurface.withAlpha(0xB3), // 70% opacity
          letterSpacing: 0.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
