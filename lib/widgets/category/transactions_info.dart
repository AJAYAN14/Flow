import "package:flow/data/flow_icon.dart";
import "package:flow/data/money.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flutter/material.dart";

class TransactionsInfo extends StatelessWidget {
  final int? count;
  final Money flow;

  final FlowIconData icon;
  final FlowColorScheme? colorScheme;

  const TransactionsInfo({
    super.key,
    required this.count,
    required this.flow,
    required this.icon,
    this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withAlpha(0x0A),
            blurRadius: 24.0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: (colorScheme?.name == "monochrome" || colorScheme == null
                          ? const Color(0xFF2563EB)
                          : colorScheme!.primary)
                      .withAlpha(0x1A),
                  shape: BoxShape.circle,
                ),
                child: FlowIcon(
                  icon,
                  size: 32.0,
                  color: colorScheme?.name == "monochrome" || colorScheme == null
                      ? const Color(0xFF2563EB)
                      : colorScheme!.primary,
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      flow.formatted,
                      style: context.textTheme.headlineMedium?.copyWith(
                        color: const Color(0xFF1E293B), // Slate 800
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      "transactions.count".t(context, count ?? 0),
                      style: context.textTheme.titleSmall?.copyWith(
                        color: const Color(0xFF64748B), // Slate 500
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
