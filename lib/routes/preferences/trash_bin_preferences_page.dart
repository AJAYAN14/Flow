import "dart:developer";

import "package:flow/l10n/extensions.dart";
import "package:flow/services/transactions.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/utils/extensions.dart";
import "package:flow/widgets/general/list_header.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:moment_dart/moment_dart.dart";

class TrashBinPreferencesPage extends StatefulWidget {
  const TrashBinPreferencesPage({super.key});

  @override
  State<TrashBinPreferencesPage> createState() =>
      _TrashBinPreferencesPageState();

  static const List<Duration> choices = [
    Duration(days: 7),
    Duration(days: 14),
    Duration(days: 30),
    Duration(days: 90),
    Duration(days: 180),
    Duration(days: 365),
  ];
}

class _TrashBinPreferencesPageState extends State<TrashBinPreferencesPage> {
  bool busy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(
        title: Text("preferences.trashBin".t(context)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ValueListenableBuilder(
        valueListenable: UserPreferencesService().valueNotifier,
        builder: (context, snapshot, _) {
          final int? trashBinRetentionDays = snapshot.trashBinRetentionDays;

          final bool isCustomPeriod =
              trashBinRetentionDays != null &&
              !TrashBinPreferencesPage.choices.any(
                (preset) => trashBinRetentionDays == preset.inDays,
              );

          final List<Duration> choices = [
            ...TrashBinPreferencesPage.choices,
            if (isCustomPeriod) Duration(days: trashBinRetentionDays),
          ]..sort((a, b) => a.inDays.compareTo(b.inDays));

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8.0),
                  ListHeader("preferences.trashBin.retention".t(context)),
                  const SizedBox(height: 8.0),
                  
                  // Card for Retention Options
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: context.colorScheme.surfaceContainerHighest.withAlpha(0x4D),
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(
                        color: context.colorScheme.outlineVariant.withAlpha(0x4D),
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      children: [
                        ...choices.map((value) {
                          final bool isSelected = value.inDays == trashBinRetentionDays;
                          return _buildOptionTile(
                            context: context,
                            title: value.toDurationString(
                              format: DurationFormat([DurationUnit.day]),
                              dropPrefixOrSuffix: true,
                            ),
                            isSelected: isSelected,
                            onTap: () => updateTrashBinRetentionDays(value.inDays),
                            isFirst: value == choices.first,
                            isLast: false,
                          );
                        }),
                        _buildOptionTile(
                          context: context,
                          title: "preferences.trashBin.retention.forever".t(context),
                          isSelected: trashBinRetentionDays == null,
                          onTap: () => updateTrashBinRetentionDays(null),
                          isFirst: false,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32.0),
                  ListHeader("preferences.trashBin.seeItems".t(context).replaceAll("查看", "操作").replaceAll("See items", "Actions")), // Dynamic header text fallback
                  const SizedBox(height: 8.0),

                  // Card for Actions
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: context.colorScheme.surfaceContainerHighest.withAlpha(0x4D),
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(
                        color: context.colorScheme.outlineVariant.withAlpha(0x4D),
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                          leading: Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withAlpha(0x26),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Symbols.history_rounded, color: Color(0xFF6366F1), size: 22.0),
                          ),
                          title: Text(
                            "preferences.trashBin.seeItems".t(context),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          trailing: Icon(Symbols.chevron_right_rounded, color: context.colorScheme.onSurfaceVariant),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                          ),
                          onTap: () => context.push("/transactions/deleted"),
                        ),
                        Divider(height: 1.0, indent: 64.0, color: context.colorScheme.outlineVariant.withAlpha(0x4D)),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                          leading: Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withAlpha(0x26),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Symbols.delete_sweep_rounded, color: Color(0xFFEF4444), size: 22.0),
                          ),
                          title: Text(
                            "preferences.trashBin.emptyBin".t(context),
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFEF4444),
                            ),
                          ),
                          enabled: !busy,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.0)),
                          ),
                          onTap: emptyTrashBin,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32.0),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isFirst,
    required bool isLast,
  }) {
    final Color activeColor = context.colorScheme.primary;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 0.0),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? activeColor : context.colorScheme.onSurface,
            ),
          ),
          trailing: isSelected
              ? Icon(Symbols.check_rounded, color: activeColor)
              : const SizedBox(width: 24, height: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(isFirst ? 20.0 : 0.0),
              bottom: Radius.circular(isLast ? 20.0 : 0.0),
            ),
          ),
          onTap: onTap,
        ),
        if (!isLast)
          Divider(height: 1.0, indent: 24.0, endIndent: 24.0, color: context.colorScheme.outlineVariant.withAlpha(0x4D)),
      ],
    );
  }

  void updateTrashBinRetentionDays(int? days) async {
    UserPreferencesService().trashBinRetentionDays = days;
  }

  void emptyTrashBin() async {
    if (busy) return;

    final bool? confirmation = await context.showConfirmationSheet(
      isDeletionConfirmation: true,
      title: "preferences.trashBin.emptyBin".t(context),
      child: Text("preferences.trashBin.emptyBin.description".t(context)),
    );

    if (confirmation != true) return;

    setState(() {
      busy = true;
    });

    try {
      await TransactionsService().emptyTrashBin();
    } catch (error) {
      log("Failed to empty trash bin", error: error);
    } finally {
      busy = false;

      if (mounted) {
        setState(() {});
      }
    }
  }
}
