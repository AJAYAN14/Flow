import "package:flow/data/exchange_rates.dart";
import "package:flow/data/multi_currency_flow.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/optional.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:moment_dart/moment_dart.dart";

class CategoryCard extends StatelessWidget {
  final Category category;

  final BorderRadius borderRadius;

  final ExchangeRates? rates;

  final bool excludeTransfersInTotal;

  final bool showAmount;

  final Optional<VoidCallback>? onTapOverride;

  final Widget? trailing;

  const CategoryCard({
    super.key,
    required this.category,
    this.onTapOverride,
    this.trailing,
    this.rates,
    this.showAmount = true,
    this.excludeTransfersInTotal = true,
    this.borderRadius = const BorderRadius.all(Radius.circular(24.0)),
  });

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();

    final String primaryCurrency = UserPreferencesService().primaryCurrency;

    final Iterable<Transaction> transactions = category
        .transactions
        .nonPending
        .nonDeleted
        .where((x) => x.transactionDate.isAtSameMonthAs(now));

    final MultiCurrencyFlow flow = MultiCurrencyFlow()
      ..addAll(
        (excludeTransfersInTotal ? transactions.nonTransfers : transactions)
            .map((transaction) => transaction.money),
      );

    final FlowColorScheme colorScheme = category.colorScheme;

    return Surface(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      builder: (context) => InkWell(
        borderRadius: borderRadius,
        onTap: onTapOverride == null
            ? () => context.push("/category/${category.id}")
            : onTapOverride!.value,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FlowIcon(
                category.icon,
                size: 24.0,
                plated: true,
                colorScheme: colorScheme,
                platePadding: const EdgeInsets.all(8.0),
                borderRadius: BorderRadius.circular(10.0),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: context.textTheme.titleMedium!.semi(context).copyWith(
                            color: const Color(0xFF0F172A),
                          ),
                    ),
                    if (showAmount) ...[
                      const SizedBox(height: 2.0),
                      DefaultTextStyle.merge(
                        style: context.textTheme.bodyMedium!.copyWith(
                          color: const Color(0xFF475569),
                          height: 1.2,
                        ),
                        child: MoneyText(flow.merge(primaryCurrency, rates).totalFlow),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 16.0), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}
