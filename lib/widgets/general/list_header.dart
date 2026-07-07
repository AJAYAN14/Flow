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
        style: style ?? context.textTheme.labelSmall?.copyWith(
          color: const Color(0xFF64748B), // Slate 500
          letterSpacing: 0.8,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
