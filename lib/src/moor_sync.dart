import 'dart:mirrors';

import 'package:entity_sync/entity_sync.dart';
import 'package:moor/moor.dart';

import 'package:entity_sync/src/sync.dart';


/// Responsible for creating proxies
abstract class ProxyFactory<TProxy, TEntity extends DataClass> {
  TProxy proxyFromInstance(TEntity instance);
}

/// Provides all the functionality to act as a proxy
abstract class ProxyMixin implements SyncableMixin, SerializableMixin {
  Insertable<DataClass> asInsertable() {
    return this as Insertable<DataClass>;
  }
}

class MoorStorage<TProxy extends ProxyMixin, TEntity extends DataClass>
    extends Storage<TProxy> {
  /// The moor database that we are syncing with
  final GeneratedDatabase database;
  /// The moor table that we are syncing with
  final Table table;
  /// The flag column of the table
  Column flagColumn;

  /// The proxy factory
  final ProxyFactory<TProxy, TEntity> factory;

  @override
  Future<Iterable<TProxy>> getInstancesToSync() async {
    final toSyncInstances = await (database.select(table)
      ..where((t) => flagColumn.equals(true))).get();
    return toSyncInstances.map((e) => factory.proxyFromInstance(e));
  }

  @override
  Future<StorageResult<TProxy>> writeInstance(TProxy instance) async {
    await database.into(table).insertOnConflictUpdate(instance.asInsertable());
    return StorageResult<TProxy>(true);
  }

  MoorStorage(this.table, this.database, this.factory) {
    /// get the actual flag field name, have to reflect for it
    final actualFlagField = reflectClass(TProxy)
        .getField(Symbol('flagField')).reflectee;

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

/// Responsible for controlling the syncing of entities and a moor sqlite db
class MoorSyncController<TProxy extends ProxyMixin, TEntity extends DataClass>
    extends SyncController<TProxy> {
  /// The moor database that we are syncing with
  final GeneratedDatabase database;
  /// The moor table that we are syncing with
  final Table table;
  /// The flag column of the table
  Column flagColumn;
  /// The proxy factory
  final ProxyFactory<TProxy, TEntity> factory;

  MoorSyncController(endpoint, this.table, this.database, this.factory)
      :super(endpoint){
    /// get the actual flag field name, have to reflect for it
    final actualFlagField = reflectClass(TProxy)
        .getField(Symbol('flagField')).reflectee;

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

  @override
  Future<SyncResult<TProxy>> sync() async {
    /// get all instances to sync
    final toSyncInstances = await getInstancesToSync();

    var successful = true;
    final endpointResults = <EndpointResult<TProxy>>[];

    /// push to endpoint
    for (var instanceToPush in toSyncInstances) {
      /// push the instance as json to get around types
      final pushToEndpoint = await endpoint.push(instanceToPush);

      /// save the endpoint results for the sync result
      endpointResults.add(pushToEndpoint);
      successful &= pushToEndpoint.successful;

      if (pushToEndpoint.successful) {
        if (pushToEndpoint.instances.isNotEmpty) {
          if (pushToEndpoint.instances.length > 1) {
            /// TODO Warn if more than one returned
            throw UnimplementedError();
          }

          final returnedInstance = pushToEndpoint.instances[0];
          /// Compare and write any changes to table
          if(!endpoint.serializer.areEqual(instanceToPush, returnedInstance)) {
            await database.into(table)
                .insertOnConflictUpdate(returnedInstance.asInsertable());
          }
        } else {
          /// TODO Warn if none returned
          throw UnimplementedError();
        }
      } else {
        /// TODO Warn if not successful
        throw UnimplementedError();
      }
    }

    /// pull all from endpoint since last sync
    /// TODO add last sync filter
    final endpointPullAll = await endpoint.pullAll();
    final endpointEntities = endpointPullAll.instances;

    /// Insert all into local db
    for (var entity in endpointEntities) {
      await database.into(table).insertOnConflictUpdate(entity.asInsertable());
    }

    return SyncResult<TProxy>(successful, endpointResults);
  }

  Future<Iterable<TProxy>> getInstancesToSync() async {
    final toSyncInstances = await (database.select(table)
      ..where((t) => flagColumn.equals(true))).get();
    return toSyncInstances.map((e) => factory.proxyFromInstance(e));
  }
}