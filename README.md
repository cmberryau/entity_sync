An entity sync library for Dart.

## Usage for Moor

Preparation:
1. Add the SyncableMoorTableMixin to your Table 
2. Create a proxy class which inherits from your generated Moor class - see ProxyMixin
3. Create a factory class for your proxy class - see ProxyFactory
4. Create a serializer for your proxy class - see Serializer


Actually syncing:
1. Instantiate an Endpoint (e.g RestfulApiEndpoint)
2. Instantiate a Storage (e.g MoorStorage)
3. Instantiate a SyncController, passing in the Endpoint and Storage
4. Call the sync method on the SyncController

When you modify any of your synced entities, set shouldSync flag to true, the sync method will take care of the rest.

A simple usage example:

```dart
import 'package:moor/moor.dart';

import 'package:entity_sync/entity_sync.dart';
import 'package:entity_sync/moor_sync.dart';

/// This is your moor database
import 'database.dart';

main() {
  /// Your database
  final database = TestDatabase(VmDatabase.memory());

  final endpoint = RestfulApiEndpoint<TestMoorEntityProxy>(url, TestMoorEntitySerializer());
  final storage = MoorStorage<TestMoorEntityProxy>(database.testMoorEntities, database, TestMoorEntityProxyFactory());
  final syncController = SyncController<TestMoorEntityProxy>(endpoint, storage);

  syncController.sync();
}

/// Add the SyncableMoorTableMixin to your table
@DataClassName('TestMoorEntity')
class TestMoorEntities extends Table with SyncableMoorTableMixin {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 3, max: 100)();
  DateTimeColumn get created => dateTime()();
}

/// Create a proxy class which inherits from your generated Moor class - see ProxyMixin
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

/// Create a factory class for your proxy class - see ProxyFactory 
class TestMoorEntityProxyFactory extends ProxyFactory<TestMoorEntityProxy,
    TestMoorEntity> {
  @override
  TestMoorEntityProxy proxyFromInstance(TestMoorEntity instance) {
    return TestMoorEntityProxy.fromEntity(instance);
  }
}

// Create a serializer for your proxy class - see Serializer
class TestMoorEntitySerializer extends Serializer<TestMoorEntityProxy> {
  final fields = <SerializableField>[
    IntegerField('id'),
    StringField('name'),
    DateTimeField('created'),
  ];

  TestMoorEntitySerializer({Map<String, dynamic>data,
    TestMoorEntityProxy instance}) : super(data: data, instance: instance);

  @override
  TestMoorEntityProxy createInstance(validatedData) {
    return TestMoorEntityProxy(validatedData['id'],
                               validatedData['name'],
                               validatedData['created']);
  }
}
```
