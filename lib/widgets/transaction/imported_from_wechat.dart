import "package:flow/l10n/extensions.dart";
import "package:flow/theme/helpers.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons_flow/symbols.dart";

class ImportedFromWechat extends StatelessWidget {
  const ImportedFromWechat({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: context.textTheme.bodyMedium?.semi(context),
        children: [
          const WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: SizedBox.square(
              dimension: 16.0,
              child: Icon(
                Symbols.chat_bubble_rounded,
                size: 16.0,
                color: Color(0xFF07C160),
                fill: 1.0,
              ),
            ),
          ),
          const TextSpan(text: " "),
          TextSpan(text: "transaction.external.from".t(context, "WeChat")),
        ],
      ),
    );
  }
}

