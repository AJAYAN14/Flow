import "dart:async";
import "dart:developer";
import "dart:io";

import "package:flow/data/flow_icon.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/widgets/action_card.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:logging/logging.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:moment_dart/moment_dart.dart";
import "package:simple_icons_flow/simple_icons_flow.dart";

final Logger _log = Logger("SetupOnboardingPage");

class SetupOnboardingPage extends StatefulWidget {
  const SetupOnboardingPage({super.key});

  @override
  State<SetupOnboardingPage> createState() => _SetupOnboardingPageState();
}

class _SetupOnboardingPageState extends State<SetupOnboardingPage> {


  bool busy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("setup.onboarding".t(context))),
      body: busy
          ? SafeArea(child: const Spinner.center())
          : SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    spacing: 16.0,
                    children: [

                      ActionCard(
                        onTap: () => context.push("/import?setupMode=true"),
                        icon: FlowIconData.icon(Symbols.restore_page_rounded),
                        title: "setup.onboarding.importExisting".t(context),
                        subtitle: "setup.onboarding.importExisting.description"
                            .t(context),
                      ),
                      ActionCard(
                        onTap: () => context.push("/setup/currency"),
                        icon: FlowIconData.icon(Symbols.wand_stars_rounded),
                        title: "setup.onboarding.freshStart".t(context),
                        subtitle: "setup.onboarding.freshStart.description".t(
                          context,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }


}
