import 'package:moor/moor.dart';

import 'package:entity_sync/entity_sync.dart';
import 'package:entity_sync/moor_sync.dart';

import 'database.dart';

@DataClassName('TestMoorEntity')
class TestMoorEntities extends Table with SyncableTableMixin {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 3, max: 100)();
  DateTimeColumn get created => dateTime()();

  @override
  Table actualTable() => this;
}

class TestMoorEntityProxyFactory extends ProxyFactory<TestMoorEntityProxy,
    TestMoorEntity> {
  @override
  TestMoorEntityProxy fromInstance(TestMoorEntity instance) {
    return TestMoorEntityProxy(instance);
  }
}

class TestMoorEntityProxy extends TestMoorEntity
    with ProxyMixin<TestMoorEntity>, SyncableMixin, SerializableMixin {
  /// The unique syncable key of the entity
  static final keyField = IntegerField('id');

  TestMoorEntityProxy(TestMoorEntity instance): super(id: instance.id,
                                                      name: instance.name,
                                                      created: instance.created,
                                                      shouldSync: true);
}

