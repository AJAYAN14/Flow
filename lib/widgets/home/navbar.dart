import "package:flow/l10n/extensions.dart";
import "package:flow/theme/navbar_theme.dart";
import "package:flow/widgets/home/navbar/navbar_button.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons_flow/symbols.dart";

class Navbar extends StatelessWidget {
  final Function(int i) onTap;

  final int activeIndex;

  /// Continuous page position from [TabController.animation].
  /// When provided, the indicator tracks the swipe gesture in real-time.
  final Animation<double>? pageAnimation;

  const Navbar({
    super.key,
    required this.onTap,
    this.activeIndex = 0,
    this.pageAnimation,
  });

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

          final Widget indicator = Container(
            decoration: BoxDecoration(
              color: navbarTheme.activeIconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(999.9),
            ),
          );

          final Widget positionedIndicator = pageAnimation != null
              ? AnimatedBuilder(
                  animation: pageAnimation!,
                  builder: (context, child) {
                    final double position = pageAnimation!.value;
                    return Positioned(
                      left: position * tabWidth + indicatorPadding,
                      top: indicatorPadding,
                      bottom: indicatorPadding,
                      width: tabWidth - indicatorPadding * 2,
                      child: child!,
                    );
                  },
                  child: indicator,
                )
              : AnimatedPositioned(
                  left: activeIndex * tabWidth + indicatorPadding,
                  top: indicatorPadding,
                  bottom: indicatorPadding,
                  width: tabWidth - indicatorPadding * 2,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  child: indicator,
                );

          return Stack(
            children: [
              positionedIndicator,
              // Tab buttons
              Row(
                children: [
                  NavbarButton(
                    index: 0,
                    label: "tabs.home".t(context),
                    icon: Symbols.home_rounded,
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
