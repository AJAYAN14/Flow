import "package:flow/l10n/extensions.dart";
import "package:flow/theme/navbar_theme.dart";
import "package:flow/widgets/home/navbar/navbar_button.dart";
import "package:flutter/material.dart";
import "package:flutter/physics.dart";
import "package:material_symbols_icons_flow/symbols.dart";

class PortalSpringCurve extends Curve {
  const PortalSpringCurve({
    this.mass = 1.0,
    this.stiffness = 180.0,
    this.damping = 22.0,
  });

  final double mass;
  final double stiffness;
  final double damping;

  @override
  double transformInternal(double t) {
    final simulation = SpringSimulation(
      SpringDescription(mass: mass, stiffness: stiffness, damping: damping),
      0.0,
      1.0,
      0.0,
    );
    return simulation.x(t).clamp(-0.1, 1.1);
  }
}

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
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999.9),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / 4;
          const double indicatorPadding = 4.0;

          return Stack(
            children: [
              // Sliding indicator — inset by indicatorPadding on all sides,
              // matching Nemo's indicatorPadding = 4.dp
              AnimatedPositioned(
                left: activeIndex * tabWidth + indicatorPadding,
                top: indicatorPadding,
                bottom: indicatorPadding,
                width: tabWidth - indicatorPadding * 2,
                duration: const Duration(milliseconds: 400),
                curve: const PortalSpringCurve(stiffness: 200, damping: 15),
                child: Container(
                  decoration: BoxDecoration(
                    color: navbarTheme.activeIconColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999.9),
                  ),
                ),
              ),
              // Tab buttons
              Row(
                children: [
                  NavbarButton(
                    index: 0,
                    label: "tabs.home".t(context),
                    icon: Symbols.circle_rounded,
                    onTap: onTap,
                    activeIndex: activeIndex,
                  ),
                  NavbarButton(
                    index: 1,
                    label: "tabs.stats".t(context),
                    icon: Symbols.bar_chart_rounded,
                    onTap: onTap,
                    activeIndex: activeIndex,
                  ),
                  NavbarButton(
                    index: 2,
                    label: "tabs.accounts".t(context),
                    icon: Symbols.wallet_rounded,
                    onTap: onTap,
                    activeIndex: activeIndex,
                  ),
                  NavbarButton(
                    index: 3,
                    label: "tabs.profile".t(context),
                    icon: Symbols.person_rounded,
                    onTap: onTap,
                    activeIndex: activeIndex,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
