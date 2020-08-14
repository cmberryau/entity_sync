import 'sync.dart';

class StorageResult<TSyncable extends SyncableMixin> {
  bool successful;

  StorageResult(this.successful);
}

abstract class Storage<TSyncable extends SyncableMixin> {
  Future<Iterable<TSyncable>> getInstancesToSync();
  Future<StorageResult<TSyncable>> writeInstance(TSyncable instance);
}