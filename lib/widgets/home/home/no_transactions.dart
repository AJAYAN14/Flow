import "package:flow/data/flow_icon.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/theme/theme.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:flow/widgets/general/flow_icon.dart";

class NoTransactions extends StatelessWidget {
  final bool isFilterModified;

  const NoTransactions({super.key, required this.isFilterModified});

  @override
  Widget build(BuildContext context) {
    // Premium colors for this specific screen
    const premiumBlue = Color(0xFF2563EB); // Royal Blue
    const premiumSlate = Color(0xFF0F172A); // Slate 900
    const premiumMuted = Color(0xFF64748B); // Slate 500

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FlowIcon(
              FlowIconData.icon(Symbols.family_star_rounded),
              size: 72.0,
              color: premiumBlue,
            ),
            const SizedBox(height: 24.0),
            Text(
              "tabs.home.noTransactions".t(context),
              textAlign: TextAlign.center,
              style: context.textTheme.headlineSmall?.copyWith(
                color: premiumSlate,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12.0),
            Text(
              isFilterModified
                  ? "tabs.home.noTransactions.tryChangingFilters".t(context)
                  : "tabs.home.noTransactions.addSome".t(context),
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: premiumMuted,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
