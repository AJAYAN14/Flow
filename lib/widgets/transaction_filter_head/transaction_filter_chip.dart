import "package:flow/entity/account.dart";
import "package:flow/entity/category.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/utils/extensions/transaction_filter.dart";
import "package:flutter/foundation.dart" hide Category;
import "package:flutter/material.dart";

class TransactionFilterChip<T> extends StatelessWidget {
  final Widget? avatar;
  final Color? iconColor;
  final bool? highlightOverride;

  /// Translation key for the label
  ///
  /// Requires following keys in the translation file:
  /// * `${translationKey}`
  /// * `${translationKey}.all`
  final String translationKey;
  final T? value;
  final T? defaultValue;

  bool get highlight {
    if (highlightOverride != null) {
      return highlightOverride!;
    }

    if (defaultValue == null && value == null) {
      return false;
    }

    if (defaultValue.runtimeType == value.runtimeType) {
      if (value is Set<Account>) {
        final Set<String> defaultValueSet = (defaultValue as Set<Account>)
            .map((account) => account.uuid)
            .toSet();
        final Set<String> valueSet = (value as Set<Account>)
            .map((account) => account.uuid)
            .toSet();

        return !setEquals(defaultValueSet, valueSet);
      }
      if (value is Set<Category>) {
        final Set<String> defaultValueSet = (defaultValue as Set<Category>)
            .map((category) => category.uuid)
            .toSet();
        final Set<String> valueSet = (value as Set<Category>)
            .map((category) => category.uuid)
            .toSet();

        return !setEquals(defaultValueSet, valueSet);
      }
    }

    return value != defaultValue;
  }

  /// * If [defaultValue] and [value] are null, displays translated [translationKey]
  /// * If [defaultValue] isn't null, but [value] is null, displays translated `$translationKey.all`
  /// * Otherwise, `valueLabelOverride(value)` if available, else `value.toString()`.
  ///
  /// First argument is the **current** value, second is the **default**.
  final String Function(T? value, T? defaultValue)? displayLabelOverride;

  /// Override [getValueLabel]. If `null` was returned, continues with the default
  /// implementation. For example, you can typecheck the value to override specific values
  final String? Function(T?)? valueLabelOverride;

  final VoidCallback onSelect;

  const TransactionFilterChip({
    super.key,
    this.avatar,
    this.iconColor,
    this.value,
    this.defaultValue,
    this.displayLabelOverride,
    required this.translationKey,
    required this.onSelect,
    this.valueLabelOverride,
    this.highlightOverride,
  });

  @override
  Widget build(BuildContext context) {
    // Premium chip colors
    const premiumBlue = Color(0xFF2563EB); // Royal Blue
    const unselectedBg = Color(0xFFFFFFFF); // White
    const selectedBg = Color(0xFFEFF6FF); // Blue 50
    const unselectedText = Color(0xFF334155); // Slate 700
    const selectedText = premiumBlue;
    const borderColor = Color(0xFFE2E8F0); // Slate 200

    return FilterChip(
      showCheckmark: false,
      avatar: avatar != null
          ? IconTheme.merge(
              data: IconThemeData(
                color: highlight ? selectedText : (iconColor ?? unselectedText),
                size: 18.0,
              ),
              child: avatar!,
            )
          : null,
      label: Text(
        getLabel(context), 
        overflow: TextOverflow.ellipsis,
      ),
      labelStyle: TextStyle(
        color: highlight ? selectedText : unselectedText,
        fontWeight: highlight ? FontWeight.w600 : FontWeight.w500,
      ),
      backgroundColor: unselectedBg,
      selectedColor: selectedBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100.0),
        side: BorderSide(
          color: highlight ? premiumBlue.withAlpha(0x40) : borderColor,
        ),
      ),
      elevation: 0,
      pressElevation: 0,
      onSelected: (_) => onSelect(),
      selected: highlight,
    );
  }

  String getLabel(BuildContext context) {
    if (displayLabelOverride != null) {
      return displayLabelOverride!(value, defaultValue);
    }

    if (value != null) {
      return TransactionFilterHelpers.getValueLabel(
        context,
        value: value,
        translationKey: translationKey,
        valueLabelOverride: valueLabelOverride,
      );
    }

    if (defaultValue == null) {
      return translationKey.t(context);
    } else {
      return "$translationKey.all".t(context);
    }
  }
}
