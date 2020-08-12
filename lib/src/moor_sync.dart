import 'dart:mirrors';

import 'package:entity_sync/entity_sync.dart';
import 'package:moor/moor.dart';

import 'package:entity_sync/src/sync.dart';


/// Responsible for controlling the syncing of entities and a moor sqlite db
class MoorSyncController<TSyncable extends SyncableMixin> extends SyncController {
  /// The moor database that we are syncing with
  final GeneratedDatabase database;
  /// The moor table that we are syncing with
  final Table table;
  /// The name of the flag field for TSyncable
  String flagFieldName;

  MoorSyncController(endpoint, this.table, this.database) : super(endpoint) {
    /// get the actual flag field name, have to reflect for it
    final actualFlagField = reflectClass(TSyncable).getField(Symbol('flagField')).reflectee;

    if (actualFlagField == null) {
      throw ArgumentError('TSyncable does not have static BoolField member');
    }

    if (actualFlagField.runtimeType != BoolField) {
      throw ArgumentError('TSyncable.flagField is not BoolField');
    }

    flagFieldName = (actualFlagField as BoolField).name;
  }

  Future<SyncResult<TSyncable>> sync() async {
    /// get all entities with flag == true
    final flagColumn = reflect(table).getField(Symbol(flagFieldName)).reflectee;
    final toSyncInstances = await (database.select(table)
      ..where((t) => flagColumn.equals(true))).get();
    
    /// push to endpoint
    for (var instance in toSyncInstances) {
      final pushToEndpoint = await endpoint.pushJson(instance.toJson());

      /// TODO write changes from endpoint to moor table
    }

    /// pull all from endpoint since last sync
    /// TODO add last sync filter
    final endpointPullAll = await endpoint.pullAll();
    final endpointEntities = endpointPullAll.instances;

    /// Insert all into local db
    for (var entity in endpointEntities) {
      await database.into(table).insertOnConflictUpdate(entity as dynamic);
    }

    return SyncResult<TSyncable>();
  }
}