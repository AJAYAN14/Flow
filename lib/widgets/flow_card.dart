import "package:auto_size_text/auto_size_text.dart";
import "package:flow/data/money.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/theme/theme.dart";
import "package:flutter/material.dart";

class FlowCard extends StatelessWidget {
  final AutoSizeGroup? autoSizeGroup;

  final TransactionType type;
  final Money flow;

  const FlowCard({
    super.key,
    required this.flow,
    required this.type,
    this.autoSizeGroup,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(20.0),
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
        child: Container(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).textScaler.scale(
              context.textTheme.titleLarge!.height! *
                      context.textTheme.titleLarge!.fontSize! +
                  40.0,
            ),
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                type.localizedNameContext(context),
                style: context.textTheme.labelMedium?.copyWith(
                  color: const Color(0xFF64748B), // Slate 500
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6.0),
              AutoSizeText(
                flow.abs().formatted,
                style: context.textTheme.titleLarge?.copyWith(
                  color: type.color(context),
                  fontWeight: FontWeight.w800,
                ),
                minFontSize: 12.0,
                maxLines: 1,
                group: autoSizeGroup,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
