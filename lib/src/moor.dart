import 'dart:mirrors';

import 'package:entity_sync/entity_sync.dart';
import 'package:moor/moor.dart';

import 'package:entity_sync/src/sync.dart';


/// Responsible for creating proxies
abstract class ProxyFactory<TProxy, TEntity extends DataClass> {
  /// Creates a proxy from a moor instance
  TProxy proxyFromInstance(TEntity instance);
}

/// Provides all the functionality to act as a proxy
abstract class ProxyMixin implements SyncableMixin, SerializableMixin {
  Insertable<DataClass> asInsertable() {
    return this as Insertable<DataClass>;
  }
}

abstract class SyncableMoorTableMixin {
  BoolColumn get shouldSync => BoolColumnBuilder().clientDefault(() => true)();
}

/// Responsible for local storage through moor
class MoorStorage<TProxy extends ProxyMixin> implements Storage<TProxy> {
  /// The moor database that we are syncing with
  final GeneratedDatabase database;
  /// The moor table that we are syncing with
  final Table table;
  /// The flag column of the table
  Column flagColumn;
  /// The proxy factory
  final ProxyFactory factory;

  @override
  Future<Iterable<TProxy>> getInstancesToSync() async {
    final toSyncInstances = await (database.select(table)
      ..where((t) => flagColumn.equals(true))).get();
    return toSyncInstances.map((e) => factory.proxyFromInstance(e));
  }

  @override
  Future<StorageResult<TProxy>> upsertInstance(TProxy instance) async {
    await database.into(table).insertOnConflictUpdate(instance.asInsertable());
    return StorageResult<TProxy>(true);
  }

  MoorStorage(this.table, this.database, this.factory) {
    /// get the actual flag field name
    final actualFlagField = reflectClass(TProxy)
        .getField(Symbol('flagField')).reflectee;

    if (table is! SyncableMoorTableMixin) {
      throw ArgumentError('Table argument must be SyncableMoorTable');
    }

    if (actualFlagField == null) {
      throw ArgumentError('TSyncable does not have static BoolField member');
    }

    if (actualFlagField.runtimeType != BoolField) {
      throw ArgumentError('TSyncable.flagField is not BoolField');
    }

    /// Resolve the flag column of the table
    final flagFieldName = (actualFlagField as BoolField).name;
    flagColumn = reflect(table).getField(Symbol(flagFieldName)).reflectee;
  }
}
