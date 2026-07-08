import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/modal_overflow_bar.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons_flow/symbols.dart";

/// Pops with a list of selected [TransactionType]s.
class SelectMultiTransactionTypeSheet extends StatefulWidget {
  final Iterable<TransactionType>? currentlySelected;

  const SelectMultiTransactionTypeSheet({super.key, this.currentlySelected});

  @override
  State<SelectMultiTransactionTypeSheet> createState() =>
      _SelectMultiTransactionTypeSheetState();
}

class _SelectMultiTransactionTypeSheetState
    extends State<SelectMultiTransactionTypeSheet> {
  late Set<TransactionType> _selectedTypes;

  @override
  void initState() {
    super.initState();
    _selectedTypes = widget.currentlySelected?.toSet() ?? {};
  }
  
  Color _getColorForType(BuildContext context, TransactionType type) {
    return switch (type) {
      TransactionType.income => context.flowColors.income,
      TransactionType.expense => context.flowColors.expense,
      TransactionType.transfer => context.flowColors.semi,
    };
  }
  
  IconData _getIconForType(TransactionType type) {
    return switch (type) {
      TransactionType.income => Symbols.download_rounded,
      TransactionType.expense => Symbols.upload_rounded,
      TransactionType.transfer => Symbols.sync_alt_rounded,
    };
  }

  void _toggleSelectAll() {
    if (_selectedTypes.length == TransactionType.values.length) {
      _selectedTypes.clear();
    } else {
      _selectedTypes.addAll(TransactionType.values);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ModalSheet.scrollable(
      title: Text("enum.TransactionType".t(context)),
      trailing: ModalOverflowBar(
        alignment: .end,
        children: [
          TextButton.icon(
            onPressed: pop,
            icon: const Icon(Symbols.check_rounded),
            label: Text("general.done".t(context)),
          ),
        ],
      ),
      leading: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _toggleSelectAll,
              child: Text(
                _selectedTypes.length == TransactionType.values.length
                    ? "general.select.clear".t(context)
                    : "general.select.all".t(context),
              ),
            ),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: TransactionType.values
            .map(
              (value) {
                final bool isSelected = _selectedTypes.contains(value);
                final Color activeColor = _getColorForType(context, value);
                final Color textColor = isSelected 
                    ? activeColor 
                    : context.colorScheme.onSurface;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
                  title: Text(
                    value.localizedNameContext(context),
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: textColor,
                    ),
                  ),
                  leading: Container(
                    width: 40.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      color: activeColor.withAlpha(0x1A),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getIconForType(value),
                      size: 20.0,
                      color: activeColor,
                    ),
                  ),
                  trailing: Icon(
                    isSelected ? Symbols.check_circle_rounded : Symbols.circle,
                    color: isSelected
                        ? activeColor
                        : context.colorScheme.onSurface.withAlpha(0x33),
                  ),
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedTypes.remove(value);
                      } else {
                        _selectedTypes.add(value);
                      }
                    });
                  },
                );
              },
            )
            .toList(),
      ),
    );
  }

  void pop() {
    context.pop(_selectedTypes.toList());
  }
}
