import "dart:math";

import "package:flow/data/flow_button_type.dart";
import "package:flow/entity/user_preferences.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/prefs/local_preferences.dart";

import "package:flow/services/user_preferences.dart";

import "package:flow/theme/theme.dart";
import "package:flow/utils/extensions/directionality.dart";
import "package:flutter/material.dart" hide Flow;
import "package:flutter/services.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:pie_menu/pie_menu.dart";

class NewTransactionButton extends StatefulWidget {
  final Function(FlowButtonType type) onActionTap;

  const NewTransactionButton({super.key, required this.onActionTap});

  @override
  State<NewTransactionButton> createState() => _NewTransactionButtonState();
}

class _NewTransactionButtonState extends State<NewTransactionButton>
    with SingleTickerProviderStateMixin {
  DateTime? _lastHoverTime;

  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
    reverseDuration: const Duration(milliseconds: 200),
  );
  late final _bounceAnimation = Tween(begin: 0.0, end: (45.0 / 180) * pi)
      .animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeInBack,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: UserPreferencesService().valueNotifier,
      builder: (context, _) {
        final UserPreferences userPreferences = UserPreferencesService().value;

        final List<FlowButtonType> buttonOrder = context.isLtr
            ? userPreferences.transactionButtonOrder
            : userPreferences.transactionButtonOrder.reversed.toList();

        return PieMenu(
          theme: context.pieTheme.copyWith(
            customAngle: 135.0,
            customAngleDiff: 40.0,
            radius: 108.0,
            customAngleAnchor: PieAnchor.center,
            leftClickShowsMenu: true,
            rightClickShowsMenu: true,
            regularPressShowsMenu: true,
            childBounceEnabled: false,
            pieBounceDuration: .zero,
            longPressDuration: .zero,
            longPressShowsMenu: true,
          ),
          onToggle: onToggle,
          actions: buttonOrder
              .map(
                (transactionType) => PieAction.builder(
                  tooltip: Text(transactionType.localizedNameContext(context)),
                  onSelect: () {
                    if (LocalPreferences().enableHapticFeedback.get()) {
                      if (_lastHoverTime == null ||
                          DateTime.now().difference(_lastHoverTime!) >
                              const Duration(milliseconds: 150)) {
                        HapticFeedback.mediumImpact();
                      }
                    }
                    widget.onActionTap(transactionType);
                  },
                  builder: (hovered) => _HoverHapticFeedback(
                    hovered: hovered,
                    onHoverVibrated: () {
                      _lastHoverTime = DateTime.now();
                    },
                    child: Icon(transactionType.icon, weight: 800.0),
                  ),
                  buttonTheme: PieButtonTheme(
                    backgroundColor: transactionType.actionBackgroundColor(
                      context,
                    ),
                    iconColor: transactionType.actionColor(context),
                  ),
                ),
              )
              .toList(),
          child: Container(
            width: 60.0,
            height: 60.0,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF0A84FF), Color(0xFF0056b3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x660A84FF),
                  blurRadius: 24.0,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: AnimatedBuilder(
                animation: _bounceAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _bounceAnimation.value,
                    child: child,
                  );
                },
                child: const Icon(
                  Symbols.add_rounded,
                  fill: 0.0,
                  color: Colors.white,
                  weight: 600.0,
                  size: 32.0,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void onToggle(bool toggled) {
    if (toggled) {
      if (LocalPreferences().enableHapticFeedback.get()) {
        HapticFeedback.lightImpact();
      }
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }
}

class _HoverHapticFeedback extends StatefulWidget {
  final bool hovered;
  final VoidCallback onHoverVibrated;
  final Widget child;

  const _HoverHapticFeedback({
    required this.hovered,
    required this.onHoverVibrated,
    required this.child,
  });

  @override
  State<_HoverHapticFeedback> createState() => _HoverHapticFeedbackState();
}

class _HoverHapticFeedbackState extends State<_HoverHapticFeedback> {
  @override
  void didUpdateWidget(covariant _HoverHapticFeedback oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hovered && !oldWidget.hovered) {
      if (LocalPreferences().enableHapticFeedback.get()) {
        HapticFeedback.selectionClick();
        widget.onHoverVibrated();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
