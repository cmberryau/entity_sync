import 'package:moor/moor.dart';

import 'package:entity_sync/src/sync.dart';


/// Responsible for controlling the syncing of entities and a moor sqlite db
class MoorSyncController<TSyncable extends SyncableMixin> extends SyncController {
  /// The moor database that we are syncing with
  final GeneratedDatabase database;
  /// The moor table that we are syncing with
  final Table table;

  MoorSyncController(endpoint, this.table, this.database) :super(endpoint);

  Future<SyncResult<TSyncable>> sync() async {
    /// get all TSyncables from the moor table with shouldSync flag
    /// push to endpoint
    /// write changed TSyncables from endpoint to moor table

    throw UnimplementedError();
  }
}