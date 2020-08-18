import 'dart:mirrors';

import 'package:entity_sync/entity_sync.dart';
import 'package:moor/moor.dart';

import 'package:entity_sync/src/sync.dart';


/// Responsible for creating proxies
abstract class ProxyFactory<TProxy extends ProxyMixin<TEntity>,
  TEntity extends DataClass> {
  /// Creates a proxy from a moor instance
  TProxy fromInstance(TEntity instance);
}

/// Provides all the functionality to act as a proxy
abstract class ProxyMixin<TEntity extends DataClass>
    implements Insertable<TEntity>, SyncableMixin, SerializableMixin  {
  /// The flag to indicate the entity should be synced
  static final flagField = BoolField('shouldSync');
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
  final ProxyFactory factory;

  @override
  Future<Iterable<TProxy>> getInstancesToSync() async {
    final toSyncInstances = await (database.select(table.actualTable())
      ..where((t) => flagColumn.equals(true))).get();
    return toSyncInstances.map((e) => factory.fromInstance(e));
  }

  @override
  Future<StorageResult<TProxy>> upsertInstance(TProxy instance) async {
    await database.into(table.actualTable()).insertOnConflictUpdate(instance);
    return StorageResult<TProxy>(true);
  }

  MoorStorage(this.table, this.database, this.factory) {
    /// Get the flag column on the table
    flagColumn = reflect(table).getField(Symbol('shouldSync')).reflectee;
  }
}
