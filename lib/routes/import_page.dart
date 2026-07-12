import "dart:async";
import "dart:io";

import "package:cross_file/cross_file.dart";
import "package:flow/constants.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/sync/import.dart";
import "package:flow/sync/import/base.dart";
import "package:flow/sync/model/external/alipay/alipay_csv_parser.dart";
import "package:flow/sync/model/external/wechat/wechat_csv_parser.dart";
import "package:flow/utils/extensions/importer.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/action_card.dart";
import "package:flow/widgets/general/list_header.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/import/file_select_area.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:logging/logging.dart";
import "package:simple_icons_flow/simple_icons_flow.dart";

final Logger _log = Logger("ImportPage");

class ImportPage extends StatefulWidget {
  final bool? setupMode;

  const ImportPage({this.setupMode = false, super.key});

  @override
  State<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  Importer? importer;

  bool busy = false;

  dynamic error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("sync.import".t(context))),
      body: SafeArea(
        child: busy
            ? const Spinner.center()
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    FileSelectArea(
                      onFileDropped: initiateImportFromDroppedFile,
                      onTap: initiateImport,
                    ),
                    const SizedBox(height: 16.0),
                    ListHeader("sync.import.other".t(context)),
                    const SizedBox(height: 8.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          ActionCard(
                            customIcon: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: ClipRRect(
                                borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                                child: Image.asset(
                                  "assets/images/external/ivy_wallet.png",
                                  width: 24.0,
                                  height: 24.0,
                                ),
                              ),
                            ),
                            title: "Ivy Wallet (CSV)",
                            onTap: () => initiateImport(
                              externalFormat: ImportExternalFormat.ivyWallet,
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          ActionCard(
                            customIcon: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Icon(
                                SimpleIcons.wechat,
                                size: 24.0,
                                color: const Color(0xFF07C160),
                              ),
                            ),
                            title: "微信支付 (CSV)",
                            onTap: initiateWechatImport,
                          ),
                          const SizedBox(height: 12.0),
                          ActionCard(
                            customIcon: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Icon(
                                SimpleIcons.alipay,
                                size: 24.0,
                                color: const Color(0xFF1677FF),
                              ),
                            ),
                            title: "支付宝 (CSV)",
                            onTap: initiateAlipayImport,
                          ),
                          const SizedBox(height: 12.0),
                          ActionCard(
                            customIcon: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Icon(
                                SimpleIcons.googlesheets,
                                size: 24.0,
                                color: const Color(0xFF2563EB),
                              ),
                            ),
                            title: "sync.import.getCSVTemplate".t(context),
                            onTap: () => openUrl(csvImportTemplateUrl),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> initiateImport({
    File? backupFile,
    ImportExternalFormat? externalFormat,
  }) async {
    if (busy) return;

    setState(() {
      busy = true;
    });

    try {
      importer = await importBackup(
        backupFile: backupFile,
        externalFormat: externalFormat,
      );

      if (mounted) {
        if (importer == null) {
          context.showErrorToast(error: "error.input.noFilePicked".t(context));
        } else {
          importer!.goToRelevantPage(
            context,
            setupMode: widget.setupMode ?? false,
          );
        }
      }
    } catch (e, stackTrace) {
      _log.severe("Importer error", e, stackTrace);
      if (mounted) {
        context.showErrorToast(error: e);
      }
    } finally {
      busy = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> initiateWechatImport() async {
    if (busy) return;

    setState(() {
      busy = true;
    });

    try {
      final file = await pickImportFile();
      if (file == null) {
        if (mounted) context.showErrorToast(error: "error.input.noFilePicked".t(context));
        return;
      }
      
      final multiParams = await WechatCsvParser.parse(file);
      if (mounted) {
        unawaited(context.push("/transaction/batch-import", extra: multiParams));
      }
    } catch (e, stackTrace) {
      _log.severe("Wechat import error", e, stackTrace);
      if (mounted) {
        context.showErrorToast(error: e);
      }
    } finally {
      busy = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> initiateAlipayImport() async {
    if (busy) return;

    setState(() {
      busy = true;
    });

    try {
      final file = await pickImportFile();
      if (file == null) {
        if (mounted) context.showErrorToast(error: "error.input.noFilePicked".t(context));
        return;
      }
      
      final multiParams = await AlipayCsvParser.parse(file);
      if (mounted) {
        unawaited(context.push("/transaction/batch-import", extra: multiParams));
      }
    } catch (e, stackTrace) {
      _log.severe("Alipay import error", e, stackTrace);
      if (mounted) {
        context.showErrorToast(error: e);
      }
    } finally {
      busy = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> initiateImportFromDroppedFile(XFile? file) async {
    if (file == null) {
      context.showErrorToast(error: "error.input.noFilePicked".t(context));
      return;
    }

    _log.fine("Trying to import from dragged file: ${file.path}");

    final backupFile = File(file.path);

    if (!(await backupFile.exists())) {
      if (mounted) {
        context.showErrorToast(error: "error.input.noFilePicked".t(context));
      }
      return;
    }

    return initiateImport(backupFile: backupFile);
  }
}
