import "dart:io";

import "package:flow/l10n/extensions.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/routes/preferences_page.dart";
import "package:flow/services/local_auth.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/info_text.dart";
import "package:flutter/material.dart";
import "package:logging/logging.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:flow/widgets/general/premium_list_tile.dart";

final Logger _log = Logger("LockApp");

/// This widget expects [LocalAuthService] to be initialized
class LockApp extends StatefulWidget {
  const LockApp({super.key});

  @override
  State<LockApp> createState() => _LockAppState();
}

class _LockAppState extends State<LockApp> {
  @override
  Widget build(BuildContext context) {
    final bool requireLocalAuth = LocalPreferences().requireLocalAuth.get();
    final bool requireLocalAuthOnBlur = LocalPreferences()
        .requireLocalAuthOnBlur
        .get();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(height: 1.0, indent: 64.0, color: Color(0xFFF1F5F9)),
        PremiumListTile(
          leading: Symbols.lock_rounded,
          title: Text("preferences.privacy.appLock".t(context)),
          accent: const Color(0xFFEF4444), // Red
          showChevron: false,
          onTap: () => updateRequireLocalAuth(!requireLocalAuth),
          trailing: Switch(
            value: requireLocalAuth,
            onChanged: updateRequireLocalAuth,
          ),
        ),
        if (requireLocalAuth || requireLocalAuthOnBlur) ...[
          const Divider(height: 1.0, indent: 64.0, color: Color(0xFFF1F5F9)),
          PremiumListTile(
            leading: Symbols.lock_rounded,
            title: Text("preferences.privacy.appLock.lockAfterClosing".t(context)),
            accent: const Color(0xFFF59E0B), // Amber
            showChevron: false,
            onTap: requireLocalAuth ? () => updateRequireLocalAuthOnBlur(!requireLocalAuthOnBlur) : null,
            trailing: Switch(
              value: requireLocalAuthOnBlur,
              onChanged: requireLocalAuth ? updateRequireLocalAuthOnBlur : null,
            ),
          ),
        ],
        if (Platform.isLinux) ...[
          const SizedBox(height: 8.0),
          Frame(
            child: InfoText(
              child: Text(
                "preferences.privacy.appLock.description#iOS".t(context),
              ),
            ),
          ),
        ],
        if (Platform.isAndroid) ...[
          const SizedBox(height: 8.0),
          Frame(
            child: InfoText(
              child: Text(
                "preferences.privacy.appLock.description#Android".t(context),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void updateRequireLocalAuth(bool? newRequireLocalAuth) async {
    if (newRequireLocalAuth == null) return;

    try {
      final bool auth = await LocalAuthService().authenticate();
      if (!auth) throw "Failed to authenticate, cannot change prefs";
    } catch (e, stackTrace) {
      _log.warning("Failed to update requireLocalAuth", e, stackTrace);
      if (mounted) {
        context.showErrorToast(error: "error.failedLocalAuth".t(context));
      }
      return;
    }

    await LocalPreferences().requireLocalAuth.set(newRequireLocalAuth);

    if (!mounted) return;

    PreferencesPage.of(context).reload();
    setState(() {});
  }

  void updateRequireLocalAuthOnBlur(bool? newRequireLocalAuthOnBlur) async {
    if (newRequireLocalAuthOnBlur == null) return;

    if (!LocalPreferences().requireLocalAuth.get()) return;

    await LocalPreferences().requireLocalAuthOnBlur.set(
      newRequireLocalAuthOnBlur,
    );

    if (!mounted) return;

    PreferencesPage.of(context).reload();
    setState(() {});
  }
}
