import "dart:io";

import "package:flow/data/transaction_multi_programmable_object.dart";
import "package:flow/data/transaction_programmable_object.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/entity/transaction/type.dart";
import "package:flow/utils/csv_parser.dart";
import "package:logging/logging.dart";

final Logger _log = Logger("AlipayCsvParser");

class AlipayCsvParser {
  static Future<TransactionMultiProgrammableObject> parse(File file) async {
    final List<List<dynamic>> rawData = await parseCsvFromFile(file, shouldParseNumbers: false);

    int headerIndex = -1;

    for (int i = 0; i < rawData.length; i++) {
      final List<dynamic> row = rawData[i];
      if (row.isNotEmpty && row[0].toString().trim().contains("------------------------支付宝")) {
        headerIndex = i + 1; // The next line is the header
        break;
      }

      // Fallback: look for actual headers
      if (row.length >= 7 && row[0].toString().trim() == "交易时间" && row[6].toString().trim() == "金额") {
        headerIndex = i;
        break;
      }
    }

    if (headerIndex == -1 || headerIndex >= rawData.length) {
      throw Exception("Invalid Alipay CSV format: Could not find header row");
    }

    final List<dynamic> headerRow = rawData[headerIndex];
    final Map<String, int> headerMap = {};
    for (int i = 0; i < headerRow.length; i++) {
      headerMap[headerRow[i].toString().trim()] = i;
    }

    // Ensure required headers exist
    final requiredHeaders = ["交易时间", "收/支", "金额", "交易对方"];
    for (final header in requiredHeaders) {
      if (!headerMap.containsKey(header)) {
        throw Exception("Invalid Alipay CSV format: Missing column '$header'");
      }
    }

    final List<TransactionProgrammableObject> transactions = [];

    for (int i = headerIndex + 1; i < rawData.length; i++) {
      final List<dynamic> row = rawData[i];
      if (row.isEmpty || row.length < requiredHeaders.length || row[0].toString().trim().isEmpty) {
        continue;
      }

      try {
        final String dateStr = row[headerMap["交易时间"]!].toString().trim();
        final DateTime transactionDate = DateTime.parse(dateStr);

        final String typeStr = row[headerMap["收/支"]!].toString().trim();

        final String amountStrRaw = row[headerMap["金额"]!].toString().trim();
        // Remove currency symbols if any
        final String cleanAmountStr = amountStrRaw.replaceAll(RegExp(r"[^\d.]"), "");
        final double amountAbs = double.tryParse(cleanAmountStr) ?? 0.0;

        final String title = row[headerMap["交易对方"]!].toString().trim();

        // Construct notes
        final List<String> notesParts = [];

        final String? product = headerMap.containsKey("商品说明") ? row[headerMap["商品说明"]!].toString().trim() : null;
        if (product != null && product.isNotEmpty && product != "/") {
          notesParts.add("商品: $product");
        }

        final String? payMethod = headerMap.containsKey("收/付款方式") ? row[headerMap["收/付款方式"]!].toString().trim() : null;
        if (payMethod != null && payMethod.isNotEmpty && payMethod != "/") {
          notesParts.add("支付方式: $payMethod");
        }

        final String? status = headerMap.containsKey("交易状态") ? row[headerMap["交易状态"]!].toString().trim() : null;
        if (status != null && status.isNotEmpty && status != "/") {
          if (status.contains("失败") || status.contains("关闭")) {
            // Unpaid transactions that failed/closed will have an empty payMethod.
            // If payMethod is NOT empty, it means the transaction was paid and later closed (e.g. refunded).
            // We must keep paid-and-closed transactions to offset their corresponding refund row.
            if (payMethod == null || payMethod.isEmpty || payMethod == "/") {
               continue;
            }
          }
          notesParts.add("当前状态: $status");
        }
        
        final String? tradeNo = headerMap.containsKey("交易订单号") ? row[headerMap["交易订单号"]!].toString().trim() : null;
        if (tradeNo != null && tradeNo.isNotEmpty && tradeNo != "/") {
          notesParts.add("交易单号: $tradeNo");
        }

        final String? remark = headerMap.containsKey("备注") ? row[headerMap["备注"]!].toString().trim() : null;
        if (remark != null && remark.isNotEmpty && remark != "/") {
          notesParts.add("备注: $remark");
        }

        final String? transactionType = headerMap.containsKey("交易分类") ? row[headerMap["交易分类"]!].toString().trim() : null;

        final bool isRefund = (transactionType != null && transactionType.contains("退款")) || 
                              (status != null && status.contains("退款")) ||
                              title.startsWith("退款-");

        double amount = amountAbs;
        if (typeStr == "支出") {
          amount = -amountAbs;
        } else if (typeStr == "收入") {
          amount = amountAbs;
        } else {
          // 不计收支 etc.
          if (isRefund) {
             amount = amountAbs; // Refunds back to the user are positive
          } else {
             amount = -amountAbs; // Default outgoing for transfer/payments
          }
        }

        if (transactionType != null && transactionType.isNotEmpty && transactionType != "/") {
          notesParts.add("交易类型: $transactionType");
        }

        final String notes = notesParts.join("\n\n");

        final List<String> tags = [Transaction.importedFromAlipayTag];

        final bool isBankCard = payMethod != null && 
            payMethod.isNotEmpty && 
            payMethod != "/" && 
            !payMethod.contains("余额") && 
            !payMethod.contains("花呗");
            
        if (isBankCard && (typeStr != "收入" || isRefund)) {
          tags.add(Transaction.importedFromAlipayBankCardTag);
        }
        
        if (typeStr == "不计收支" || typeStr == "/" || typeStr == "") {
          tags.add(Transaction.importedFromAlipayTransferTag);
        }

        transactions.add(
          TransactionProgrammableObject(
            title: title,
            amount: amount,
            transactionDate: transactionDate,
            notes: notes,
            type: amount < 0 ? TransactionType.expense : TransactionType.income,
            extraTags: tags,
          ),
        );
      } catch (e) {
        _log.warning("Failed to parse Alipay CSV row $i", e);
      }
    }

    return TransactionMultiProgrammableObject(t: transactions);
  }
}
