import "package:flow/data/money.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/utils/optional.dart";
import "package:flow/widgets/general/directional_chevron.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/sheets/select_currency_icu_pattern.dart";
import "package:flutter/material.dart";
import "package:flow/widgets/general/premium_list_tile.dart";
import "package:material_symbols_icons_flow/symbols.dart";

class MoneyFormattingPreferencesPage extends StatefulWidget {
  const MoneyFormattingPreferencesPage({super.key});

  @override
  State<MoneyFormattingPreferencesPage> createState() =>
      _MoneyFormattingPreferencesPageState();
}

class _MoneyFormattingPreferencesPageState
    extends State<MoneyFormattingPreferencesPage> {
  @override
  Widget build(BuildContext context) {
    final bool preferFullAmounts = LocalPreferences().preferFullAmounts.get();
    final bool useCurrencySymbol = LocalPreferences().useCurrencySymbol.get();

    return Scaffold(
      appBar: AppBar(title: Text("preferences.moneyFormatting".t(context))),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: .start,
            children: [
              const SizedBox(height: 16.0),
              Center(
                child: MoneyText(
                  Money(12345678.90, UserPreferencesService().primaryCurrency),
                  initiallyAbbreviated: !preferFullAmounts,
                  tapToToggleAbbreviation: false,
                  style: context.textTheme.displaySmall,
                ),
              ),
              const SizedBox(height: 24.0),
              PremiumListGroup(
                children: [
                  PremiumListTile(
                    title: Text(
                      "preferences.moneyFormatting.preferFull".t(context),
                    ),
                    subtitle: Text(
                      "preferences.moneyFormatting.preferFull.description".t(context),
                    ),
                    leading: Symbols.numbers_rounded,
                    accent: const Color(0xFF3B82F6), // Blue
                    showChevron: false,
                    onTap: () => updatePreferFullAmounts(!preferFullAmounts),
                    trailing: Checkbox(
                      value: preferFullAmounts,
                      onChanged: updatePreferFullAmounts,
                    ),
                  ),
                  const Divider(height: 1.0, indent: 64.0, color: Color(0xFFF1F5F9)),
                  PremiumListTile(
                    title: Text(
                      "preferences.moneyFormatting.useCurrencySymbol".t(context),
                    ),
                    subtitle: Text(
                      "preferences.moneyFormatting.useCurrencySymbol.description".t(context),
                    ),
                    leading: Symbols.attach_money_rounded,
                    accent: const Color(0xFF10B981), // Emerald
                    showChevron: false,
                    onTap: () => updateUseCurrencySymbol(!useCurrencySymbol),
                    trailing: Checkbox(
                      value: useCurrencySymbol,
                      onChanged: updateUseCurrencySymbol,
                    ),
                  ),
                  const Divider(height: 1.0, indent: 64.0, color: Color(0xFFF1F5F9)),
                  PremiumListTile(
                    title: Text(
                      "preferences.moneyFormatting.setICUPattern".t(context),
                    ),
                    leading: Symbols.tune_rounded,
                    accent: const Color(0xFF8B5CF6), // Purple
                    onTap: updateCustomICUCurrencyFormatter,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void updatePreferFullAmounts(bool? newPreferFullAmounts) async {
    if (newPreferFullAmounts == null) return;

    await LocalPreferences().preferFullAmounts.set(newPreferFullAmounts);

    if (mounted) setState(() {});
  }

  void updateUseCurrencySymbol(bool? newUseCurrencySymbol) async {
    if (newUseCurrencySymbol == null) return;

    await LocalPreferences().useCurrencySymbol.set(newUseCurrencySymbol);

    if (mounted) setState(() {});
  }

  void updateCustomICUCurrencyFormatter() async {
    final Optional<String?>? result = await showModalBottomSheet(
      context: context,
      builder: (context) => SelectCurrencyIcuPattern(),
      isScrollControlled: true,
    );

    if (result == null) return;

    UserPreferencesService().icuCurrencyFormattingPattern = result.value;

    setState(() {});
  }
}
