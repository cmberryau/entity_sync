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
  Future<StorageResult<TProxy>> upsertInstance(dynamic instance,
      [dynamic oldInstance]) async {
    try {
      if (instance.remoteKeyField != null) {
        final instanceRemoteId = instance.toMap()[instance.remoteKeyField.name];

        // the case where the model is read only
        if (instance.keyField == null) {
          // check if the instance is already exist
          final result = await (database.select(table.actualTable())
                ..where(
                    (_) => table.remoteKeyColumn().equals(instanceRemoteId)))
              .getSingle();

          if (result == null) {
            await database.into(table.actualTable()).insert(instance);
          } else {
            await (database.update(table.actualTable())
                  ..where(
                      (_) => table.remoteKeyColumn().equals(instanceRemoteId)))
                .write(instance);
          }
          return StorageResult<TProxy>(true);
        }
        // if this is the result of a push operation
        else if (oldInstance != null) {
          final mapData = instance.toMap();
          final localKey = instance.keyField.name;
          mapData[localKey] = oldInstance.toMap()[localKey];
          instance = instance.copyFromMap(mapData);
        } else {
          // find an existing instance in the database then assign the existing id
          // to the new instance
          if (instanceRemoteId != null) {
            final result = await (database.select(table.actualTable())
                  ..where(
                      (_) => table.remoteKeyColumn().equals(instanceRemoteId)))
                .getSingle();

            if (result != null) {
              final oldInstanceKeyValue =
                  result.toJson()[instance.keyField.name];
              final mapData = instance.toMap();
              mapData[instance.keyField.name] = oldInstanceKeyValue;
              instance = instance.copyFromMap(mapData as Map<String, dynamic>);
            }
          }
        }
      }
      await database.into(table.actualTable()).insert(instance,
          onConflict: DoUpdate((_) => instance),
          mode: InsertMode.insertOrReplace);
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
