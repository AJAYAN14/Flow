import "dart:ui";

import "package:flow/l10n/extensions.dart";
import "package:flow/theme/navbar_theme.dart";
import "package:flow/widgets/home/navbar/navbar_button.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons_flow/symbols.dart";

class Navbar extends StatelessWidget {
  final Function(int i) onTap;

  final int activeIndex;

  const Navbar({super.key, required this.onTap, this.activeIndex = 0});

  @override
  Widget build(BuildContext context) {
    final NavbarTheme navbarTheme = Theme.of(context).extension<NavbarTheme>()!;

    return Container(
      height: 72.0,
      constraints: const BoxConstraints(maxWidth: 420.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999.9),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 0.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 32.0,
            offset: Offset(0, 16),
          ),
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 16.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999.9),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
          child: Container(
            color: navbarTheme.backgroundColor.withOpacity(0.75),
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                NavbarButton(
                  index: 0,
                  tooltip: "tabs.home".t(context),
                  icon: Symbols.circle_rounded,
                  onTap: onTap,
                  activeIndex: activeIndex,
                ),
                NavbarButton(
                  index: 1,
                  tooltip: "tabs.stats".t(context),
                  icon: Symbols.bar_chart_rounded,
                  onTap: onTap,
                  activeIndex: activeIndex,
                ),
                NavbarButton(
                  index: 2,
                  tooltip: "tabs.accounts".t(context),
                  icon: Symbols.wallet_rounded,
                  onTap: onTap,
                  activeIndex: activeIndex,
                ),
                NavbarButton(
                  index: 3,
                  tooltip: "tabs.profile".t(context),
                  icon: Symbols.person_rounded,
                  onTap: onTap,
                  activeIndex: activeIndex,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
