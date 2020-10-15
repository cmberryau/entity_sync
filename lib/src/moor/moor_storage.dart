part of 'moor.dart';

/// Responsible for local storage through moor
class MoorStorage<TProxy extends ProxyMixin> implements Storage<TProxy> {
  /// The moor database that we are syncing with
  final GeneratedDatabase database;

  /// The moor table that we are syncing with
  final SyncableTable table;

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
  Future<StorageResult<TProxy>> upsertInstance(TProxy instance) async {
    await database.into(table.actualTable()).insertOnConflictUpdate(instance);
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
