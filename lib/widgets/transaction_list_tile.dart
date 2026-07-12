import "package:flow/data/flow_icon.dart";
import "package:flow/data/money.dart";
import "package:flow/data/transaction_filter.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/entity/transaction/extensions/default/transfer.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/providers/accounts_provider.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/extensions/transaction.dart";
import "package:flow/widgets/general/directional_slidable.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/transaction_list_tile/transaction_subtitle.dart";
import "package:flow/widgets/transaction_list_tile_theme.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_slidable/flutter_slidable.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:moment_dart/moment_dart.dart";

class TransactionListTile extends StatelessWidget {
  final TransactionListTileThemeData? theme;

  final Transaction transaction;

  final VoidCallback? recoverFromTrashFn;
  final VoidCallback? moveToTrashFn;
  final VoidCallback? duplicateFn;
  final Function([bool confirm])? confirmFn;

  final Key? dismissibleKey;

  final bool combineTransfers;

  final bool? overrideObscure;

  /// Determines what date/time to show. i.e.:
  ///
  /// * [TransactionGroupRange.hour] - Hour and minute
  /// * [TransactionGroupRange.day] - Hour and minute
  /// * [TransactionGroupRange.week] - Calendar date with hour and minute
  /// * [TransactionGroupRange.month] - Calendar date with hour and minute
  /// * [TransactionGroupRange.year] - Calendar date with hour and minute
  ///
  /// Defaults to [TransactionGroupRange.day]
  final TransactionGroupRange? groupRange;

  /// When true, the list is in selection mode. Tapping the row toggles
  /// selection instead of navigating, and slidable actions are suppressed.
  final bool selectionActive;

  /// Whether this transaction is currently in the selection set.
  final bool selected;

  /// Called when the user taps to toggle selection. When non-null, tapping
  /// the leading icon always toggles regardless of [selectionActive].
  final VoidCallback? onSelectionToggle;

  /// Renders an eye badge on the leading icon to mark the row as a read-only
  /// preview — e.g. projected recurring occurrences that aren't real entries.
  final bool preview;

  final bool isFirstInGroup;
  final bool isLastInGroup;

  const TransactionListTile({
    super.key,
    required this.transaction,
    required this.recoverFromTrashFn,
    required this.moveToTrashFn,
    required this.combineTransfers,
    this.groupRange = TransactionGroupRange.day,
    this.confirmFn,
    this.duplicateFn,
    this.dismissibleKey,
    this.overrideObscure,
    this.theme,
    this.selectionActive = false,
    this.selected = false,
    this.onSelectionToggle,
    this.preview = false,
    this.isFirstInGroup = true,
    this.isLastInGroup = true,
  });

