import 'package:entity_sync/moor_sync.dart';
import 'package:drift/drift.dart';

import 'sync.dart';

class StorageResult<TSyncable extends SyncableMixin> {
  bool successful;

  StorageResult({required this.successful});

  @override
  String toString() {
    return 'StorageResult(successful: $successful)';
  }
}

/// Responsible for local storage of syncable entities
abstract class Storage<TSyncable extends SyncableMixin> {
  /// Get the instances to sync
  Future<Iterable<TSyncable>> getInstancesToSync();

  /// Get an instance matching the remote key first, local key second if
  /// no remote key provided, or null
  Future<TSyncable?> get({dynamic remoteKey, dynamic localKey});

  /// Upsert an instance using an optional local key
  Future<StorageResult<TSyncable>> insert(TSyncable instance);

  /// Update an instance using an optional local key
  Future<StorageResult<TSyncable>> update(
    TSyncable instance, {
    dynamic remoteKey,
    dynamic localKey,
  });

  /// Deletes an instance matching the remote key first, local key second if
  /// no remote key provided, or null
  Future<StorageResult<TSyncable>> delete({dynamic remoteKey, dynamic localKey});

  Future<int> count();

  Future<bool> isEmpty();

  Future<bool> containsOnlyInstances(List<TSyncable> instances);

  String getStorageName();

  Future clear();
}

/// The relation between syncable entities
abstract class Relation<TSyncable extends SyncableMixin> {
  Future<String?> needToSyncInstance(TSyncable instance);
}

/// The moor relation between syncable entities
class MoorRelation<TProxy extends ProxyMixin<DataClass>>
    implements Relation<TProxy> {
  /// The database that contains both entities
  final GeneratedDatabase database;

  /// The foreign key on the original table
  final String fkColumn;

  /// The foreign key's table
  final SyncableTable fkTable;

  MoorRelation({
    required this.database,
    required this.fkColumn,
    required this.fkTable,
  });

  @override
  Future<String?> needToSyncInstance(TProxy instance) async {
    // get the remote key
    final remoteKey = instance.toMap()[fkColumn];

    // get the related instance
    final fkInstance = await (database.select(
      fkTable.actualTable() as TableInfo,
    )..where(
            (t) => fkTable.remoteKeyColumn().equals(remoteKey),
          ))
        .getSingleOrNull();

    // if the related instance is missing then return null else return its
    // remote key
    if (fkInstance == null) {
      return remoteKey;
    }

    return null;
  }

  @override
  String toString() {
    return 'MoorRelation(database: $database, fkColumn: $fkColumn, fkTable: $fkTable)';
  }
}
