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
    await database.into(table.actualTable() as TableInfo).insert(instance);
    return StorageResult<TProxy>(successful: true);
  }

  @override
  Future<StorageResult<TProxy>> update(TProxy instance,
      {dynamic remoteKey, dynamic localKey}) async {
    final localInstance = await get(remoteKey: remoteKey, localKey: localKey);

    if (localInstance != null) {
      await (database.update(table.actualTable() as TableInfo)
            ..where((t) =>
                table.localKeyColumn().equals(localInstance.getLocalKey())))
          .write(instance);
    } else {
      throw ArgumentError('Could not find a local instance');
    }

    return StorageResult<TProxy>(successful: true);
  }

  @override
  Future<DateTime> getLastUpdated() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey(_getLastUpdateTableNameKey())) {
      final lastUpdatedString = prefs.getString(_getLastUpdateTableNameKey());
      return DateTime.parse(lastUpdatedString!);
    }

    await setLastUpdated(DateTime(1900));
    return DateTime(1900);
  }

  @override
  Future setLastUpdated(DateTime lastUpdated) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _getLastUpdateTableNameKey(),
      lastUpdated.toIso8601String(),
    );
  }

  String _getLastUpdateTableNameKey() {
    return (table.actualTable() as TableInfo).actualTableName! + '_lastUpdate';
  }
}
