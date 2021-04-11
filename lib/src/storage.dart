import 'sync.dart';

class StorageResult<TSyncable extends SyncableMixin> {
  bool successful;

  StorageResult(this.successful);
}

/// Responsible for local storage of syncable entities
abstract class Storage<TSyncable extends SyncableMixin> {
  /// Gets the instances to sync
  Future<Iterable<TSyncable>> getInstancesToSync();

  /// Gets an instance matching the remote key, or null
  Future<TSyncable?> get({dynamic remoteKey, dynamic localKey});

  /// Upserts an instance using an optional local key
  Future<StorageResult<TSyncable>> insert(TSyncable instance);

  /// Upserts an instance using an optional local key
  Future<StorageResult<TSyncable>> update(TSyncable instance,
      {dynamic remoteKey, dynamic localKey});
}
