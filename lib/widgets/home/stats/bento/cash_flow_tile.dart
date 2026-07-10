import "package:flow/data/money.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/extensions.dart";
import "package:flow/utils/primary_currency_dependent_state.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/home/stats/bento/bento_tile.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:moment_dart/moment_dart.dart";

/// Bento preview of cash flow for the selected range: a hero net "Saved" or
/// "Overspent" figure, a single stacked in/out flow bar, and the labeled
/// income and expense totals anchored to each side of the bar.
class CashFlowTile extends StatefulWidget {
  final TimeRange range;

  const CashFlowTile({super.key, required this.range});

  @override
  State<CashFlowTile> createState() => _CashFlowTileState();
}

class _CashFlowTileState extends State<CashFlowTile>
    with PrimaryCurrencyDependentState<CashFlowTile> {
  bool busy = true;
  bool loaded = false;

  double income = 0.0;
  double expense = 0.0;

  @override
  void didUpdateWidget(CashFlowTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.range != oldWidget.range) fetch();
  }

  @override
  Widget build(BuildContext context) {
    final double net = income - expense;
    final bool saved = net >= 0;
    final bool empty = income <= 0 && expense <= 0;

    final Color netColor = saved
        ? context.flowColors.income
        : const Color(0xFFDE2D26); // HTML text-[#de2d26]

    return BentoTile(
      accent: const Color(0xFF10B981), // Emerald
      label: "tabs.stats.analytics.cashFlow".t(context),
      icon: Symbols.swap_vert_rounded,
      height: 170.0,
      busy: busy && !loaded,
      onTap: () => context.push("/stats/cash-flow"),
      child: empty
          ? Text(
              "tabs.stats.analytics.cashFlow.noMovement".t(context),
              style: context.textTheme.bodySmall?.semi(context),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      saved
                          ? Symbols.trending_up_rounded
                          : Symbols.trending_down_rounded,
                      color: netColor,
                      size: 16.0,
                    ),
                    const SizedBox(width: 6.0), // HTML gap-1.5
                    Text(
                      (saved
                              ? "tabs.stats.analytics.saved"
                              : "tabs.stats.analytics.overspent")
                          .t(context),
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF6B7280), // HTML text-gray-500
                        fontSize: 14.0, // HTML text-sm
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4.0), // HTML mb-1
                MoneyText(
                  Money(saved ? net : -net, primaryCurrency),
                  style: context.textTheme.headlineLarge?.copyWith(
                    color: netColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 28.0,
                    height: 1.0,
                    letterSpacing: -0.5,
                  ),
                  autoSize: true,
                  initiallyAbbreviated: true,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB), // HTML bg-gray-50
                    borderRadius: BorderRadius.circular(12.0), // HTML rounded-xl
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 6.0,
                          height: 6.0,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6.0),
                        Text(
                          "tabs.stats.analytics.in".t(context),
                          style: context.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF6B7280),
                            fontSize: 13.0,
                          ),
                        ),
                        const SizedBox(width: 6.0),
                        MoneyText(
                          Money(income, primaryCurrency),
                          style: context.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF059669),
                            fontWeight: FontWeight.w600,
                            fontSize: 13.0,
                          ),
                          autoSize: false,
                          initiallyAbbreviated: true,
                        ),
                        const SizedBox(width: 12.0),
                        Container(
                          width: 1.0,
                          height: 12.0,
                          color: const Color(0xFFD1D5DB),
                        ),
                        const SizedBox(width: 12.0),
                        Container(
                          width: 6.0,
                          height: 6.0,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6.0),
                        Text(
                          "tabs.stats.analytics.out".t(context),
                          style: context.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF6B7280),
                            fontSize: 13.0,
                          ),
                        ),
                        const SizedBox(width: 6.0),
                        MoneyText(
                          Money(expense, primaryCurrency),
                          style: context.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFFDE2D26),
                            fontWeight: FontWeight.w600,
                            fontSize: 13.0,
                          ),
                          autoSize: false,
                          initiallyAbbreviated: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  @override
  Future<void> fetch() async {
    try {
      final List<Transaction> transactions = await ObjectBox()
          .transcationsByRange(widget.range, includeTransfers: false);

      double nextIncome = 0.0;
      double nextExpense = 0.0;

      for (final Transaction transaction in transactions) {
        final double? converted = transaction.money.tryConvertAmount(
          primaryCurrency,
          rates,
        );
        if (converted == null) continue;

        if (transaction.type == TransactionType.income) {
          nextIncome += converted.abs();
        } else if (transaction.type == TransactionType.expense) {
          nextExpense += converted.abs();
        }
      }

      income = nextIncome;
      expense = nextExpense;
      loaded = true;
    } finally {
      busy = false;
      if (mounted) setState(() {});
    }
  }
}
