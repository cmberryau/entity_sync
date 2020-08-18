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

  group('Test MoorSyncController', () {
    setUp(() {
      database = TestDatabase(VmDatabase.memory());
    });

    test('Test MoorSyncController.sync', () async {
      /// Set up the mock client
      final client = MockClient();
      final url = 'https://www.example.com/test-entity';
      final getResponseBody = '[{"id": 2, "name": "TestName", '
          '"created": "2020-08-07T12:30:15.123456"}]';
      final postResponseBody = '{"id": 1, "name": "UpdatedTestName", '
          '"created": "2020-08-07T12:30:15.123456"}';
      final statusCode = 200;

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

      when(client.get('${url}')).thenAnswer((a) async => http.Response(
          getResponseBody, statusCode));
      when(client.post('${url}', body: postTestRepresentation))
          .thenAnswer((a) async => http.Response(postResponseBody, statusCode));

      /// Test the mock client
      final response = await client.get('${url}');
      expect(response, isNotNull);
      expect(response, isA<http.Response>());
      expect(response.body, equals(getResponseBody));
      expect(response.statusCode, equals(statusCode));

      var entities = await database.getTestMoorEntities();
      expect(entities, isNotNull);
      expect(entities.length, equals(0));

      await database.into(database.testMoorEntities).insert(postTestEntity);

      entities = await database.getTestMoorEntities();
      expect(entities, isNotNull);
      expect(entities.length, equals(1));

      /// Create the endpoint and the sync controller
      final endpoint = RestfulApiEndpoint<TestMoorEntityProxy>(url,
          TestMoorEntitySerializer(), client: client);
      final factory = TestMoorEntityProxyFactory();
      final storage = MoorStorage<TestMoorEntityProxy>(
          database.testMoorEntities, database, factory);
      final syncController = SyncController<TestMoorEntityProxy>(endpoint,
          storage);

      /// Perform the sync
      final results = await syncController.sync();

      entities = await database.getTestMoorEntities();
      expect(entities, isNotNull);
      expect(entities.length, equals(2));
    });
    
    tearDown(() async {
      await database.close();
    });
  });
}