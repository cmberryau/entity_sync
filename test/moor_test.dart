import 'package:moor/ffi.dart';
import 'package:test/test.dart';

import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

import 'package:entity_sync/entity_sync.dart';
import 'package:entity_sync/moor_sync.dart';

import 'models/test_entities.dart';
import 'models/database.dart';
import 'endpoints_test.dart';

/// A serializer for TestEntity
class TestMoorEntitySerializer extends Serializer<TestMoorEntityProxy> {
  final fields = <SerializableField>[
    IntegerField('id'),
    StringField('name'),
    DateTimeField('created'),
  ];

  TestMoorEntitySerializer({Map<String, dynamic>data,
    TestMoorEntityProxy instance}) : super(data: data, instance: instance);

  int validateId(int value) {
    if (value < 0) {
      throw ValidationException('id must be positive value');
    }

    return value;
  }

  String validateName(String value) {
    if (value == null) {
      throw ValidationException('name must not be null');
    }

    if (value.isEmpty) {
      throw ValidationException('name must not be empty');
    }

    return value;
  }

  DateTime validateCreated(DateTime value) {
    if (value == null) {
      throw ValidationException('created must not be null');
    }

    return value;
  }

  @override
  TestMoorEntityProxy createInstance(validatedData) {
    final entity = TestMoorEntity(id: validatedData['id'],
                                  name: validatedData['name'],
                                  created: validatedData['created'],
                                  shouldSync: false);
    return TestMoorEntityProxy(entity, entity.shouldSync);
  }
}

void main() {
  TestDatabase database;

  group('Test SyncController.sync with MoorStorage and RestfulApiEndpoint', () {
    setUp(() {
      database = TestDatabase(VmDatabase.memory());
    });

    test('Test simple outdated local data case', () async {
      /// Set up the mock client
      final client = MockClient();
      final url = 'https://www.example.com/test-entity';

      final now = DateTime.now();
      final nowWithoutSubsecondPrecision = DateTime(now.year, now.month,
          now.day, now.hour, now.minute, now.second);
      final postTestEntity = TestMoorEntity(id: 1, name:"OutdatedTestName",
          created: nowWithoutSubsecondPrecision, shouldSync: true);
      final postTestProxy = TestMoorEntityProxy(postTestEntity,
          postTestEntity.shouldSync);
      final postTestSerializer = TestMoorEntitySerializer(
          instance: postTestProxy);
      final postTestRepresentation = postTestSerializer
          .toRepresentationString();

      final getResponseBody = '[{"id": 2, "name": "TestName", '
          '"created": "2020-08-07T12:30:15.123456"}]';
      final postResponseBody = '{"id": 1, "name": "UpdatedTestName", '
          '"created": "2020-08-07T12:45:15.123456"}';
      final statusCode = 200;

      when(client.get('${url}')).thenAnswer((a) async => http.Response(
          getResponseBody, statusCode));
      when(client.post('${url}', body: postTestRepresentation))
          .thenAnswer((a) async => http.Response(postResponseBody, statusCode));

      /// Validate that we have zero entities in the db
      var entities = await database.getTestMoorEntities();
      expect(entities, isNotNull);
      expect(entities.length, equals(0));

      /// Pop in one entity
      await database.into(database.testMoorEntities).insert(postTestEntity);
      entities = await database.getTestMoorEntities();
      expect(entities, isNotNull);
      expect(entities.length, equals(1));

      /// Create the endpoint, storage and sync controller
      final endpoint = RestfulApiEndpoint<TestMoorEntityProxy>(url,
          TestMoorEntitySerializer(), client: client);
      final factory = TestMoorEntityProxyFactory();
      final storage = MoorStorage<TestMoorEntityProxy>(
          database.testMoorEntities, database, factory);
      final syncController = SyncController<TestMoorEntityProxy>(endpoint,
          storage);

      /// Perform the sync
      final result = await syncController.sync();
      expect(result, isNotNull);

      /// Validate the synced entities
      entities = await database.getTestMoorEntities();
      expect(entities, isNotNull);
      expect(entities.length, equals(2));

      /// Validate that entity with id == 1 has updated name
      expect(entities[0].id, equals(1));
      expect(entities[0].name, equals('UpdatedTestName'));
      /// DateTime fields lose subsecond precision in moor
      expect(entities[0].created, equals(DateTime(2020, 8, 7, 12, 45, 15)));

      /// Validate that entity with id == 2 is as expected
      expect(entities[1].id, equals(2));
      expect(entities[1].name, equals('TestName'));
      expect(entities[1].created, equals(DateTime(2020, 8, 7, 12, 30, 15)));
    });
    
    tearDown(() async {
      await database.close();
    });
  });
}