import "package:flow/theme/theme.dart";
import "package:flutter/material.dart";
import "package:moment_dart/moment_dart.dart";

class MonthButton extends StatelessWidget {
  final DateTime? currentDate;

  final DateTime month;

  final VoidCallback? onTap;

  final BorderRadius borderRadius;

  const MonthButton({
    super.key,
    required this.month,
    this.borderRadius = const .all(Radius.circular(16.0)),
    this.currentDate,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final DateTime now = Moment.startOfThisMonth();
    final bool selected = currentDate?.isAtSameMonthAs(month) == true;
    final bool highlighted = now.isAtSameMonthAs(month);
    final bool future = month.startOfMonth().isAfter(now);

    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF2563EB) // Royal Blue
              : const Color(0xFFF1F5F9), // Slate 100
          borderRadius: borderRadius,
        ),
        child: Text(
          month.format(payload: "MMMM"),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: future
              ? context.textTheme.bodyMedium?.semi(context)
              : context.textTheme.bodyLarge?.copyWith(
                  color: selected ? Colors.white : (highlighted ? const Color(0xFF2563EB) : const Color(0xFF1E293B)), // White / Blue / Slate 800
                  fontWeight: selected ? FontWeight.w600 : (highlighted ? FontWeight.w600 : FontWeight.w500),
                ),
        ),
      ),
    );
  }
}
