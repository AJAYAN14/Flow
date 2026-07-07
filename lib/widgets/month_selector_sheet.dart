import "package:flow/l10n/flow_localizations.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/button.dart";
import "package:flow/widgets/general/modal_overflow_bar.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flow/widgets/sheets/month_selector_sheet/month_button.dart";
import "package:flow/widgets/year_selector_bar.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

class MonthSelectorSheet extends StatefulWidget {
  final DateTime? initialDate;

  const MonthSelectorSheet({super.key, this.initialDate});

  @override
  State<MonthSelectorSheet> createState() => _MonthSelectorSheetState();
}

class _MonthSelectorSheetState extends State<MonthSelectorSheet> {
  late int year;
  late int month;

  @override
  void initState() {
    super.initState();

    final DateTime current = widget.initialDate ?? DateTime.now();
    year = current.year;
    month = current.month;
  }

  @override
  Widget build(BuildContext context) {
    return ModalSheet(
      title: Text("select.time.select.month".t(context)),
      trailing: Container(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
        child: Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: () => setState(() {
                  final DateTime now = DateTime.now();
                  year = now.year;
                  month = now.month;
                }),
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
                  "select.time.now".t(context),
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: pop,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB), // Royal Blue
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
                child: Text(
                  "general.done".t(context),
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          YearSelectorBar(year: year, onUpdate: updateYear),
          const SizedBox(height: 16.0),
          MonthsGrid(
            onTap: updateMonth,
            currentMonth: month,
            currentYear: year,
          ),
        ],
      ),
    );
  }

  void updateYear(int newYear) {
    setState(() {
      year = newYear;
    });
  }

  void updateMonth(int newMonth) {
    assert(month >= 1 && month <= 12);

    setState(() {
      month = newMonth;
    });
  }

  void pop() {
    context.pop(DateTime(year, month));
  }
}

class MonthsGrid extends StatelessWidget {
  final int currentYear;
  final int currentMonth;
  final Function(int) onTap;

  const MonthsGrid({
    super.key,
    required this.onTap,
    required this.currentYear,
    required this.currentMonth,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in [1, 4, 7, 10]) ...[
          if (row != 1) const SizedBox(height: 12.0),
          Row(
            children: [
              for (int i = row; i < row + 3; i++) ...[
                if (i != row) const SizedBox(width: 12.0),
                Expanded(
                  child: MonthButton(
                    currentDate: DateTime(currentYear, currentMonth),
                    month: DateTime(currentYear, i),
                    onTap: () => onTap(i),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}
