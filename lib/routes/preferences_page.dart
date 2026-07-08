import "dart:io";

import "package:flow/constants.dart";
import "package:flow/l10n/flow_localizations.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/routes/preferences/language_selection_sheet.dart";
import "package:flow/routes/preferences/sections/haptics.dart";
import "package:flow/routes/preferences/sections/lock_app.dart";
import "package:flow/routes/preferences/sections/privacy.dart";
import "package:flow/services/file_attachment.dart";
import "package:flow/services/local_auth.dart";
import "package:flow/services/notifications.dart";
import "package:flow/services/user_preferences.dart";

import "package:flow/utils/extensions.dart";
import "package:flow/widgets/animated_eny_logo.dart";
import "package:flow/widgets/general/directional_chevron.dart";
import "package:flow/widgets/general/list_header.dart";
import "package:flow/widgets/general/premium_list_tile.dart";
import "package:flow/widgets/sheets/select_currency_sheet.dart";
import "package:flutter/material.dart" hide Flow;
import "package:go_router/go_router.dart";
import "package:logging/logging.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:permission_handler/permission_handler.dart";

final Logger _log = Logger("PreferencesPage");

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => PreferencesPageState();

  static PreferencesPageState of(BuildContext context) {
    return context.findAncestorStateOfType<PreferencesPageState>()!;
  }
}

class PreferencesPageState extends State<PreferencesPage> {
  bool _currencyBusy = false;
  bool _languageBusy = false;

  bool _showLockApp = false;

  @override
  void initState() {
    super.initState();

    LocalAuthService.initialize()
        .then((_) {
          _showLockApp = LocalAuthService.available;

          if (mounted) {
            setState(() {});
          }
        })
        .catchError((_) {
          _log.warning("Failed to initialize local auth service");
        });
  }

