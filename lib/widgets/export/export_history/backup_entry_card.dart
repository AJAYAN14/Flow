import "dart:async";
import "dart:io";

import "package:flow/entity/backup_entry.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/general/directional_slidable.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flutter/material.dart";
import "package:flutter_slidable/flutter_slidable.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:moment_dart/moment_dart.dart";

class BackupEntryCard extends StatefulWidget {
  final BackupEntry entry;

  final BorderRadius borderRadius;
  final EdgeInsets padding;

  final Key? dismissibleKey;

  final Function()? onUpload;

  final double? uploadProgress;

  const BackupEntryCard({
    super.key,
    required this.entry,
    this.borderRadius = const .all(Radius.circular(16.0)),
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
    this.dismissibleKey,
    this.onUpload,
    this.uploadProgress,
  });

  @override
  State<BackupEntryCard> createState() => _BackupEntryCardState();
}

class _BackupEntryCardState extends State<BackupEntryCard> {
  bool _busyDownloading = false;

  double _downloadProgress = 0.0;

  @override
  Widget build(BuildContext context) {
    final int? fileSize = getFileSize();

    final Widget listTile = InkWell(
      borderRadius: widget.borderRadius,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: widget.padding,
            child: Row(
              children: [
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: FlowIcon(
                        widget.entry.icon,
                        size: 48.0,
                        plated: true,
                      ),
                    ),

                  ],
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: .start,
                    children: [
                      Text(
                        widget.entry.backupEntryType.localizedNameContext(
                          context,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.labelLarge,
                      ),
                      Text(
                        [
                          widget.entry.createdDate.toMoment().calendar(),
                          widget.entry.fileExt,
                          fileSize?.humanReadableBinarySize,
                        ].nonNulls.join(" • "),
                        style: context.textTheme.bodyMedium?.semi(context),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8.0),
                Builder(
                  builder: (context) {
                    if (_busyDownloading) {
                      return CircularProgressIndicator(
                        value: _downloadProgress,
                      );
                    }

                    return IconButton(
                      onPressed: _busyDownloading ? null : onDownload,
                      icon: (fileSize != null)
                          ? const Icon(Symbols.save_alt_rounded)
                          : Icon(
                              Symbols.error_circle_rounded,
                              color: context.flowColors.expense,
                            ),
                    );
                  },
                ),
                const SizedBox(width: 8.0),
              ],
            ),
          ),
          if (widget.uploadProgress != null)
            LinearProgressIndicator(
              value: widget.uploadProgress,
              minHeight: 4.0,
              color: context.flowColors.income,
              backgroundColor: context.colorScheme.surface.withAlpha(0xC0),
            ),
        ],
      ),
    );

    final List<SlidableAction> startActions = [];

    final List<SlidableAction> endActions = [
      SlidableAction(
        onPressed: (context) => delete(context),
        icon: Symbols.delete_forever_rounded,
        backgroundColor: context.flowColors.expense,
      ),
    ];

    return DirectionalSlidable(
      key: widget.dismissibleKey,
      groupTag: "backup_entry_card",
      startActions: startActions,
      endActions: endActions,
      child: listTile,
    );
  }

  Future<void> delete(BuildContext context) async {
    final String title = widget.entry.backupEntryType.localizedNameContext(
      context,
    );

    final confirmation = getFileSize() == null
        ? true
        : await context.showConfirmationSheet(
            isDeletionConfirmation: true,
            title: "general.delete.confirmName".t(context, title),
            child: Text(
              "general.delete.permanentWarning".t(context),
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.flowColors.expense,
              ),
              textAlign: TextAlign.center,
            ),
          );

    if (confirmation == true) {
      unawaited(
        widget.entry.delete().then((deleted) {
          if (context.mounted && !deleted) {
            context.showErrorToast(
              error: "error.sync.fileDeleteFailed".t(context),
            );
          }
        }),
      );
    }
  }

  Future<void> onDownload() async {
    String? fileToShare = widget.entry.filePath;

    if (!mounted) return;

    if (fileToShare != null) {
      await context.showFileShareSheet(
        subject: "sync.export.save.shareTitle".t(context, {
          "type": widget.entry.fileExt,
          "date": widget.entry.createdDate.toMoment().lll,
        }),
        filePath: fileToShare,
      );
    } else {
      context.showErrorToast(error: "error.sync.fileNotFound".t(context));
    }
  }

  int? getFileSize() {
    return widget.entry.getFileSizeSync();
  }
}
