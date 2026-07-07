import "package:flow/l10n/flow_localizations.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/button.dart";
import "package:flow/widgets/general/modal_overflow_bar.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:go_router/go_router.dart";

class YearSelectorSheet extends StatefulWidget {
  final DateTime? initialDate;

  const YearSelectorSheet({super.key, this.initialDate});

  @override
  State<YearSelectorSheet> createState() => _YearSelectorSheetState();
}

class _YearSelectorSheetState extends State<YearSelectorSheet> {
  late final TextEditingController _yearController;

  @override
  void initState() {
    super.initState();

    final DateTime current = widget.initialDate ?? DateTime.now();

    _yearController = TextEditingController(text: current.year.toString());
  }

  @override
  void dispose() {
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModalSheet(
      title: Text("select.time.select.year".t(context)),
      trailing: Container(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
        child: Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: () => setState(() {
                  final DateTime now = DateTime.now();
                  _yearController.text = now.year.toString();
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
          TextField(
            controller: _yearController,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.number,
            autofocus: true,
            textAlign: TextAlign.center,
            style: context.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B), // Slate 800
              letterSpacing: 1.0,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12.0),
            ),
            onSubmitted: (_) => pop(),
          ),
        ],
      ),
    );
  }

  void pop() {
    final int? year = int.tryParse(_yearController.text);

    if (year == null || year <= 0 || year > 3000) {
      context.pop(null);
    } else {
      context.pop(DateTime(year));
    }
  }
}
