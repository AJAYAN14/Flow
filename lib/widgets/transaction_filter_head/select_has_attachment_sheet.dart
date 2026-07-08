import "package:flow/l10n/extensions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/optional.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons_flow/symbols.dart";

/// Pops with an [Optional]\<bool> indicating whether to filter for transactions
class SelectHasAttachmentSheet extends StatelessWidget {
  final bool? initialSelected;

  const SelectHasAttachmentSheet({super.key, this.initialSelected});

  String suffix(BuildContext context, bool? value) => switch (value) {
    null => ".all".t(context),
    true => "#true".t(context),
    false => "#false".t(context),
  };

  IconData _getIconData(bool? value) => switch (value) {
    null => Symbols.all_inclusive_rounded,
    true => Symbols.attach_file_rounded,
    false => Symbols.block_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return ModalSheet.scrollable(
      title: Text("transactions.query.filter.hasAttachments".t(context)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [null, true, false].map((value) {
          final bool isSelected = initialSelected == value;
          final Color textColor = isSelected 
              ? context.colorScheme.primary 
              : context.colorScheme.onSurface;
          
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
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
                _getIconData(value),
                size: 20.0,
                color: isSelected 
                    ? context.colorScheme.primary
                    : context.colorScheme.onSurfaceVariant,
              ),
            ),
            title: Text(
              "transactions.query.filter.hasAttachments${suffix(context, value)}".t(context),
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: textColor,
              ),
            ),
            trailing: isSelected
                ? Icon(Symbols.check_circle_rounded, color: context.colorScheme.primary)
                : Icon(Symbols.circle, color: context.colorScheme.onSurface.withAlpha(0x33)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            onTap: () {
              context.pop(Optional<bool>(value));
            },
          );
        }).toList(),
      ),
    );
  }
}
