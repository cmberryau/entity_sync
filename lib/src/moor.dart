import 'dart:async';

import 'package:entity_sync/entity_sync.dart';
import 'package:entity_sync/src/sync.dart';
import 'package:moor/moor.dart';
import 'package:moor/src/dsl/dsl.dart';

/// Responsible for creating proxies
abstract class ProxyFactory<TProxy extends ProxyMixin<TEntity>,
    TEntity extends DataClass> {
  /// Creates a proxy from a moor instance
  TProxy fromInstance(TEntity instance);
}

/// Provides all the functionality to act as a proxy
abstract class ProxyMixin<TEntity extends DataClass>
    implements Insertable<TEntity>, SyncableMixin, SerializableMixin {
  @override
  final flagField = BoolField('shouldSync');
}

abstract class SyncableTableMixin {
  /// Indicates if the entity should be synced
  BoolColumn get shouldSync => BoolColumnBuilder().clientDefault(() => true)();

  /// The actual table
  Table actualTable();
}

/// Responsible for local storage through moor
class MoorStorage<TProxy extends ProxyMixin> implements Storage<TProxy> {
  /// The moor database that we are syncing with
  final GeneratedDatabase database;

  /// The moor table that we are syncing with
  final SyncableTableMixin table;

  /// The flag column of the table
  Column flagColumn;

  /// The proxy factory
  final proxyFactory;

  @override
  Future<Iterable<TProxy>> getInstancesToSync() async {
    final toSyncInstances = await (database.select(table.actualTable())
          ..where((t) => flagColumn.equals(true)))
        .get();

    return toSyncInstances.map((e) => proxyFactory.fromInstance(e));
  }

  @override
  Future<StorageResult<TProxy>> upsertInstance(dynamic instance,
      [dynamic oldInstance]) async {
    try {
      if (oldInstance != null) {
        instance =
            (instance as dynamic).copyWith(id: (oldInstance as dynamic).id);
      } else {
        final instanceUuid = instance.toMap()[instance.keyField.name];
        if (instanceUuid != null) {
          oldInstance = await (database.select(table.actualTable())
                ..where((dynamic t) => t.uuid.equals(instanceUuid)))
              .getSingle();

          if (oldInstance != null) {
            instance =
                (instance as dynamic).copyWith(id: (oldInstance as dynamic).id);
          }
        }
      }

      await database.into(table.actualTable()).insert(instance,
          onConflict: DoUpdate((tbl) {
        return instance.toCompanion(false).copyWith(
            id: instance.id == null
                ? Value<String>.absent()
                : Value<String>(instance.id));
      }), mode: InsertMode.insertOrReplace);
    } catch (err) {
      print(err);
    }

    return StorageResult<TProxy>(true);
  }

  MoorStorage(this.table, this.database, this.proxyFactory)
      : assert(table != null),
        assert(database != null),
        assert(proxyFactory != null) {
    /// Get the flag column on the table
    flagColumn = table.shouldSync;
  }
}
