import 'package:entity_sync/src/sync.dart';


/// Responsible for controlling the syncing of entities and a moor sqlite db
abstract class MoorSyncController<TSyncable extends SyncableMixin> {
  Future<SyncResult<TSyncable>> sync() async {

  }
}