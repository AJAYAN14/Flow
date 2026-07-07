import "package:flow/l10n/flow_localizations.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons_flow/symbols.dart";

class AccountCardSkeleton extends StatelessWidget {
  final VoidCallback? onTap;
  final BorderRadius borderRadius;

  const AccountCardSkeleton({
    super.key,
    this.onTap,
    this.borderRadius = const .all(Radius.circular(24.0)),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF), // Blue 50
        borderRadius: borderRadius,
        border: Border.all(
          color: const Color(0xFFBFDBFE), // Blue 200
          width: 2.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: SizedBox(
            height: 179.0,
            width: double.infinity,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "account.new".t(context),
                    style: context.textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF2563EB), // Blue 600
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  const Icon(
                    Symbols.add_rounded,
                    size: 40.0,
                    weight: 700.0,
                    opticalSize: 40.0,
                    color: Color(0xFF2563EB), // Blue 600
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
