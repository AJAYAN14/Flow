import "package:cross_file/cross_file.dart";
import "package:desktop_drop/desktop_drop.dart";
import "package:flow/data/flow_icon.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons_flow/symbols.dart";

class FileSelectArea extends StatefulWidget {
  final Function(XFile? file)? onFileDropped;
  final VoidCallback? onTap;

  const FileSelectArea({super.key, this.onFileDropped, this.onTap});

  @override
  State<FileSelectArea> createState() => _FileSelectAreaState();
}

class _FileSelectAreaState extends State<FileSelectArea> {
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    final bool showDropText = isDesktop();

    return DropTarget(
      onDragDone: (detail) {
        if (widget.onFileDropped != null) {
          widget.onFileDropped!(detail.files.firstOrNull);
        }
      },
      onDragEntered: (detail) => setState(() => _dragging = true),
      onDragExited: (detail) => setState(() => _dragging = false),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(24.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEFF6FF),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Symbols.cloud_upload_rounded,
                          fill: 1,
                          size: 40.0,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        showDropText
                            ? "sync.import.pickFile.pickOrDrop".t(context)
                            : "sync.import.pickFile".t(context),
                        style: context.textTheme.titleLarge!.semi(context).copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        "sync.import.pickFile.description".t(
                          context,
                          "ZIP, JSON, CSV",
                        ),
                        style: context.textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              ignoring: !_dragging,
              child: AnimatedOpacity(
                opacity: _dragging ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  color: context.colorScheme.primary,
                  child: Center(
                    child: Text(
                      "sync.import.pickFile.dropzone.active".t(context),
                      style: context.textTheme.headlineMedium?.copyWith(
                        color: context.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
