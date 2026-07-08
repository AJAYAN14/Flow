import "package:flow/data/setup/default_categories.dart";
import "package:flow/entity/category.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/widgets/categories/no_categories.dart";
import "package:flow/widgets/category_card.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons_flow/symbols.dart";

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  QueryBuilder<Category> qb() =>
      ObjectBox().box<Category>().query().order(Category_.createdDate);

  @override
  void initState() {
    super.initState();

    if (TransitiveLocalPreferences().usesNonPrimaryCurrency.get()) {
      ExchangeRatesService().getPrimaryCurrencyRates();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("categories".t(context))),
      body: SafeArea(
        child: StreamBuilder<List<Category>>(
          stream: qb()
              .watch(triggerImmediately: true)
              .map((event) => event.find()),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Spinner.center();
            }

            final List<Category> categories = snapshot.requireData;

            final bool showPresetsButton = !getCategoryPresets().every(
              (preset) =>
                  categories.any((category) => category.uuid == preset.uuid),
            );

            return switch (categories.length) {
              0 => const NoCategories(),
              _ => ValueListenableBuilder(
                valueListenable: ExchangeRatesService().exchangeRatesCache,
                builder: (context, exchangeRatesCache, _) {
                  return ValueListenableBuilder(
                    valueListenable: UserPreferencesService().valueNotifier,
                    builder: (context, userPreferences, child) {
                      final bool excludeTransfersInTotal =
                          userPreferences.excludeTransfersFromFlow;
                      final String primaryCurrency =
                          UserPreferencesService().primaryCurrency;

                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                        child: Column(
                          spacing: 16.0,
                          crossAxisAlignment: .stretch,
                          children: [
                            Surface(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
                              builder: (context) => InkWell(
                                borderRadius: BorderRadius.circular(24.0),
                                onTap: () => context.push("/category/new"),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                                  child: Row(
                                    children: [
                                      const Icon(Symbols.add_rounded, size: 24.0, color: Color(0xFF0F172A)),
                                      const SizedBox(width: 16.0),
                                      Text(
                                        "category.new".t(context),
                                        style: context.textTheme.titleMedium!.semi(context).copyWith(
                                          color: const Color(0xFF0F172A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (showPresetsButton)
                              Surface(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
                                builder: (context) => InkWell(
                                  borderRadius: BorderRadius.circular(24.0),
                                  onTap: () {
                                    context.push(
                                      "/setup/categories?standalone=true&selectAll=false",
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                                    child: Row(
                                      children: [
                                        const Icon(Symbols.category_rounded, size: 24.0, color: Color(0xFF0F172A)),
                                        const SizedBox(width: 16.0),
                                        Text(
                                          "categories.addFromPresets".t(context),
                                          style: context.textTheme.titleMedium!.semi(context).copyWith(
                                            color: const Color(0xFF0F172A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Divider(color: Color(0xFFE2E8F0)), // ui-ux-pro-max slate-200
                            ),
                            ...categories.map(
                              (category) => CategoryCard(
                                category: category,
                                excludeTransfersInTotal:
                                    excludeTransfersInTotal,
                                rates: exchangeRatesCache?.get(primaryCurrency),
                              ),
                            ),
                            const SizedBox(height: 16.0),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            };
          },
        ),
      ),
    );
  }
}
