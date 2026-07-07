import "package:flow/l10n/flow_localizations.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/modal_overflow_bar.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flow/widgets/general/premium_list_tile.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:moment_dart/moment_dart.dart";

enum TimeRangeMode {
  last30Days("last30Days"),
  thisWeek("thisWeek"),
  thisMonth("thisMonth"),
  thisYear("thisYear"),
  byMonth("byMonth"),
  byYear("byYear"),
  allTime("allTime"),
  custom("custom");

  final String value;

  const TimeRangeMode(this.value);

  String get translationKey => "select.timeRange.$value";

  /// Only returns one of [TimeRangeMode.thisWeek], [TimeRangeMode.thisMonth],
  /// [TimeRangeMode.thisYear], [TimeRangeMode.allTime] based on the [anchor]
  /// or now.
  static TimeRangeMode? tryInferPresetFromRange(
    TimeRange? range, {
    DateTime? anchor,
  }) {
    if (range == null) {
      return null;
    }

    final DateTime now = anchor ?? DateTime.now();

    if (range == LocalWeekTimeRange(now)) {
      return TimeRangeMode.thisWeek;
    } else if (range == MonthTimeRange.fromDateTime(now)) {
      return TimeRangeMode.thisMonth;
    } else if (range == YearTimeRange.fromDateTime(now)) {
      return TimeRangeMode.thisYear;
    } else if (range == Moment.minValue.rangeToMax()) {
      return TimeRangeMode.allTime;
    }

    return null;
  }
}

class SelectTimeRangeModeSheet extends StatelessWidget {
  final TimeRangeMode? initialValue;

  const SelectTimeRangeModeSheet({super.key, this.initialValue});

  @override
  Widget build(BuildContext context) {
    return ModalSheet.scrollable(
      title: Text("select.timeRange".t(context)),
      trailing: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
        child: FilledButton(
          onPressed: () => context.pop(null),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFF1F5F9), // Slate 100
            foregroundColor: const Color(0xFF475569), // Slate 600
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
          ),
          child: Text(
            "general.cancel".t(context),
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: .start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "select.timeRange.presets".t(context),
              style: context.textTheme.labelMedium?.copyWith(
                color: const Color(0xFF64748B), // Slate 500
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 12.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children:
                  [
                        TimeRangeMode.last30Days,
                        TimeRangeMode.thisWeek,
                        TimeRangeMode.thisMonth,
                        TimeRangeMode.thisYear,
                        TimeRangeMode.allTime,
                      ]
                      .map(
                        (mode) {
                          final isSelected = mode == initialValue;
                          return FilterChip(
                            label: Text(mode.translationKey.t(context)),
                            onSelected: (_) => context.pop(mode),
                            selected: isSelected,
                            showCheckmark: isSelected,
                            checkmarkColor: Colors.white,
                            backgroundColor: const Color(0xFFF1F5F9), // Slate 100
                            selectedColor: const Color(0xFF2563EB), // Blue 600
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            labelStyle: context.textTheme.labelLarge?.copyWith(
                              color: isSelected ? Colors.white : const Color(0xFF475569), // Slate 600
                              fontWeight: FontWeight.w600,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                          );
                        }
                      )
                      .toList(),
            ),
          ),
          const SizedBox(height: 24.0),
          PremiumListGroup(
            children: [
              PremiumListTile(
                title: Text("select.timeRange.mode.byMonth".t(context)),
                leading: Symbols.calendar_month_rounded,
                accent: const Color(0xFF2563EB), // Blue
                onTap: () => context.pop(TimeRangeMode.byMonth),
              ),
              const Divider(height: 1, indent: 56.0, endIndent: 16.0, color: Color(0xFFF1F5F9)),
              PremiumListTile(
                title: Text("select.timeRange.mode.byYear".t(context)),
                leading: Symbols.calendar_view_week_rounded,
                accent: const Color(0xFF8B5CF6), // Purple
                onTap: () => context.pop(TimeRangeMode.byYear),
              ),
              const Divider(height: 1, indent: 56.0, endIndent: 16.0, color: Color(0xFFF1F5F9)),
              PremiumListTile(
                title: Text("select.timeRange.mode.custom".t(context)),
                leading: Symbols.tune_rounded,
                accent: const Color(0xFF10B981), // Emerald
                onTap: () => context.pop(TimeRangeMode.custom),
              ),
            ],
          ),
          const SizedBox(height: 24.0),
        ],
      ),
    );
  }
}
