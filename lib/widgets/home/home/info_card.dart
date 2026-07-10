import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flutter/cupertino.dart";

class InfoCard extends StatelessWidget {
  final String title;

  final Widget? money;
  final Widget? delta;

  final Widget? icon;
  final Color? color;

  const InfoCard({
    super.key,
    required this.title,
    this.icon,
    this.money,
    this.delta,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Surface(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: .circular(16.0)),
      builder: (BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: .start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  IconTheme(data: const IconThemeData(size: 20.0), child: icon!),
                  const SizedBox(width: 8.0),
                ],
                Flexible(
                  child: Text(
                    title,
                    style: context.textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            ?money,
            ?delta,
          ],
        ),
      ),
    );
  }
}
