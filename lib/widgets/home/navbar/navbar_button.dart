import "package:flow/prefs/local_preferences.dart";
import "package:flow/theme/navbar_theme.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:material_symbols_icons_flow/symbols.dart";

class NavbarButton extends StatefulWidget {
  final String label;
  final IconData icon;

  final int index;
  final int activeIndex;

  final Function(int) onTap;

  const NavbarButton({
    super.key,
    required this.label,
    required this.icon,
    required this.index,
    required this.activeIndex,
    required this.onTap,
  });

  @override
  State<NavbarButton> createState() => _NavbarButtonState();
}

class _NavbarButtonState extends State<NavbarButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool get isActive => widget.index == widget.activeIndex;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.1).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.1, end: 1.0).chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 50,
      ),
    ]).animate(_pulseController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _pulseController.forward(from: 0.0);
    if (LocalPreferences().enableHapticFeedback.get()) {
      HapticFeedback.lightImpact();
    }
    widget.onTap(widget.index);
  }

  @override
  Widget build(BuildContext context) {
    final NavbarTheme navbarTheme =
        Theme.of(context).extension<NavbarTheme>()!;

    final Color activeColor = navbarTheme.activeIconColor;
    const Color inactiveIconColor = Colors.black;
    const Color inactiveTextColor = Colors.black;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleTap,
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: child,
            );
          },
          child: SizedBox.expand(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TweenAnimationBuilder<Color?>(
                    tween: ColorTween(
                      end: isActive ? activeColor : inactiveIconColor,
                    ),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    builder: (context, color, _) {
                      return Icon(
                        widget.icon,
                        color: color,
                        size: 22.0,
                        fill: (isActive &&
                                widget.icon != Symbols.circle_rounded)
                            ? 1.0
                            : 0.0,
                        weight: isActive ? 700.0 : 500.0,
                      );
                    },
                  ),
                  const SizedBox(height: 2.0),
                  TweenAnimationBuilder<Color?>(
                    tween: ColorTween(
                      end: isActive ? activeColor : inactiveTextColor,
                    ),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    builder: (context, color, _) {
                      return Text(
                        widget.label,
                        style: TextStyle(
                          fontSize: 11.0,
                          fontWeight:
                              isActive ? FontWeight.w700 : FontWeight.w500,
                          color: color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
