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

  /// The name of the table
  String sqlTableName;
  String sqlFlagColumnName;

  MoorSyncController(endpoint, this.table, this.database) : super(endpoint) {
    /// get the actual table name, have to reflect for it
    sqlTableName = reflect(table).getField(Symbol('actualTableName')).reflectee;

    /// get the actual flag field name, have to reflect for it
    final actualFlagField = reflectClass(TSyncable).getField(Symbol('flagField')).reflectee;

    if (actualFlagField == null) {
      throw ArgumentError('TSyncable does not have static BoolField member');
    }

    if (actualFlagField.runtimeType != BoolField) {
      throw ArgumentError('TSyncable.flagField is not BoolField');
    }

    flagFieldName = (actualFlagField as BoolField).name;

    final camelCaseRegex = RegExp(r'(?<=[a-z])[A-Z]');
    sqlFlagColumnName = flagFieldName.replaceAllMapped(camelCaseRegex,
            (m) => ('_' + m.group(0))).toLowerCase();
  }

  Future<SyncResult<TSyncable>> sync() async {
    /// get all entities with flag == true
    final toSyncSql = 'SELECT * FROM ${sqlTableName} WHERE ${sqlFlagColumnName} == true;';
    final toSyncRawInstances = await database.customSelect(toSyncSql).get();
    final flagColumn = reflect(table).getField(Symbol('shouldSync')).reflectee;
    final toSyncConcreteInstances = await (database.select(table)..where((t) => flagColumn.equals(true))).get();
    
    /// push to endpoint
    for (var rawInstance in toSyncRawInstances) {
      final pushToEndpoint = await endpoint.push(null);
    }

    /// write changes from endpoint to moor table

    /// pull all from endpoint
    final endpointPullAll = await endpoint.pullAll();
    final endpointEntities = endpointPullAll.instances;

    /// Insert all into local db
    for (var entity in endpointEntities) {
      await database.into(table).insertOnConflictUpdate(entity as dynamic);
    }

    return SyncResult<TSyncable>();
  }
}