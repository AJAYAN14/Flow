import "package:flow/data/flow_icon.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/widgets/general/empty_state.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons_flow/symbols.dart";

class NoResult extends StatelessWidget {
  const NoResult({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: FlowIconData.icon(Symbols.receipt_long_rounded),
      title: Text("transactions.query.noResult".t(context)),
      subtitle: Text("transactions.query.noResult.description".t(context)),
    );
  }
}
