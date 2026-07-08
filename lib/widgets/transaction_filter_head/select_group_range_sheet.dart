import "package:flow/data/transaction_filter.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons_flow/symbols.dart";

/// Pops with [TransactionSearchData]
class SelectGroupRangeSheet extends StatelessWidget {
  final TransactionGroupRange? selected;

  const SelectGroupRangeSheet({super.key, this.selected});

  IconData _getIconForRange(TransactionGroupRange range) {
    return switch (range) {
      TransactionGroupRange.hour => Symbols.schedule_rounded,
      TransactionGroupRange.day => Symbols.calendar_view_day_rounded,
      TransactionGroupRange.week => Symbols.calendar_view_week_rounded,
      TransactionGroupRange.month => Symbols.calendar_view_month_rounded,
      TransactionGroupRange.year => Symbols.calendar_today_rounded,
      TransactionGroupRange.allTime => Symbols.all_inclusive_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final TransactionGroupRange currentSelected = selected ?? TransactionGroupRange.day;

    return ModalSheet.scrollable(
      title: Text("transactions.query.filter.groupBy".t(context)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: TransactionGroupRange.values.map((range) {
          final bool isSelected = currentSelected == range;
          final Color textColor = isSelected 
              ? context.colorScheme.primary 
              : context.colorScheme.onSurface;

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
            title: Text(
              range.localizedNameContext(context),
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: textColor,
              ),
            ),
            leading: Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: isSelected 
                    ? context.colorScheme.primary.withAlpha(0x1A)
                    : context.colorScheme.onSurface.withAlpha(0x0A),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconForRange(range),
                size: 20.0,
                color: isSelected 
                    ? context.colorScheme.primary
                    : context.colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: isSelected
                ? Icon(Symbols.check_circle_rounded, color: context.colorScheme.primary)
                : Icon(Symbols.circle, color: context.colorScheme.onSurface.withAlpha(0x33)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            onTap: () {
              context.pop(range);
            },
          );
        }).toList(),
      ),
    );
  }
}
