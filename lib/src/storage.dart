import 'sync.dart';

class StorageResult<TSyncable extends SyncableMixin> {
  bool successful;

  StorageResult(this.successful);
}

/// Responsible for local storage of syncable entities
abstract class Storage<TSyncable extends SyncableMixin> {
  /// Gets the instances to sync
  Future<Iterable<TSyncable>> getInstancesToSync();
  
  /// Upserts an instance
  Future<StorageResult<TSyncable>> upsertInstance(TSyncable instance, [dynamic key]);
}