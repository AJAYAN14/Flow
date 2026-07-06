import "dart:async";

import "package:flow/constants.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/services/notifications.dart";
import "package:flow/services/sync/icloud_syncer.dart";
import "package:flow/services/transactions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/general/button.dart";
import "package:flow/widgets/general/list_header.dart";
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
  bool _debugICloudBusy = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          const SizedBox(height: 24.0),
          const Center(child: ProfileCard()),
          const SizedBox(height: 24.0),
          ListTile(
            title: Text("tabs.stats.insights".t(context)),
            leading: const Icon(Symbols.insights_rounded),
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
          ListTile(
            title: Text("accounts".t(context)),
            leading: const Icon(Symbols.wallet_rounded),
            onTap: () => context.push("/accounts"),
          ),
          ListTile(
            title: Text("categories".t(context)),
            leading: const Icon(Symbols.category_rounded),
            onTap: () => context.push("/categories"),
          ),
          // ListTile(
          //   title: Text("budgets".t(context)),
          //   leading: const Icon(Symbols.money_bag_rounded),
          //   onTap: () => context.push("/budgets"),
          // ),
          // ListTile(
          //   title: Text("goals".t(context)),
          //   leading: const Icon(Symbols.savings_rounded),
          //   onTap: () => context.push("/goals"),
          // ),
          ListTile(
            title: Text("transaction.tags".t(context)),
            leading: const Icon(Symbols.style_rounded),
            onTap: () => context.push("/transactionTags"),
          ),
          ListTile(
            title: Text("preferences.transactions.pending".t(context)),
            leading: const Icon(Symbols.search_activity_rounded),
            onTap: () => context.push("/transactions/pending"),
          ),
          const SizedBox(height: 32.0),
          ListHeader("tabs.profile.community".t(context)),
          ListTile(
            title: Text("tabs.profile.support".t(context)),
            leading: const Icon(Symbols.favorite_rounded),
            onTap: () => context.push("/support"),
          ),

          ListTile(
            title: Text("tabs.profile.recommend".t(context)),
            leading: const Icon(Symbols.share_rounded),
            onTap: () => context.showUriShareSheet(uri: website),
          ),
          // ListTile(
          //   title: Text("tabs.profile.guide".t(context)),
          //   leading: const Icon(Symbols.book_2_rounded),
          //   onTap: () => openUrl(guideUrl),
          // ),

          const SizedBox(height: 32.0),
          ListHeader("tabs.profile.other".t(context)),
          ListTile(
            title: Text("transaction.deleted".t(context)),
            leading: const Icon(Symbols.delete_rounded),
            onTap: () => context.push("/transactions/deleted"),
          ),
          ListTile(
            title: Text("tabs.profile.backup".t(context)),
            leading: const Icon(Symbols.hard_drive_rounded),
            onTap: () => context.push("/exportOptions"),
          ),
          ListTile(
            title: Text("tabs.profile.import".t(context)),
            leading: const Icon(Symbols.restore_page_rounded),
            onTap: () => context.push("/import"),
          ),
          ListTile(
            title: Text("tabs.profile.preferences".t(context)),
            leading: const Icon(Symbols.settings_rounded),
            onTap: () => context.push("/preferences"),
          ),
          if (flowDebugMode) ...[
            const SizedBox(height: 32.0),
            ListHeader("debug.options".t(context)),
            ListTile(
              title: Text("debug.themeTestPage".t(context)),
              leading: const Icon(Symbols.palette_rounded),
              onTap: () => context.push("/_debug/theme"),
            ),
            ListTile(
              title: Text("debug.viewScheduledNotifications".t(context)),
              leading: const Icon(Symbols.notifications_rounded),
              onTap: () => context.push("/_debug/scheduledNotifications"),
            ),
            ListTile(
              title: Text("debug.iCloudDebugExplorer".t(context)),
              leading: const Icon(Symbols.cloud_rounded),
              onTap: () => context.push("/_debug/iCloud"),
            ),
            ListTile(
              title: Text("debug.scheduleDebugNotification".t(context)),
              leading: const Icon(Symbols.notification_add_rounded),
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
            ListTile(
              title: Text("debug.showDebugNotification".t(context)),
              leading: const Icon(Symbols.notifications_rounded),
              onTap: () => NotificationsService().debugShow(),
              onLongPress: () => Future.delayed(
                const Duration(seconds: 3),
                () => NotificationsService().debugShow(),
              ),
            ),
            ListTile(
              title: Text("debug.clearExchangeRatesCache".t(context)),
              onTap: () => clearExchangeRatesCache(),
              leading: const Icon(Symbols.adb_rounded),
            ),
            ListTile(
              title: Text("debug.populateObjectbox".t(context)),
              leading: const Icon(Symbols.adb_rounded),
              onTap: () => ObjectBox().createAndPutDebugData(),
            ),
            ListTile(
              title: Text(
                _debugDbBusy ? "debug.clearingDatabase".t(context) : "debug.clearObjectbox".t(context),
              ),
              onTap: () => resetDatabase(),
              leading: _debugDbBusy
                  ? const SizedBox(
                      width: 24.0,
                      height: 24.0,
                      child: Spinner.center(),
                    )
                  : const Icon(Symbols.adb_rounded),
            ),
            ListTile(
              title: Text("debug.clearSharedPreferences".t(context)),
              onTap: () => resetPrefs(),
              leading: const Icon(Symbols.adb_rounded),
            ),
            ListTile(
              title: Text("debug.purgeICloudDebugFolder".t(context)),
              onTap: () => debugPurgeICloud(),
              leading: const Icon(Symbols.adb_rounded),
            ),
            ListTile(
              title: Text("debug.jumpToSetupPage".t(context)),
              onTap: () => context.pushReplacement("/setup"),
              leading: const Icon(Symbols.settings_rounded),
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

  void debugPurgeICloud() async {
    if (_debugICloudBusy) return;
    setState(() {
      _debugICloudBusy = true;
    });
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("debug.purgeICloudDebugFolderConfirm".t(context)),
        actions: [
          Button(
            onTap: () => context.pop(true),
            child: Text("debug.confirmDelete".t(context)),
          ),
          Button(onTap: () => context.pop(false), child: Text("general.cancel".t(context))),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final int deletedCount = await ICloudSyncer().debugPurge();

      if (mounted) {
        context.showToast(text: "debug.deletedDebugItems".t(context, deletedCount.toString()));
      }
    } finally {
      _debugICloudBusy = false;
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
