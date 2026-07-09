import "dart:async";

import "package:flow/data/transaction_filter.dart";
import "package:flow/entity/backup_entry.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/prefs/local_preferences.dart";

import "package:flow/services/transactions.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/sync/export.dart";
import "package:flow/utils/should_execute_scheduled_task.dart";
import "package:logging/logging.dart";
import "package:moment_dart/moment_dart.dart";
import "package:flow/objectbox/actions.dart";

final Logger _log = Logger("SyncService");

class SyncService {
  static const String cloudBackupsFolder = "backups";

  static const String cloudFileBaseName = "latest";

  static SyncService? _instance;

  factory SyncService() => _instance ??= SyncService._internal();

  int get activeSyncersCount {
    return 0; // iCloud sync removed
  }

  bool get working => activeSyncersCount > 0;

  SyncService._internal() {
    triggerAutoBackup();
  }

  Future<void> triggerAutoBackup() async {
    try {
      final int? intervalHours =
          UserPreferencesService().autoBackupIntervalInHours;

      if (intervalHours == null) {
        _log.info("Auto backup is disabled");
        return;
      }

      final DateTime? lastBackup =
          TransitiveLocalPreferences().lastAutoBackupRanAt.value;

      if (!shouldExecuteScheduledTask(
        Duration(hours: intervalHours),
        lastBackup,
      )) {
        _log.info(
          "Auto backup is not due yet (last ran at: ${lastBackup?.toIso8601String()})",
        );
        return;
      }

      if (TransactionsService().countMany(TransactionFilter.empty) == 0) {
        _log.info(
          "Auto backup is cancelled due to having no transactions (last ran at: ${lastBackup?.toIso8601String()})",
        );
        return;
      }

      final result = await export(
        type: BackupEntryType.automated,
        showShareDialog: false,
      );

      try {
        final int? id = await result.objectBoxId;

        if (id == null || id < 1) {
          throw Exception("Failed to get objectBoxId from export result");
        }

        final BackupEntry? entry = ObjectBox().box<BackupEntry>().get(id);

        if (entry == null) {
          throw Exception("Failed to get BackupEntry from objectBoxId: $id");
        }

        unawaited(putToAll(entry));
      } catch (e, stackTrace) {
        _log.warning(
          "Failed to upload backup to iCloud: ${result.filePath}",
          e,
          stackTrace,
        );
      }

      final Moment now = Moment.now();

      await TransitiveLocalPreferences().lastAutoBackupRanAt.set(now);
      await TransitiveLocalPreferences().lastAutoBackupPath.set(
        result.filePath,
      );
      _log.info("Auto backup successfully ran at $now");

      await _cleanupOldBackups();
    } catch (e, stackTrace) {
      _log.severe("Failed to perform auto-backup", e, stackTrace);
    }
  }

  Future<void> _cleanupOldBackups() async {
    try {
      final int? retentionDays = 
          UserPreferencesService().autoBackupRetentionDays;
          
      if (retentionDays == null) {
        _log.info("Auto backup retention is set to forever. Skipping cleanup.");
        return;
      }

      final DateTime cutoffDate =
          DateTime.now().subtract(Duration(days: retentionDays));

      final query = ObjectBox()
          .box<BackupEntry>()
          .query(BackupEntry_.type.equals(BackupEntryType.automated.value))
          .build();

      final List<BackupEntry> allAutoEntries = query.find();
      query.close();

      final oldEntries = allAutoEntries.where(
        (e) => e.createdDate.isBefore(cutoffDate),
      ).toList();

      if (oldEntries.isEmpty) {
        return;
      }

      _log.info(
        "Found ${oldEntries.length} auto backups older than $retentionDays days. Deleting...",
      );

      for (final entry in oldEntries) {
        await entry.delete();
      }

      _log.info("Successfully deleted ${oldEntries.length} old auto backups.");
    } catch (e, stackTrace) {
      _log.warning("Failed to clean up old auto backups", e, stackTrace);
    }
  }

  Future<bool> putToAll(
    BackupEntry entry, {
    Function(double)? onProgress,
  }) async {
    return false; // iCloud sync removed
  }
}
