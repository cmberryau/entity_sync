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
  Future<TProxy> get({dynamic remoteKey, dynamic localKey}) async {
    dynamic instance;
    if (remoteKey != null) {
      instance = await (database.select(table.actualTable())..where((t) => table.remoteKeyColumn().equals(remoteKey))).getSingle();
    } else if (localKey != null) {
      instance = await (database.select(table.actualTable())..where((t) => table.localKeyColumn().equals(localKey))).getSingle();
    }

    if (instance == null) {
      return null;
    }

    return proxyFactory.fromInstance(instance);
  }

  @override
  Future<StorageResult<TProxy>> insert(TProxy instance, {dynamic remoteKey, dynamic localKey}) async {
    await database.into(table.actualTable()).insert(instance);
    return StorageResult<TProxy>(true);
  }

  @override
  Future<StorageResult<TProxy>> update(TProxy instance, {dynamic remoteKey, dynamic localKey}) async {
    final localInstance = await get(remoteKey: remoteKey, localKey: localKey);

    if (localInstance != null) {
      await (database.update(table.actualTable())..where((t) => table.localKeyColumn().equals(localInstance.getLocalKey()))).write(instance);
    }
    else {
      throw ArgumentError('Could not find a local instance');
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
