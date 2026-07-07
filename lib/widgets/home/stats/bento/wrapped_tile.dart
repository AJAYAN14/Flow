import "package:flow/data/money.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/extensions.dart";
import "package:flow/utils/primary_currency_dependent_state.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:moment_dart/moment_dart.dart";

/// A slim accent banner inviting the user into their monthly "wrapped" recap.
///
/// Deliberately styled apart from the data tiles — wrapped is a seasonal
/// moment, not a daily chart. Carries a one-line teaser built from this
/// month's transactions.
class WrappedTile extends StatefulWidget {
  const WrappedTile({super.key});

  @override
  State<WrappedTile> createState() => _WrappedTileState();
}

class _WrappedTileState extends State<WrappedTile>
    with PrimaryCurrencyDependentState<WrappedTile> {
  int entryCount = 0;
  double biggestExpense = 0.0;

  @override
  Widget build(BuildContext context) {
    final String month = DateTime.now().toMoment().format("MMMM");
    final Color accent = context.colorScheme.primary;

    final String teaser = entryCount == 0
        ? "tabs.stats.analytics.wrapped.tileTeaserEmpty".t(context)
        : (entryCount == 1
                  ? "tabs.stats.analytics.wrapped.tileTeaser.one"
                  : "tabs.stats.analytics.wrapped.tileTeaser")
              .t(context, {
                "count": entryCount,
                "amount": Money(
                  biggestExpense,
                  primaryCurrency,
                ).formattedCompact,
              });

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: const BorderRadius.all(Radius.circular(24.0)),
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
          onTap: () => context.push("/stats/wrapped"),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(24.0)),
              gradient: const LinearGradient(
                begin: AlignmentDirectional.centerStart,
                end: AlignmentDirectional.centerEnd,
                colors: [
                  Color(0xFFFFFBEB), // Very pale golden amber (Amber 50)
                  Color(0x00FFFFFF), // Fades to transparent white
                ],
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withAlpha(0x26), // Amber 15% opacity
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Symbols.auto_awesome_rounded, 
                  color: Color(0xFFF59E0B), // Golden Amber
                  size: 20.0,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  mainAxisSize: .min,
                  children: [
                    Text(
                      "tabs.stats.analytics.wrapped.tileTitle".t(context, month),
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      teaser,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.semi(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              Icon(
                Symbols.chevron_right_rounded,
                color: context.flowColors.semi,
                size: 20.0,
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  @override
  Future<void> fetch() async {
    try {
      final List<Transaction> transactions = await ObjectBox()
          .transcationsByRange(TimeRange.thisMonth(), includeTransfers: false);

      int count = 0;
      double biggest = 0.0;

      for (final Transaction transaction in transactions) {
        count++;
        if (transaction.type != TransactionType.expense) continue;

        final double? converted = transaction.money.tryConvertAmount(
          primaryCurrency,
          rates,
        );
        if (converted == null) continue;

        final double magnitude = converted.abs();
        if (magnitude > biggest) biggest = magnitude;
      }

      entryCount = count;
      biggestExpense = biggest;
    } finally {
      if (mounted) setState(() {});
    }
  }
}
