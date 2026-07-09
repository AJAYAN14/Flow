import "dart:async";

import "package:flow/constants.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/services/notifications.dart";

import "package:flow/services/transactions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/general/button.dart";
import "package:flow/widgets/general/list_header.dart";
import "package:flow/widgets/general/premium_list_tile.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/home/preferences/profile_card.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:moment_dart/moment_dart.dart";
import "package:shared_preferences/shared_preferences.dart";


class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _debugDbBusy = false;
  bool _debugPrefsBusy = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          const SizedBox(height: 24.0),
          const Center(child: ProfileCard()),
          const SizedBox(height: 24.0),
          PremiumListGroup(
            children: [
              PremiumListTile(
                title: Text("tabs.stats.insights".t(context)),
                leading: Symbols.insights_rounded,
                accent: const Color(0xFF8B5CF6), // Purple
                trailing: LocalPreferences().openedInsightsIndex.get()
                    ? null
                    : Badge(
                        label: Text("general.new".t(context)),
                        backgroundColor: context.colorScheme.primary,
                        textColor: context.colorScheme.onPrimary,
                      ),
                onTap: () {
                  final entry = LocalPreferences().openedInsightsIndex;
                  if (!entry.get()) {
                    entry.set(true);
                    setState(() {});
                  }
                  context.push("/stats/insights");
                },
              ),
              const Divider(height: 1.0, indent: 64.0, color: Color(0xFFF1F5F9)), // Slate 100
              PremiumListTile(
                title: Text("accounts".t(context)),
                leading: Symbols.wallet_rounded,
                accent: const Color(0xFF3B82F6), // Blue
                onTap: () => context.push("/accounts"),
              ),
              const Divider(height: 1.0, indent: 64.0, color: Color(0xFFF1F5F9)),
              PremiumListTile(
                title: Text("categories".t(context)),
                leading: Symbols.category_rounded,
                accent: const Color(0xFFF43F5E), // Rose
                onTap: () => context.push("/categories"),
              ),
              const Divider(height: 1.0, indent: 64.0, color: Color(0xFFF1F5F9)),
              PremiumListTile(
                title: Text("transaction.tags".t(context)),
                leading: Symbols.style_rounded,
                accent: const Color(0xFFF59E0B), // Amber
                onTap: () => context.push("/transactionTags"),
              ),
              const Divider(height: 1.0, indent: 64.0, color: Color(0xFFF1F5F9)),
              PremiumListTile(
                title: Text("preferences.transactions.pending".t(context)),
                leading: Symbols.search_activity_rounded,
                accent: const Color(0xFF14B8A6), // Teal
                onTap: () => context.push("/transactions/pending"),
              ),
            ],
          ),

          const SizedBox(height: 32.0),
          ListHeader("tabs.profile.other".t(context), padding: const EdgeInsets.symmetric(horizontal: 24.0)),
          PremiumListGroup(
            children: [
              PremiumListTile(
                title: Text("transaction.deleted".t(context)),
                leading: Symbols.delete_rounded,
                accent: const Color(0xFFEF4444), // Red
                onTap: () => context.push("/transactions/deleted"),
              ),
              const Divider(height: 1.0, indent: 64.0, color: Color(0xFFF1F5F9)),
              PremiumListTile(
                title: Text("tabs.profile.backup".t(context)),
                leading: Symbols.hard_drive_rounded,
                accent: const Color(0xFF8B5CF6), // Purple
                onTap: () => context.push("/exportOptions"),
              ),
              const Divider(height: 1.0, indent: 64.0, color: Color(0xFFF1F5F9)),
              PremiumListTile(
                title: Text("tabs.profile.import".t(context)),
                leading: Symbols.restore_page_rounded,
                accent: const Color(0xFF10B981), // Emerald
                onTap: () => context.push("/import"),
              ),
              const Divider(height: 1.0, indent: 64.0, color: Color(0xFFF1F5F9)),
              PremiumListTile(
                title: Text("tabs.profile.preferences".t(context)),
                leading: Symbols.settings_rounded,
                accent: const Color(0xFF64748B), // Slate 500
                onTap: () => context.push("/preferences"),
              ),
            ],
          ),
          if (flowDebugMode) ...[
            const SizedBox(height: 32.0),
            ListHeader("debug.options".t(context), padding: const EdgeInsets.symmetric(horizontal: 24.0)),
            PremiumListGroup(
              children: [
                PremiumListTile(
                  title: Text("debug.themeTestPage".t(context)),
                  leading: Symbols.palette_rounded,
                  accent: const Color(0xFF94A3B8), // Slate 400
                  onTap: () => context.push("/_debug/theme"),
                ),
                const Divider(height: 1.0, indent: 64.0, color: Color(0xFFF1F5F9)),
                PremiumListTile(
                  title: Text("debug.viewScheduledNotifications".t(context)),
                  leading: Symbols.notifications_rounded,
                  accent: const Color(0xFF94A3B8),
                  onTap: () => context.push("/_debug/scheduledNotifications"),
                ),
                const Divider(height: 1.0, indent: 64.0, color: Color(0xFFF1F5F9)),
                PremiumListTile(
                  title: Text("debug.scheduleDebugNotification".t(context)),
                  leading: Symbols.notification_add_rounded,
                  accent: const Color(0xFF94A3B8),
                  onTap: () {
                    NotificationsService()
                        .debugSchedule(Moment.now().startOfNextMinute())
                        .then((_) {
                          if (context.mounted) {
                            context.showToast(
                              text: "debug.debugNotificationScheduled".t(context),
                            );
                          }
                        });
                  },
                ),
                const Divider(height: 1.0, indent: 64.0, color: Color(0xFFF1F5F9)),
                PremiumListTile(
                  title: Text("debug.showDebugNotification".t(context)),
                  leading: Symbols.notifications_rounded,
                  accent: const Color(0xFF94A3B8),
                  onTap: () => NotificationsService().debugShow(),
                  onLongPress: () => Future.delayed(
                    const Duration(seconds: 3),
                    () => NotificationsService().debugShow(),
                  ),
                ),
                const Divider(height: 1.0, indent: 64.0, color: Color(0xFFF1F5F9)),
                PremiumListTile(
                  title: Text("debug.clearExchangeRatesCache".t(context)),
                  leading: Symbols.adb_rounded,
                  accent: const Color(0xFF94A3B8),
                  onTap: () => clearExchangeRatesCache(),
                ),
                const Divider(height: 1.0, indent: 64.0, color: Color(0xFFF1F5F9)),
                PremiumListTile(
                  title: Text("debug.populateObjectbox".t(context)),
                  leading: Symbols.adb_rounded,
                  accent: const Color(0xFF94A3B8),
                  onTap: () => ObjectBox().createAndPutDebugData(),
                ),
                const Divider(height: 1.0, indent: 64.0, color: Color(0xFFF1F5F9)),
                PremiumListTile(
                  title: Text(
                    _debugDbBusy ? "debug.clearingDatabase".t(context) : "debug.clearObjectbox".t(context),
                  ),
                  leading: Symbols.adb_rounded,
                  accent: const Color(0xFF94A3B8),
                  trailing: _debugDbBusy
                      ? const SizedBox(
                          width: 20.0,
                          height: 20.0,
                          child: Spinner.center(),
                        )
                      : null,
                  onTap: () => resetDatabase(),
                ),
                const Divider(height: 1.0, indent: 64.0, color: Color(0xFFF1F5F9)),
                PremiumListTile(
                  title: Text("debug.clearSharedPreferences".t(context)),
                  leading: Symbols.adb_rounded,
                  accent: const Color(0xFF94A3B8),
                  onTap: () => resetPrefs(),
                ),
                const Divider(height: 1.0, indent: 64.0, color: Color(0xFFF1F5F9)),
                PremiumListTile(
                  title: Text("debug.jumpToSetupPage".t(context)),
                  leading: Symbols.settings_rounded,
                  accent: const Color(0xFF94A3B8),
                  onTap: () => context.pushReplacement("/setup"),
                ),
              ],
            ),
          ],
          const SizedBox(height: 64.0),
          Center(
            child: Text("v$appVersion", style: context.textTheme.labelSmall),
          ),
          Center(
            child: Opacity(
              opacity: 0.5,
              child: Text(
                "tabs.profile.withLoveFromTheCreator".t(context),
                style: context.textTheme.labelSmall,
              ),
            ),
          ),
          const SizedBox(height: 24.0),
          const SizedBox(height: 96.0),
        ],
      ),
    );
  }

  void resetDatabase() async {
    if (_debugDbBusy) return;

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("debug.resetDatabase".t(context)),
        actions: [
          Button(
            onTap: () => context.pop(true),
            child: Text("debug.confirmDelete".t(context)),
          ),
          Button(onTap: () => context.pop(false), child: Text("general.cancel".t(context))),
        ],
      ),
    );

    setState(() {
      _debugDbBusy = true;
    });

    TransactionsService().pauseListeners();

    try {
      if (confirm == true) {
        await ObjectBox().eraseMainData();
      }
    } finally {
      TransactionsService().resumeListeners();

      _debugDbBusy = false;

      if (mounted) {
        setState(() {});
      }
    }
  }

  void resetPrefs() async {
    if (_debugPrefsBusy) return;

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("debug.clearSharedPreferencesConfirm".t(context)),
        actions: [
          Button(
            onTap: () => context.pop(true),
            child: Text("debug.confirmClear".t(context)),
          ),
          Button(onTap: () => context.pop(false), child: Text("general.cancel".t(context))),
        ],
      ),
    );

    setState(() {
      _debugPrefsBusy = true;
    });

    try {
      if (confirm == true) {
        final instanceAvecCache = await SharedPreferencesWithCache.create(
          cacheOptions: SharedPreferencesWithCacheOptions(),
        );
        await instanceAvecCache.clear();
      }
    } finally {
      _debugPrefsBusy = false;

      if (mounted) {
        setState(() {});
      }
    }
  }

  void clearExchangeRatesCache() {
    ExchangeRatesService().debugClearCache();
  }
}
