import 'package:moor/moor.dart';

import 'package:entity_sync/entity_sync.dart';
import 'package:entity_sync/moor_sync.dart';

import 'database.dart';

part 'test_entities.g.dart';

@DataClassName('TestMoorEntity')
class TestMoorEntities extends Table with SyncableTableMixin {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 3, max: 100)();
  DateTimeColumn get created => dateTime()();

  @override
  Table actualTable() => this;
}

class TestMoorEntityProxyFactory
    extends ProxyFactory<TestMoorEntityProxy, TestMoorEntity> {
  @override
  TestMoorEntityProxy fromInstance(TestMoorEntity instance) {
    return TestMoorEntityProxy(instance, instance.shouldSync);
  }
}

@UseSerialization(TestMoorEntity)
class TestMoorEntityProxy extends $_TestMoorEntityProxy
    with ProxyMixin<TestMoorEntity>, SyncableMixin {
  /// The unique syncable key of the entity
  @override
  final keyField = IntegerField('id');

  TestMoorEntityProxy(TestMoorEntity instance, bool shouldSync)
      : super(
            id: instance.id,
            name: instance.name,
            created: instance.created,
            shouldSync: shouldSync);
}
