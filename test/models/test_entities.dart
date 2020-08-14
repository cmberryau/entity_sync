import 'package:moor/moor.dart';

import 'package:entity_sync/entity_sync.dart';
import 'package:entity_sync/moor_entity_sync.dart';

import 'database.dart';

@DataClassName('TestMoorEntity')
class TestMoorEntities extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 3, max: 100)();
  DateTimeColumn get created => dateTime()();
  BoolColumn get shouldSync => boolean().clientDefault(() => true)();
}

class TestMoorEntityProxyFactory extends ProxyFactory<TestMoorEntityProxy,
    TestMoorEntity> {
  @override
  TestMoorEntityProxy proxyFromInstance(TestMoorEntity instance) {
    return TestMoorEntityProxy.fromEntity(instance);
  }
}

class TestMoorEntityProxy extends TestMoorEntity with ProxyMixin,
    SyncableMixin, SerializableMixin {
  /// The unique syncable key of the entity
  static final keyField = IntegerField('id');
  /// The flag to indicate the entity needs to be synced
  static final flagField = BoolField('shouldSync');

  TestMoorEntityProxy.fromEntity(TestMoorEntity instance)
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

