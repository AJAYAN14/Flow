import "package:flow/data/multi_currency_flow.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/optional.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter/scheduler.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:moment_dart/moment_dart.dart";

class AccountCard extends StatelessWidget {
  final Account account;

  final Optional<VoidCallback>? onTapOverride;

  final bool useCupertinoContextMenu;

  final bool excludeTransfersInTotal;

  final bool primary;

  final BorderRadius borderRadius;

  const AccountCard({
    super.key,
    required this.account,
    required this.useCupertinoContextMenu,
    this.onTapOverride,
    this.primary = false,
    this.borderRadius = const .all(Radius.circular(24.0)),
    required this.excludeTransfersInTotal,
  });

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();

    final Iterable<Transaction> transactions = account
        .transactions
        .nonPending
        .nonDeleted
        .where((x) => x.transactionDate.isAtSameMonthAs(now));

    final MultiCurrencyFlow flow = MultiCurrencyFlow()
      ..addAll(
        (excludeTransfersInTotal ? transactions.nonTransfers : transactions)
            .map((transaction) => transaction.money),
      );

    final child = Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: borderRadius,
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
        child: InkWell(
          onTap: onTapOverride == null
              ? () => context.push("/account/${account.id}")
              : onTapOverride!.value,
          borderRadius: borderRadius,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: (account.colorScheme.name == "monochrome" 
                            ? const Color(0xFF2563EB) 
                            : account.colorScheme.primary).withAlpha(0x1A),
                        shape: BoxShape.circle,
                      ),
                      child: FlowIcon(
                        account.icon,
                        size: 32.0,
                        color: account.colorScheme.name == "monochrome" 
                            ? const Color(0xFF2563EB) 
                            : account.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                if (primary)
                                  const WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: Padding(
                                      padding: EdgeInsets.only(right: 6.0),
                                      child: Icon(
                                        Symbols.star_rounded,
                                        size: 16.0,
                                        color: Color(0xFFF59E0B),
                                      ),
                                    ),
                                  ),
                                TextSpan(
                                  text:
                                      account.name +
                                      (account.archived
                                          ? " (${"account.archived".t(context)})"
                                          : ""),
                                ),
                              ],
                              style: context.textTheme.titleMedium?.copyWith(
                                color: const Color(0xFF64748B), // Slate 500
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4.0),
                          MoneyText(
                            account.balance,
                            style: context.textTheme.headlineMedium?.copyWith(
                              color: const Color(0xFF1E293B), // Slate 800
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (!account.archived) ...[
                  const SizedBox(height: 24.0),
                  Text(
                    "account.thisMonth".t(context),
                    style: context.textTheme.labelMedium?.copyWith(
                      color: const Color(0xFF94A3B8), // Slate 400
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              TransactionType.income.localizedNameContext(context),
                              style: context.textTheme.labelSmall?.copyWith(
                                color: const Color(0xFF10B981), // Emerald 500
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            MoneyText(
                              flow.getIncomeByCurrency(account.currency),
                              style: context.textTheme.titleMedium?.copyWith(
                                color: const Color(0xFF334155), // Slate 700
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              TransactionType.expense.localizedNameContext(context),
                              style: context.textTheme.labelSmall?.copyWith(
                                color: const Color(0xFFF43F5E), // Rose 500
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            MoneyText(
                              flow.getExpenseByCurrency(account.currency),
                              style: context.textTheme.titleMedium?.copyWith(
                                color: const Color(0xFF334155), // Slate 700
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    if (!useCupertinoContextMenu) return child;

    return CupertinoContextMenu.builder(
      builder: (context, animation) {
        return Padding(
          padding: const EdgeInsets.all(16.0) * animation.value,
          child: child,
        );
      },
      actions: [
        // TODO Why is it still open? Do I really have to pop, then push?
        CupertinoContextMenuAction(
          onPressed: () {
            context.pop();
            SchedulerBinding.instance.addPostFrameCallback((_) {
              context.push("/account/${account.id}/edit");
            });
          },
          isDefaultAction: true,
          trailingIcon: Symbols.edit_rounded,
          child: Text("account.edit".t(context)),
        ),
        CupertinoContextMenuAction(
          onPressed: () {
            context.pop();
            SchedulerBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              context.push(
                "/account/${account.id}/transactions?title=${"account.transactions.title".t(context, account.name)}",
              );
            });
          },
          isDefaultAction: true,
          trailingIcon: Symbols.list_rounded,
          child: Text("account.transactions".t(context)),
        ),
      ],
    );
  }
}
