part of 'moor.dart';

/// Responsible for local storage through moor
class MoorStorage<TProxy extends ProxyMixin<DataClass>>
    implements Storage<TProxy> {
  /// The moor database that we are syncing with
  final GeneratedDatabase database;

  /// The moor table that we are syncing with
  final SyncableTable table;

  /// The flag column of the table
  late Column flagColumn;

  /// The proxy factory
  final ProxyFactory proxyFactory;

  MoorStorage(this.table, this.database, this.proxyFactory) {
    /// Get the flag column on the table
    flagColumn = table.shouldSync;
  }

  @override
  Future<Iterable<TProxy>> getInstancesToSync() async {
    final toSyncInstances =
        await (database.select(table.actualTable() as TableInfo)
              ..where((t) => flagColumn.equals(true)))
            .get();

    return toSyncInstances.map((e) => proxyFactory.fromInstance(e) as TProxy);
  }

  @override
  Future<TProxy?> get({dynamic remoteKey, dynamic localKey}) async {
    DataClass? instance;
    if (remoteKey != null) {
      instance = await (database.select(table.actualTable() as TableInfo)
            ..where((t) => table.remoteKeyColumn().equals(remoteKey)))
          .getSingleOrNull();
    } else if (localKey != null) {
      instance = await (database.select(table.actualTable() as TableInfo)
            ..where((t) => table.localKeyColumn().equals(localKey)))
          .getSingleOrNull();
    }

    if (instance == null) {
      return null;
    }

    return proxyFactory.fromInstance(instance) as TProxy;
  }

  @override
  Future<StorageResult<TProxy>> insert(TProxy instance,
      {dynamic remoteKey, dynamic localKey}) async {
    await database.into(table.actualTable() as TableInfo).insert(
          instance,
          onConflict: DoUpdate(
            (_) => instance,
            target: [
              table.actualTable().remoteKeyColumn(),
            ],
          ),
        );

    return StorageResult<TProxy>(successful: true);
  }

  @override
  Future<StorageResult<TProxy>> update(TProxy instance,
      {dynamic remoteKey, dynamic localKey}) async {
    final localInstance = await get(remoteKey: remoteKey, localKey: localKey);

    if (localInstance != null) {
      try {
        await (database.update(table.actualTable() as TableInfo)
              ..where((t) =>
                  table.localKeyColumn().equals(localInstance.getLocalKey())))
            .write(instance);
      } on DriftRemoteException catch (e) {
        final remoteCause = e.remoteCause;
        if (remoteCause is String) {
          if (remoteCause.contains(
            'SqliteException(2067): UNIQUE constraint failed: ${'${(table
                .actualTable() as TableInfo).actualTableName}.${instance
                .remoteKeyField.name}'}',
          )) {
            final remoteKey = instance.getRemoteKey();
            if (remoteKey != null) {
              // update the instance based on the key without the id
              await (database.update(table.actualTable() as TableInfo)
                ..where((t) => table.remoteKeyColumn().equals(remoteKey)))
                  .write(
                (instance as dynamic).copyWith(
                  id: Value<int>.absent(),
                ),
              );

              // delete the duplicate instance
              await (database.delete(table.actualTable() as TableInfo)
                ..where((tbl) =>
                    table.localKeyColumn().equals(
                        localInstance.getLocalKey()))).go();

            }
          }
        }

        rethrow;
      }
    } else {
      throw ArgumentError('Could not find a local instance for ID $localKey');
    }

    return StorageResult<TProxy>(successful: true);
  }

  @override
  Future<bool> isEmpty() async {
    return (await count()) == 0;
  }

  @override
  Future<bool> containsOnlyInstances(Iterable<TProxy> instances) async {
    if (await count() != instances.length) {
      return false;
    }

    final result = await (database.select(table.actualTable() as TableInfo)
          ..where(
            (_) => table.remoteKeyColumn().isIn(
                  List<String>.from(instances
                      .map(
                        (e) => e.remoteKeyField.getValue(e),
                      )
                      .toList()),
                ),
          ))
        .get();

    return result.length == instances.length;
  }

  @override
  Future<int> count() async {
    final countExp = table.localKeyColumn().count();
    final query = database.selectOnly(table.actualTable() as TableInfo)
      ..addColumns([countExp]);

    return await query.map((row) => row.read(countExp)).getSingle();
  }

  @override
  Future clear() async {
    await database.delete(table.actualTable() as TableInfo).go();
  }

  @override
  String getStorageName() {
    return (table.actualTable() as TableInfo).actualTableName;
  }

  @override
  Future<StorageResult<TProxy>> delete({dynamic remoteKey, dynamic localKey}) async {
    var result = 0;
    if (remoteKey != null) {
      result = await (database.delete(table.actualTable() as TableInfo)
        ..where((t) =>
            table.remoteKeyColumn().equals(remoteKey))).go();
    } else if (localKey != null) {
      result = await (database.delete(table.actualTable() as TableInfo)
        ..where((t) =>
            table.localKeyColumn().equals(localKey))).go();
    }

    return StorageResult<TProxy>(successful: true);
  }
}
