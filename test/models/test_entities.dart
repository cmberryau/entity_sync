import 'package:moor/moor.dart';

import 'package:entity_sync/entity_sync.dart';
import 'package:entity_sync/moor_sync.dart';

import 'database.dart';

@DataClassName('TestMoorEntity')
class TestMoorEntities extends Table with SyncableMoorTableMixin {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 3, max: 100)();
  DateTimeColumn get created => dateTime()();
}

class TestMoorEntityProxyFactory extends ProxyFactory<TestMoorEntityProxy,
    TestMoorEntity> {
  @override
  TestMoorEntityProxy proxyFromInstance(TestMoorEntity instance) {
    return TestMoorEntityProxy.fromInstance(instance);
  }
}

class TestMoorEntityProxy extends TestMoorEntity
    with ProxyMixin<TestMoorEntity>, SyncableMixin, SerializableMixin {
  /// The unique syncable key of the entity
  static final keyField = IntegerField('id');
  /// The flag to indicate the entity needs to be synced
  static final flagField = BoolField('shouldSync');

  static ProxyMixin proxyFromInstance(DataClass instance) {
    return TestMoorEntityProxy.fromInstance(instance);
  }

  TestMoorEntityProxy.fromInstance(TestMoorEntity instance)
      :super(id: instance.id,
             name: instance.name,
             created: instance.created,
             shouldSync: instance.shouldSync);

  TestMoorEntityProxy(id, name, created, {bool shouldSync = false})
      :super(id: id,
             name: name,
             created: created,
             shouldSync: shouldSync);
}

