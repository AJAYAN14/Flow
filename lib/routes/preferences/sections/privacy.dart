import "package:flow/l10n/extensions.dart";
import "package:flow/routes/preferences_page.dart";
import "package:flow/services/user_preferences.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:flow/widgets/general/premium_list_tile.dart";

class Privacy extends StatefulWidget {
  const Privacy({super.key});

  @override
  State<Privacy> createState() => _PrivacyState();
}

class _PrivacyState extends State<Privacy> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PremiumListTile(
          leading: Symbols.password_rounded,
          title: Text("preferences.privacy.maskAtStartup".t(context)),
          accent: const Color(0xFF6366F1), // Indigo
          showChevron: false,
          onTap: () => updatePrivacyMode(!UserPreferencesService().privacyModeUponLaunch),
          trailing: Switch(
            value: UserPreferencesService().privacyModeUponLaunch,
            onChanged: updatePrivacyMode,
          ),
        ),
        const Divider(height: 1.0, indent: 64.0, color: Color(0xFFF1F5F9)),
        PremiumListTile(
          leading: Symbols.earthquake_rounded,
          title: Text("preferences.privacy.maskAtShake".t(context)),
          accent: const Color(0xFF8B5CF6), // Purple
          showChevron: false,
          onTap: () => updatePrivacyModeUponShaking(!UserPreferencesService().privacyModeUponShaking),
          trailing: Switch(
            value: UserPreferencesService().privacyModeUponShaking,
            onChanged: updatePrivacyModeUponShaking,
          ),
        ),
      ],
    );
  }

  void updatePrivacyMode(bool? newPrivacyMode) async {
    if (newPrivacyMode == null) return;

    UserPreferencesService().privacyModeUponLaunch = newPrivacyMode;

    if (!mounted) return;

    PreferencesPage.of(context).reload();
    setState(() {});
  }

  void updatePrivacyModeUponShaking(bool? newPrivacyMode) async {
    if (newPrivacyMode == null) return;

    UserPreferencesService().privacyModeUponShaking = newPrivacyMode;

    if (!mounted) return;

    PreferencesPage.of(context).reload();
    setState(() {});
  }
}
