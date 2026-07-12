import "package:flow/data/money.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flutter/material.dart";

/// One node on either side of the cash flow.
class CashFlowDatum {
  final String label;
  final double value;
  final Color color;

  const CashFlowDatum({
    required this.label,
    required this.value,
    required this.color,
  });
}

/// A color-swatch + label + amount legend with a proportional progress bar.
class CashFlowLegend extends StatelessWidget {
  final List<CashFlowDatum> data;
  final String currency;
  final double totalValue;

  const CashFlowLegend({
    super.key,
    required this.data,
    required this.currency,
    required this.totalValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: data.map((datum) {
        final double fraction = totalValue > 0 ? (datum.value / totalValue).clamp(0.0, 1.0) : 0.0;
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 12.0,
                    height: 12.0,
                    decoration: BoxDecoration(
                      color: datum.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Text(
                      datum.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  MoneyText(
                    Money(datum.value, currency),
                    style: context.textTheme.bodyMedium?.semi(context),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              LinearProgressIndicator(
                value: fraction,
                backgroundColor: context.colorScheme.surfaceContainerHighest.withAlpha(0x80),
                color: datum.color,
                minHeight: 4.0,
                borderRadius: BorderRadius.circular(2.0),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
