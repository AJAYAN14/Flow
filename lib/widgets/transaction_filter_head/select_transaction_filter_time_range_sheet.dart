import "package:flow/data/transactions_filter/time_range.dart";
import "package:flow/widgets/sheets/select_time_range_mode_sheet.dart";
import "package:flow/utils/time_and_range.dart";
import "package:flutter/material.dart";
import "package:moment_dart/moment_dart.dart";

final Map<TransactionFilterTimeRange, TimeRangeMode> filterRangeToModeMapping =
    {
      TransactionFilterTimeRange.last30Days: TimeRangeMode.last30Days,
      TransactionFilterTimeRange.thisWeek: TimeRangeMode.thisWeek,
      TransactionFilterTimeRange.thisMonth: TimeRangeMode.thisMonth,
      TransactionFilterTimeRange.thisYear: TimeRangeMode.thisYear,
      TransactionFilterTimeRange.allTime: TimeRangeMode.allTime,
    };

Future<TransactionFilterTimeRange?> showTransactionFilterTimeRangeSelectorSheet(
  BuildContext context, {
  TransactionFilterTimeRange? initialValue,
}) async {
  final TimeRangeMode? mode = await showModalBottomSheet<TimeRangeMode>(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) => SelectTimeRangeModeSheet(
      initialValue: initialValue != null
          ? filterRangeToModeMapping[initialValue]
          : null,
    ),
  );

  if (mode == null) return null;
  if (!context.mounted) return null;

  return switch (mode) {
    TimeRangeMode.last30Days => TransactionFilterTimeRange.last30Days,
    TimeRangeMode.thisWeek => TransactionFilterTimeRange.thisWeek,
    TimeRangeMode.thisMonth => TransactionFilterTimeRange.thisMonth,
    TimeRangeMode.thisYear => TransactionFilterTimeRange.thisYear,
    TimeRangeMode.allTime => TransactionFilterTimeRange.allTime,
    TimeRangeMode.byYear when context.mounted =>
      await showYearPickerSheet(
        context,
        initialDate: initialValue?.range?.from,
      ).then(
        (value) => value == null
            ? null
            : TransactionFilterTimeRange.fromTimeRange(
                YearTimeRange.fromDateTime(value),
              ),
      ),
    TimeRangeMode.byMonth when context.mounted =>
      await showMonthPickerSheet(
        context,
        initialDate: initialValue?.range?.from,
      ).then(
        (value) => value == null
            ? null
            : TransactionFilterTimeRange.fromTimeRange(
                MonthTimeRange.fromDateTime(value),
              ),
      ),
    TimeRangeMode.custom when context.mounted =>
      await showDateRangePicker(
        context: context,
        firstDate: DateTime.fromMicrosecondsSinceEpoch(0),
        lastDate: DateTime(4000),
        initialDateRange: initialValue?.range is CustomTimeRange
            ? DateTimeRange(
                start: initialValue!.range!.from,
                end: initialValue.range!.to,
              )
            : null,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: const Color(0xFF2563EB), // Royal Blue
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: const Color(0xFF1E293B), // Slate 800
                  ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white,
                foregroundColor: Color(0xFF1E293B), // Slate 800
                elevation: 0,
              ),
              datePickerTheme: DatePickerThemeData(
                backgroundColor: Colors.white,
                headerBackgroundColor: Colors.white,
                headerForegroundColor: const Color(0xFF1E293B), // Slate 800
                rangeSelectionOverlayColor: MaterialStateProperty.all(
                  const Color(0xFFDBEAFE), // Blue 100 (Brighter and more vibrant)
                ),
                rangeSelectionBackgroundColor: const Color(0xFFDBEAFE), // Blue 100
                todayForegroundColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) return Colors.white;
                  return const Color(0xFF2563EB); // Royal Blue for today's text
                }),
                dayStyle: const TextStyle(fontWeight: FontWeight.w600),
                yearStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF2563EB), // Royal Blue
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
            child: child!,
          );
        },
      ).then(
        (value) => value == null
            ? null
            : TransactionFilterTimeRange.fromTimeRange(
                CustomTimeRange(value.start.startOfDay(), value.end.endOfDay()),
              ),
      ),
    _ => null, // context.mounted == true
  };
}
