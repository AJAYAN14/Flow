import "package:flow/data/flow_icon.dart";
import "package:flow/data/transaction_multi_programmable_object.dart";
import "package:flow/data/transaction_programmable_object.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/providers/accounts_provider.dart";
import "package:flow/routes/transaction_page/section.dart";
import "package:flow/widgets/sheets/select_account_sheet.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/general/button.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/form_close_button.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/info_text.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/scaffold_actions.dart";
import "package:flow/widgets/transaction_batch_import_page/tpo_preview_list_item.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons_flow/symbols.dart";

class TransactionBatchImportPage extends StatefulWidget {
  final TransactionMultiProgrammableObject? params;

  const TransactionBatchImportPage({super.key, required this.params});

  @override
  State<TransactionBatchImportPage> createState() =>
      _TransactionBatchImportPageState();
}

class _TransactionBatchImportPageState
    extends State<TransactionBatchImportPage> {
  // final List<String> _assignedAccountUuids = [];
  String? _fromAccountUuid;
  String? _toAccountUuid;

  bool assignIndividually = false;

  bool _hideWechatBankCardTransactions = true;

  bool _busy = false;

  @override
  void initState() {
    super.initState();
    try {
      _fromAccountUuid = UserPreferencesService().primaryAccountUuid;
    } catch (e) {
      //
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Account> accounts = AccountsProvider.of(context).activeAccounts;

    final Account? selectedFromAccount = _fromAccountUuid == null
        ? null
        : accounts.firstWhereOrNull(
            (account) => account.uuid == _fromAccountUuid,
          );

    final Account? selectedToAccount = _toAccountUuid == null
        ? null
        : accounts.firstWhereOrNull(
            (account) => account.uuid == _toAccountUuid,
          );

    final bool hasAnyTransfer =
        widget.params?.t.any((x) => x.type == .transfer) == true;

    return GestureDetector(
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): () => (),
          osSingleActivator(LogicalKeyboardKey.enter): () => (),
          osSingleActivator(LogicalKeyboardKey.numpadEnter): () => (),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            appBar: AppBar(
              leading: FormCloseButton(canPop: () => false),
              titleTextStyle: context.textTheme.bodyLarge,
              title: Text("transactions.batch.import".t(context)),
              centerTitle: true,
              backgroundColor: context.colorScheme.surface,
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Frame(
                    child: InfoText(
                      child: Text("transactions.batch.review".t(context)),
                    ),
                  ),
                  if (widget.params?.t.any((tpo) => tpo.extraTags?.contains(Transaction.importedFromWechatBankCardTag) == true) == true)
                    SwitchListTile(
                      title: Text("隐藏非零钱支付（银行卡等）的交易"),
                      subtitle: Text("开启后将只导入零钱或零钱通支付的交易，避免与银行卡账单重复"),
                      value: _hideWechatBankCardTransactions,
                      onChanged: (val) {
                        setState(() {
                          _hideWechatBankCardTransactions = val;
                        });
                      },
                    ),
                  const SizedBox(height: 8.0),
                  if (widget.params != null) ...[
                    Builder(
                      builder: (context) {
                        final filteredTpos = widget.params!.t.where((tpo) {
                          if (_hideWechatBankCardTransactions &&
                              tpo.extraTags?.contains(Transaction.importedFromWechatBankCardTag) == true) {
                            return false;
                          }
                          return true;
                        }).toList();

                        return Expanded(
                          child: ListView.builder(
                            itemCount: filteredTpos.length,
                            itemBuilder: (context, index) =>
                                TpoPreviewListItem(tpo: filteredTpos[index]),
                          ),
                        );
                      },
                    ),
                  ]
                ],
              ),
            ),
            bottomNavigationBar: ScaffoldActions(
              children: [
                // Frame(
                //   child: Align(
                //     alignment: AlignmentDirectional.topEnd,
                //     child: TextButton(
                //       onPressed: () => setState(
                //         () => assignIndividually = !assignIndividually,
                //       ),
                //       child: Text(
                //         assignIndividually
                //             ? "transactions.batch.assignAccountForAll".t(
                //                 context,
                //               )
                //             : "transactions.batch.assignAccountIndividually".t(
                //                 context,
                //               ),
                //       ),
                //     ),
                //   ),
                // ),
                if (!assignIndividually) ...[
                  Section(
                    title: "account".t(context),
                    child: ListTile(
                      leading: selectedFromAccount == null
                          ? null
                          : FlowIcon(selectedFromAccount.icon, plated: true),
                      title: Text(
                        selectedFromAccount?.name ??
                            "transaction.edit.selectAccount".t(context),
                      ),
                      subtitle: selectedFromAccount == null
                          ? null
                          : MoneyText(selectedFromAccount.balance),
                      onTap: () => selectFromAccount(),
                      trailing: const Icon(Symbols.chevron_right),
                    ),
                  ),
                  if (hasAnyTransfer)
                    Section(
                      title: "transaction.transfer.to".t(context),
                      child: ListTile(
                        leading: selectedToAccount == null
                            ? null
                            : FlowIcon(selectedToAccount.icon, plated: true),
                        title: Text(
                          selectedToAccount?.name ??
                              "transaction.edit.selectAccount".t(context),
                        ),
                        subtitle: selectedToAccount == null
                            ? null
                            : MoneyText(selectedToAccount.balance),
                        onTap: () => selectToAccount(),
                        trailing: const Icon(Symbols.chevron_right),
                      ),
                    ),
                ],

                Button(
                  onTap: (_busy || (hasAnyTransfer && _toAccountUuid == null))
                      ? null
                      : importTransactions,
                  leading: FlowIcon(
                    FlowIconData.icon(Symbols.download_rounded),
                  ),
                  child: Builder(
                    builder: (context) {
                      final filteredCount = widget.params?.t.where((tpo) {
                        if (_hideWechatBankCardTransactions &&
                            tpo.extraTags?.contains(Transaction.importedFromWechatBankCardTag) == true) {
                          return false;
                        }
                        return true;
                      }).length ?? 0;

                      return Text(
                        "transactions.batch.importN".t(
                          context,
                          filteredCount,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void selectFromAccount() async {
    final accounts = AccountsProvider.of(context).activeAccounts;

    final selectedAccountId = accounts
        .firstWhereOrNull((account) => account.uuid == _fromAccountUuid)
        ?.id;

    final Account? account =
        accounts.singleOrNull ??
        await showModalBottomSheet<Account>(
          context: context,
          builder: (context) => SelectAccountSheet(
            accounts: accounts,
            currentlySelectedAccountId: selectedAccountId,
            showBalance: true,
            showTrailing: false,
          ),
          isScrollControlled: true,
        );

    if (account == null) return;

    _fromAccountUuid = account.uuid;
    if (_toAccountUuid == _fromAccountUuid) {
      _toAccountUuid = null;
    }

    if (!mounted) return;

    setState(() {});
  }

  void selectToAccount() async {
    final accounts = AccountsProvider.of(context).activeAccounts
        .where((account) => account.uuid != _fromAccountUuid)
        .toList();

    final selectedAccountId = accounts
        .firstWhereOrNull((account) => account.uuid == _toAccountUuid)
        ?.id;

    final Account? account =
        accounts.singleOrNull ??
        await showModalBottomSheet<Account>(
          context: context,
          builder: (context) => SelectAccountSheet(
            accounts: accounts,
            currentlySelectedAccountId: selectedAccountId,
            showBalance: true,
            showTrailing: false,
          ),
          isScrollControlled: true,
        );

    if (account == null) return;

    _toAccountUuid = account.uuid;

    if (!mounted) return;

    setState(() {});
  }

  Future<void> importTransactions() async {
    if (_busy) return;

    setState(() {
      _busy = true;
    });

    final List<TransactionProgrammableObject> tpos =
        widget.params?.t.where((tpo) {
      if (_hideWechatBankCardTransactions &&
          tpo.extraTags?.contains(Transaction.importedFromWechatBankCardTag) == true) {
        return false;
      }
      return true;
    }).toList() ?? <TransactionProgrammableObject>[];

    try {
      for (final TransactionProgrammableObject tpo in tpos) {
        tpo.save(
          fromAccountOverride: _fromAccountUuid,
          toAccountOverride: _toAccountUuid,
          extraTags: tpo.extraTags,
        );
      }
      if (!mounted) return;

      if (context.canPop()) {
        context.pop();
      }

      context.showToast(
        text: "transactions.batch.import.success".t(context, tpos.length),
        type: .success,
      );
    } catch (e) {
      //
    } finally {
      _busy = false;
      if (mounted) {
        setState(() {});
      }
    }
  }
}