  @override
  Widget build(BuildContext context) {


    final bool enableGeo = LocalPreferences().enableGeo.get();
    final bool autoAttachTransactionGeo = LocalPreferences()
        .autoAttachTransactionGeo
        .get();
    final bool pendingTransactionsRequireConfrimation = LocalPreferences()
        .pendingTransactions
        .requireConfrimation
        .get();

    final String currentPrimaryCurrency =
        UserPreferencesService().primaryCurrency;

    return Scaffold(
      appBar: AppBar(title: Text("preferences".t(context))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          children: [
            PremiumListGroup(
              children: [
                PremiumListTile(
                  title: Text("preferences.sync".t(context)),
                  leading: Symbols.sync_rounded,
                  accent: const Color(0xFF3B82F6), // Blue
                  onTap: () => _pushAndRefreshAfter("/preferences/sync"),
                ),
                if (flowDebugMode || NotificationsService.schedulingSupported) ...[
                  const Divider(height: 1.0, indent: 64.0, color: Color(0xFFF1F5F9)),
                  PremiumListTile(
                    title: Text("preferences.reminders".t(context)),
                    leading: Symbols.notifications_rounded,
                    accent: const Color(0xFFF59E0B), // Amber
                    onTap: () => _pushAndRefreshAfter("/preferences/reminders"),
                  ),
                ],
                const Divider(height: 1.0, indent: 64.0, color: Color(0xFFF1F5F9)),
                PremiumListTile(
                  title: Text("preferences.language".t(context)),
                  subtitle: Text(FlowLocalizations.of(context).locale.endonym),
                  leading: Symbols.language_rounded,
                  accent: const Color(0xFF6366F1), // Indigo
                  onTap: () => _updateLanguage(),
                ),
                const Divider(height: 1.0, indent: 64.0, color: Color(0xFFF1F5F9)),
                PremiumListTile(
                  title: Text("preferences.primaryCurrency".t(context)),
                  subtitle: Text(currentPrimaryCurrency),
                  leading: Symbols.universal_currency_alt_rounded,
                  accent: const Color(0xFF10B981), // Emerald
                  onTap: () => _updatePrimaryCurrency(),
                ),
                const Divider(height: 1.0, indent: 64.0, color: Color(0xFFF1F5F9)),
                PremiumListTile(
                  title: Text("preferences.transfer".t(context)),
                  subtitle: Text(
                    "preferences.transfer.description".t(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  leading: Symbols.sync_alt_rounded,
                  accent: const Color(0xFF8B5CF6), // Purple
                  onTap: () => _pushAndRefreshAfter("/preferences/transfer"),
                ),
                const Divider(height: 1.0, indent: 64.0, color: Color(0xFFF1F5F9)),
                PremiumListTile(
                  title: Text("preferences.trashBin".t(context)),
                  leading: Symbols.delete_rounded,
                  accent: const Color(0xFFEF4444), // Red
                  onTap: () => _pushAndRefreshAfter("/preferences/trashBin"),
                ),
                const Divider(height: 1.0, indent: 64.0, color: Color(0xFFF1F5F9)),
                PremiumListTile(
                  title: Text("preferences.moneyFormatting".t(context)),
                  leading: Symbols.numbers_rounded,
                  accent: const Color(0xFF64748B), // Slate 500
                  onTap: () => _pushAndRefreshAfter("/preferences/moneyFormatting"),
                ),
              ],
            ),
            const SizedBox(height: 24.0),
            ListHeader("preferences.integrations".t(context), padding: const EdgeInsets.symmetric(horizontal: 24.0)),
            PremiumListGroup(
              children: [
                PremiumListTile(
                  title: const Text("Eny"),
                  leadingWidget: const SizedBox(
                    width: 20.0,
                    height: 20.0,
                    child: AnimatedEnyLogo(),
                  ),
                  accent: const Color(0xFF8B5CF6), // Purple
                  onTap: () => _pushAndRefreshAfter("/preferences/integrations/eny"),
                ),
              ],
            ),
            const SizedBox(height: 24.0),
            ListHeader("preferences.transactions".t(context), padding: const EdgeInsets.symmetric(horizontal: 24.0)),
            PremiumListGroup(
              children: [
                PremiumListTile(
                  title: Text("preferences.transactions.pending".t(context)),
                  subtitle: Text(
                    pendingTransactionsRequireConfrimation
                        ? "general.enabled".t(context)
                        : "general.disabled".t(context),
                  ),
                  leading: Symbols.search_activity_rounded,
                  accent: const Color(0xFF14B8A6), // Teal
                  onTap: () => _pushAndRefreshAfter("/preferences/pendingTransactions"),
                ),
                const Divider(height: 1.0, indent: 64.0, color: Color(0xFFF1F5F9)),
                PremiumListTile(
                  title: Text("preferences.transactions.geo".t(context)),
                  subtitle: Text(
                    enableGeo
                        ? (autoAttachTransactionGeo
                              ? "preferences.transactions.geo.auto.enabled".t(
                                  context,
                                )
                              : "general.enabled".t(context))
                        : "general.disabled".t(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  leading: Symbols.location_pin_rounded,
                  accent: const Color(0xFFF59E0B), // Amber
                  onTap: () => _pushAndRefreshAfter("/preferences/transactionGeo"),
                ),
                const Divider(height: 1.0, indent: 64.0, color: Color(0xFFF1F5F9)),
                PremiumListTile(
                  title: Text("preferences.transactions.listTile".t(context)),
                  leading: Symbols.list_rounded,
                  accent: const Color(0xFF3B82F6), // Blue
                  onTap: () => _pushAndRefreshAfter(
                    "/preferences/transactionListItemAppearance",
                  ),
                ),
                const Divider(height: 1.0, indent: 64.0, color: Color(0xFFF1F5F9)),
                PremiumListTile(
                  title: Text("preferences.transactionEntryFlow".t(context)),
                  leading: Symbols.automation_rounded,
                  accent: const Color(0xFFEC4899), // Pink
                  onTap: () => _pushAndRefreshAfter("/preferences/transactionEntryFlow"),
                ),
              ],
            ),
            const SizedBox(height: 24.0),
            ListHeader("preferences.appearance".t(context), padding: const EdgeInsets.symmetric(horizontal: 24.0)),
            PremiumListGroup(
              children: [
                PremiumListTile(
                  title: Text("preferences.numpad".t(context)),
                  subtitle: Text(
                    LocalPreferences().usePhoneNumpadLayout.get()
                        ? "preferences.numpad.layout.modern".t(context)
                        : "preferences.numpad.layout.classic".t(context),
                  ),
                  leading: Symbols.dialpad_rounded,
                  accent: const Color(0xFF6366F1), // Indigo
                  onTap: () => _pushAndRefreshAfter("/preferences/numpad"),
                ),
                const Divider(height: 1.0, indent: 64.0, color: Color(0xFFF1F5F9)),
                PremiumListTile(
                  title: Text("preferences.transactionButtonOrder".t(context)),
                  subtitle: Text(
                    "preferences.transactionButtonOrder.description".t(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  leading: Symbols.action_key_rounded,
                  accent: const Color(0xFF10B981), // Emerald
                  onTap: () => _pushAndRefreshAfter("/preferences/transactionButtonOrder"),
                ),
                const Divider(height: 1.0, indent: 64.0, color: Color(0xFFF1F5F9)),
                PremiumListTile(
                  title: Text("preferences.changeVisuals".t(context)),
                  leading: Symbols.moving_rounded,
                  accent: const Color(0xFF8B5CF6), // Purple
                  onTap: () => _pushAndRefreshAfter("/preferences/changeVisuals"),
                ),
              ],
            ),
            const SizedBox(height: 24.0),
            ListHeader("preferences.privacy".t(context), padding: const EdgeInsets.symmetric(horizontal: 24.0)),
            PremiumListGroup(
              children: [
                const Privacy(),
                if (_showLockApp) ...[const LockApp()],
              ],
            ),
            const SizedBox(height: 24.0),
            ListHeader("preferences.hapticFeedback".t(context), padding: const EdgeInsets.symmetric(horizontal: 24.0)),
            const Haptics(),
            const SizedBox(height: 24.0),
            ListHeader("preferences.feedback".t(context), padding: const EdgeInsets.symmetric(horizontal: 24.0)),
            PremiumListGroup(
              children: [
                PremiumListTile(
                  title: Text("fileAttachment.cleanupHangingFiles".t(context)),
                  leading: Symbols.bug_report_rounded,
                  accent: const Color(0xFFEF4444), // Red
                  onTap: () => _deleteHangingFiles(),
                ),
                const Divider(height: 1.0, indent: 64.0, color: Color(0xFFF1F5F9)),
                PremiumListTile(
                  title: Text("preferences.feedback.debugLogs".t(context)),
                  leading: Symbols.bug_report_rounded,
                  accent: const Color(0xFFF59E0B), // Amber
                  onTap: () => context.push("/_debug/logs"),
                ),
              ],
            ),
            const SizedBox(height: 32.0),
          ],
        ),
      ),
    );
  }

  void _updateLanguage() async {
    if (Platform.isIOS) {
      await LocalPreferences().localeOverride.remove().catchError((
        e,
        stackTrace,
      ) {
        _log.warning("Failed to remove locale override", e, stackTrace);
      });
      try {
        await openAppSettings();
        return;
      } catch (e, stackTrace) {
        _log.warning(
          "Failed to open system app settings on iOS",
          e,
          stackTrace,
        );
      }
    }

    if (_languageBusy || !mounted) return;

    setState(() {
      _languageBusy = true;
    });

    try {
      Locale current =
          LocalPreferences().localeOverride.get() ??
          FlowLocalizations.supportedLocales.first;

      final selected = await showModalBottomSheet<Locale>(
        context: context,
        builder: (context) => LanguageSelectionSheet(currentLocale: current),
        isScrollControlled: true,
      );

      if (selected != null) {
        await LocalPreferences().localeOverride.set(selected);
      }
    } finally {
      _languageBusy = false;
    }
  }

  void _updatePrimaryCurrency() async {
    if (_currencyBusy) return;

    setState(() {
      _currencyBusy = true;
    });

    try {
      final String current = UserPreferencesService().primaryCurrency;

      final selected = await showModalBottomSheet<String>(
        context: context,
        builder: (context) => SelectCurrencySheet(currentlySelected: current),
        isScrollControlled: true,
      );

      if (selected != null) {
        UserPreferencesService().primaryCurrency = selected;
      }
    } finally {
      _currencyBusy = false;

      if (mounted) {
        setState(() {});
      }
    }
  }

  void _pushAndRefreshAfter(String path) async {
    await context.push(path);

    // Rebuild to update description text
    if (mounted) setState(() {});
  }


  void _deleteHangingFiles() async {
    final bool? confirmation = await context.showConfirmationSheet(
      isDeletionConfirmation: true,
      title: "fileAttachment.cleanupHangingFiles".t(context),
      child: Text("fileAttachment.cleanupHangingFiles.description".t(context)),
    );

    if (confirmation != true || !mounted) return;

    try {
      final int deleted = await FileAttachmentService().deleteAllOrphans();

      if (mounted) {
        context.showToast(text: "fileAttachment.delete.success".t(context));
      }

      _log.info("Deleted $deleted hanging files");
    } catch (e, stackTrace) {
      _log.warning("Failed to delete hanging files", e, stackTrace);

      if (mounted) {
        context.showErrorToast(error: "error.sync.fileNotFound".t(context));
      }
    }
  }

  void reload() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }
}
