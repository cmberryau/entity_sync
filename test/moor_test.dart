import 'package:entity_sync/entity_sync.dart';
import 'package:entity_sync/moor_sync.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:moor/ffi.dart';
import 'package:test/test.dart';

import 'endpoints_test.dart';
import 'models/database.dart';
import 'models/test_entities.dart';

void main() {
  late TestDatabase database;

  group('Test SyncController.sync with MoorStorage and RestfulApiEndpoint', () {
    setUp(() {
      database = TestDatabase(VmDatabase.memory());
    });

    test('Test outdated local data case', () async {
      /// Run the sync
      final result = await localOutdatedDataSync(database, false);
      expect(result, isNotNull);

      /// Validate the synced entities
      final entities = await database.getTestMoorEntities();
      expect(entities, isNotNull);
      expect(entities.length, equals(3));

      /// Validate that entity with id == 1 has updated name
      expect(entities[0].uuid, equals('00000000-0000-0000-0000-000000000001'));
      expect(entities[0].id, equals(1));
      expect(entities[0].name, equals('UpdatedTestName'));
      expect(entities[0].shouldSync, equals(false));

      /// DateTime fields lose subsecond precision in moor
      expect(entities[0].created, equals(DateTime(2020, 8, 7, 12, 45, 15)));

      /// Validate that entity with id == 2 is as expected
      expect(entities[1].uuid, equals('00000000-0000-0000-0000-000000000002'));
      expect(entities[1].id, equals(2));
      expect(entities[1].name, equals('TestName'));
      expect(entities[1].created, equals(DateTime(2020, 8, 7, 12, 30, 15)));
      expect(entities[1].shouldSync, equals(false));

      /// Validate the entity that is not synced due to failure
      expect(entities[2].shouldSync, equals(true));
      expect(entities[2].id, equals(3));
    });

    test('Test outdated local data case with readonly endpoint', () async {
      /// Run the sync
      final result = await localOutdatedDataSync(database, true);
      expect(result, isNotNull);

      /// Validate the synced entities
      final entities = await database.getTestMoorEntities();
      expect(entities, isNotNull);
      expect(entities.length, equals(3));

      /// Validate that entity with id == 1 has updated name
      expect(entities[0].id, equals(1));
      expect(entities[0].name, equals('UpdatedTestName'));
      expect(entities[0].shouldSync, equals(false));

      /// DateTime fields lose subsecond precision in moor
      expect(entities[0].created, equals(DateTime(2020, 8, 7, 12, 45, 15)));

      /// Validate that entity with id == 2 is as expected
      expect(entities[1].id, equals(2));
      expect(entities[1].name, equals('TestName'));
      expect(entities[1].created, equals(DateTime(2020, 8, 7, 12, 30, 15)));
      expect(entities[1].shouldSync, equals(false));

      /// Validate the entity that is not synced due to failure
      expect(entities[2].shouldSync, equals(true));
      expect(entities[2].id, equals(3));
    });

    test('Test syncing multiple entities with partial failure', () async {});

    tearDown(() async {
      await database.close();
    });
  });
}

Future<SyncResult> localOutdatedDataSync(
    TestDatabase database, bool readOnlyEndpoint) async {
  /// Set up the mock client
  final url = 'https://www.example.com/test-entity/';
  final client = MockClient();

  final now = DateTime.now();
  final nowWithoutSubsecondPrecision =
      DateTime(now.year, now.month, now.day, now.hour, now.minute, now.second);
  final postTestEntity = TestMoorEntity(
    id: 1,
    name: 'OutdatedTestName',
    created: nowWithoutSubsecondPrecision,
    shouldSync: true,
  );
  final postTestProxy = TestMoorEntityProxy(
      id: postTestEntity.id,
      name: postTestEntity.name,
      created: postTestEntity.created,
      shouldSync: postTestEntity.shouldSync);
  final postTestSerializer = TestMoorEntitySerializer(instance: postTestProxy);
  final postTestRepresentation = postTestSerializer.toRepresentationString();

  final postFailureTestEntity = TestMoorEntity(
    id: 3,
    name: 'FailedTestName',
    created: nowWithoutSubsecondPrecision.subtract(Duration(days: 31)),
    shouldSync: true,
  );
  final postFailureTestProxy = TestMoorEntityProxy(
    id: postFailureTestEntity.id,
    name: postFailureTestEntity.name,
    created: postFailureTestEntity.created,
    shouldSync: postFailureTestEntity.shouldSync,
  );
  final postFailureTestSerializer = TestMoorEntitySerializer(
    instance: postFailureTestProxy,
  );
  final postFailureTestRepresentation =
      postFailureTestSerializer.toRepresentationString();

  final getResponseBody = '[{'
      '"uuid": "00000000-0000-0000-0000-000000000002", '
      '"id": 2, '
      '"name": "TestName", '
      '"created": "2020-08-07T12:30:15.123456"'
      '}]';
  final postResponseBody = '{'
      '"uuid": "00000000-0000-0000-0000-000000000001", '
      '"id": 1, '
      '"name": "UpdatedTestName", '
      '"created": "2020-08-07T12:45:15.123456"'
      '}';
  final postFailureResponseBody = '{}';

  final statusCode = 200;
  final failureStatusCode = 401;
  final notFoundStatusCode = 400;

  when(client.get(Uri.parse(url)))
      .thenAnswer((a) async => http.Response(getResponseBody, statusCode));
  when(client.get(Uri.parse('${url}1')))
      .thenAnswer((a) async => http.Response(postResponseBody, statusCode));
  when(client.get(Uri.parse('${url}3'))).thenAnswer(
    (a) async => http.Response(
      postFailureResponseBody,
      notFoundStatusCode,
    ),
  );
  when(client.post(Uri.parse(url), body: postTestRepresentation))
      .thenAnswer((a) async => http.Response(postResponseBody, statusCode));
  when(client.post(Uri.parse(url), body: postFailureTestRepresentation))
      .thenAnswer((a) async =>
          http.Response(postFailureResponseBody, failureStatusCode));

  /// Validate that we have zero entities in the db
  var entities = await database.getTestMoorEntities();
  expect(entities, isNotNull);
  expect(entities.length, equals(0));

  /// Pop in one entity
  await database.into(database.testMoorEntities).insert(postTestEntity);
  entities = await database.getTestMoorEntities();
  expect(entities, isNotNull);
  expect(entities.length, equals(1));

  /// Pop in another entity that is expected to fail when being synced
  await database.into(database.testMoorEntities).insert(postFailureTestEntity);
  entities = await database.getTestMoorEntities();
  expect(entities, isNotNull);
  expect(entities.length, equals(2));

  /// Create the endpoint, storage and sync controller
  final endpoint = RestfulApiEndpoint<TestMoorEntityProxy>(
      url, TestMoorEntitySerializer(),
      client: client, readOnly: readOnlyEndpoint, headers: {});
  final factory = TestMoorEntityProxyFactory();
  final storage = MoorStorage<TestMoorEntityProxy>(
      database.testMoorEntities, database, factory);
  final syncController = SyncController<TestMoorEntityProxy>(endpoint, storage);

  /// Perform the sync
  return await syncController.sync();
}