  @override
  Widget build(BuildContext context) {
    final TransactionListTileThemeData effectiveTheme =
        TransactionListTileTheme.maybeOf(context)?.data.merge(theme) ??
        theme ??
        TransactionListTileThemeData.fallback;

    final bool isLivePending =
        transaction.isPending == true && transaction.isDeleted != true;

    final bool showPendingConfirmation = confirmFn != null && isLivePending;

    final bool showDuplicateButton =
        transaction.isDeleted != true && duplicateFn != null;
    final bool showHoldButton = confirmFn != null && transaction.holdable();
    final bool showConfirmButton = confirmFn != null && isLivePending;

    if ((combineTransfers || showPendingConfirmation) &&
        transaction.isTransfer &&
        !transaction.amount.isNegative) {
      return Container();
    }

    final String resolvedTitle = switch (transaction.title) {
      String title when title.isNotEmpty => title,
      _ =>
        ((effectiveTheme.useCategoryNameForUntitledTransactionsOrDefault
                ? transaction.category.target?.name
                : null) ??
            "transaction.fallbackTitle".t(context)),
    };

    final Transfer? transfer = transaction.isTransfer
        ? transaction.extensions.transfer
        : null;

    final List<InlineSpan> subtitleComponents = [
      TextSpan(
        text: (transaction.isTransfer && combineTransfers)
            ? "${AccountsProvider.of(context).getName(transfer!.fromAccountUuid)} → ${AccountsProvider.of(context).getName(transfer.toAccountUuid)}"
            : (AccountsProvider.of(context).getName(transaction.accountUuid) ??
                  transaction.account.target?.name),
      ),
      if (effectiveTheme.showCategoryOrDefault &&
          transaction.category.target != null)
        TextSpan(text: transaction.category.target!.name),
      if (effectiveTheme.showExternalSourceOrDefault)
        if (transaction.externalProviderName
            case String externalProviderName) ...[
              TextSpan(text: externalProviderName),
        ],
      TextSpan(text: dateString),
      if (transaction.transactionDate.isFuture)
        TextSpan(
          text: transaction.isPending == true
              ? "transaction.pending".t(context)
              : "transaction.pending.preapproved".t(context),
        ),
    ];

    final WidgetSpan? titleLeadingIconSpan = transaction.isRecurring
        ? titleIconSpan(context, Symbols.repeat_rounded)
        : (transaction.transactionDate.isFutureAnchored(
                Moment.now().startOfNextMinute(),
              )
              ? titleIconSpan(
                  context,
                  Symbols.search_activity_rounded,
                  color: transaction.isPending == true
                      ? context.colorScheme.onSurface.withAlpha(0xc0)
                      : context.flowColors.income,
                )
              : null);

    final Widget visualLeading = selected
        ? FlowIcon(FlowIconData.icon(Symbols.check_rounded), plated: true)
        : preview
        ? _previewBadged(context, buildLeading(context, effectiveTheme))
        : buildLeading(context, effectiveTheme);

    final Widget leading = onSelectionToggle != null
        ? GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              HapticFeedback.selectionClick();
              onSelectionToggle!();
            },
            child: visualLeading,
          )
        : visualLeading;

    final Widget listTile = Material(
      type: MaterialType.card,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: isFirstInGroup ? const Radius.circular(24.0) : Radius.zero,
          bottom: isLastInGroup ? const Radius.circular(24.0) : Radius.zero,
        ),
      ),
      color: selected
          ? context.colorScheme.primary.withAlpha(0x20)
          : Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: selectionActive
                ? () {
                    HapticFeedback.selectionClick();
                    (onSelectionToggle ?? () {})();
                  }
                : () {
                    HapticFeedback.lightImpact();
                    context.push("/transaction/${transaction.id}");
                  },
            child: Padding(
              padding: effectiveTheme.paddingOrDefault,
              child: Column(
                children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: effectiveTheme.spacingOrDefault,
                children: [
                  leading,
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: .start,
                      spacing: effectiveTheme.titleSpacingOrDefault,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              if (titleLeadingIconSpan != null) ...[
                                titleLeadingIconSpan,
                                TextSpan(text: " "),
                              ],
                              TextSpan(text: resolvedTitle),
                            ],
                            style: context.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: context.colorScheme.onSurface,
                              fontFamilyFallback: const ['PingFang SC', 'Heiti SC', 'Microsoft YaHei'],
                            ),
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        TransactionSubtitle(components: subtitleComponents),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: .end,
                    spacing: effectiveTheme.titleSpacingOrDefault,
                    children: [
                      MoneyText(
                        transaction.money,
                        displayAbsoluteAmount:
                            transaction.isTransfer && combineTransfers,
                        style: context.textTheme.bodyLarge?.copyWith(
                          color: transaction.type.color(context),
                          fontWeight: FontWeight.bold,
                        ),
                        overrideObscure: overrideObscure,
                      ),
                      if (combineTransfers &&
                          AccountsProvider.of(context).ready &&
                          transaction.extensions.transfer?.conversionRate !=
                              null &&
                          transaction.extensions.transfer?.conversionRate !=
                              1.0)
                        MoneyText(
                          Money(
                            transaction.money.amount *
                                transaction
                                    .extensions
                                    .transfer!
                                    .conversionRate!,
                            AccountsProvider.of(context)
                                .get(
                                  transaction
                                      .extensions
                                      .transfer!
                                      .toAccountUuid,
                                )!
                                .currency,
                          ),
                          displayAbsoluteAmount: true,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colorScheme.onSurface.withAlpha(
                              0x80,
                            ),
                          ),
                          overrideObscure: overrideObscure,
                        ),
                    ],
                  ),
                ],
              ),
              if (showPendingConfirmation) ...[
                SizedBox(height: effectiveTheme.spacingOrDefault),
                Row(
                  mainAxisAlignment: .end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        confirmFn!();
                      },
                      label: Text("general.confirm".t(context)),
                      icon: Icon(Symbols.check_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
              ],
            ],
          ),
        ),
      ),
      if (!isLastInGroup)
        Padding(
          padding: const EdgeInsets.only(left: 76.0),
          child: Divider(
            height: 1.0,
            thickness: 0.5,
            color: context.colorScheme.outlineVariant.withAlpha(0x40),
          ),
        ),
    ],
  ),
);

    final List<SlidableAction> startActions = [
      if (showDuplicateButton)
        SlidableAction(
          onPressed: (context) {
            HapticFeedback.mediumImpact();
            duplicateFn!();
          },
          icon: Symbols.content_copy_rounded,
          backgroundColor: context.flowColors.semi,
        ),
    ];

    final List<SlidableAction> endActions = [
      if (showConfirmButton)
        SlidableAction(
          onPressed: (context) {
            HapticFeedback.mediumImpact();
            confirmFn!();
          },
          icon: Symbols.check_rounded,
          backgroundColor: context.colorScheme.primary,
        ),
      if (showHoldButton)
        SlidableAction(
          onPressed: (context) {
            HapticFeedback.mediumImpact();
            confirmFn!(false);
          },
          icon: Symbols.cancel_rounded,
          backgroundColor: context.flowColors.expense,
        ),
      if (moveToTrashFn != null &&
          !showHoldButton &&
          transaction.isDeleted != true)
        SlidableAction(
          onPressed: (context) {
            HapticFeedback.heavyImpact();
            moveToTrashFn!();
          },
          icon: Symbols.delete_forever_rounded,
          backgroundColor: context.flowColors.expense,
        ),
      if (recoverFromTrashFn != null &&
          !showHoldButton &&
          transaction.isDeleted == true)
        SlidableAction(
          onPressed: (context) {
            HapticFeedback.mediumImpact();
            recoverFromTrashFn!();
          },
          icon: Symbols.restore_page_rounded,
          backgroundColor: context.flowColors.income,
        ),
    ];

    final Widget result = selectionActive
        ? KeyedSubtree(key: dismissibleKey, child: listTile)
        : DirectionalSlidable(
            key: dismissibleKey,
            groupTag: "transaction_list_tile",
            startActions: startActions,
            endActions: endActions,
            child: listTile,
          );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: result,
    );
  }

  Widget buildLeading(
    BuildContext context,
    TransactionListTileThemeData theme,
  ) {
    late final FlowIconData iconData;
    FlowColorScheme? colorScheme;

    if (transaction.isTransfer) {
      iconData = FlowIconData.icon(Symbols.sync_alt_rounded);
    } else if (theme.useAccountIconForLeadingOrDefault) {
      final account = AccountsProvider.of(context).get(transaction.accountUuid) ?? transaction.account.target;
      iconData = account?.icon ?? FlowIconData.icon(Symbols.circle_rounded);
      colorScheme = account?.colorScheme;
    } else if (transaction.category.target != null) {
      iconData = transaction.category.target!.icon;
      colorScheme = transaction.category.target!.colorScheme;
    } else if ((transaction.title ?? "").trim().isNotEmpty) {
      iconData = FlowIconData.emoji(
        (transaction.title ?? "").trim().characters.first.toString(),
      );
    } else {
      iconData = FlowIconData.icon(Symbols.circle_rounded);
    }

    Color effectiveColor = colorScheme?.primary ?? context.colorScheme.primary;
    if (colorScheme == null && iconData is CharacterFlowIcon) {
      final int hash = (transaction.title ?? "").trim().hashCode;
      effectiveColor = Colors.primaries[hash.abs() % Colors.primaries.length];
    }

    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: effectiveColor.withAlpha(0x1A), // 10% opacity roughly
        shape: BoxShape.circle,
      ),
      child: FlowIcon(
        iconData,
        size: 24.0,
        color: effectiveColor,
        plated: false,
      ),
    );
  }

  /// Overlays a small eye badge on the bottom-right of a leading [icon] to flag
  /// the row as a non-editable preview. There's no shared badge component in the
  /// app, so this is a deliberate one-off.
  Widget _previewBadged(BuildContext context, Widget icon) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        icon,
        Positioned(
          right: -1.0,
          bottom: -1.0,
          child: DecoratedBox(
            // A surface-colored ring separates the badge from the icon plate.
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Icon(
                Symbols.visibility_rounded,
                size: 12.0,
                color: context.flowColors.semi,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String get dateString {
    final DateTime now = Moment.now().startOfNextMinute();

    final bool pending =
        transaction.isPending == true ||
        transaction.transactionDate.isFutureAnchored(now);

    if (pending) return transaction.transactionDate.toMoment().calendar();

    return switch (groupRange) {
      TransactionGroupRange.hour ||
      TransactionGroupRange.day => transaction.transactionDate.toMoment().LT,
      _ => transaction.transactionDate.toMoment().lll,
    };
  }

  WidgetSpan titleIconSpan(
    BuildContext context,
    IconData icon, {
    Color? color,
  }) => WidgetSpan(
    alignment: PlaceholderAlignment.middle,
    child: Icon(
      icon,
      size: context.textTheme.bodyMedium!.fontSize!,
      fill: 0.0,
      color: color,
    ),
  );
}

