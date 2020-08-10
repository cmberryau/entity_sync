import 'package:moor/moor.dart';

import 'package:entity_sync/src/sync.dart';


/// Responsible for controlling the syncing of entities and a moor sqlite db
class MoorSyncController<TSyncable extends SyncableMixin> extends SyncController {
  /// The moor table that we are syncing with
  final Table table;

  MoorSyncController(endpoint, this.table) :super(endpoint);

  Future<SyncResult<TSyncable>> sync() async {
    throw UnimplementedError();
  }
}