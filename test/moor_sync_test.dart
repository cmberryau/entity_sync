import 'package:entity_sync/src/moor_sync.dart';
import 'package:moor/ffi.dart';
import 'package:test/test.dart';

import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

import 'package:entity_sync/entity_sync.dart';

import 'models/test_entities.dart';
import 'serialization_test.dart';
import 'endpoints_test.dart';
import 'models/database.dart';

/// A serializer for TestEntity
class TestMoorEntityProxySerializer extends Serializer<TestMoorEntityProxy> {
  final fields = <SerializableField>[
    IntegerField('id'),
    StringField('name'),
    DateTimeField('created'),
  ];

  TestMoorEntityProxySerializer({Map<String, dynamic>data,
    TestMoorEntityProxy instance})
      : super(data: data, instance: instance);

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
    return TestMoorEntityProxy(validatedData['id'],
                               validatedData['name'],
                               validatedData['created']);
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
      final postTestEntity = TestMoorEntityProxy(1, "OutdatedTestName",
          nowWithoutSubsecondPrecision, shouldSync: true);
      final postTestSerializer = TestMoorEntityProxySerializer(
          instance: postTestEntity);
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
          TestMoorEntityProxySerializer(), client: client);
      final syncController = MoorSyncController<TestMoorEntityProxy, TestMoorEntity>(endpoint,
          database.testMoorEntities, database, TestMoorEntityProxyFactory());

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