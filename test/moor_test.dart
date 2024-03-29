import 'package:drift/drift.dart' hide isNotNull;
import 'package:entity_sync/entity_sync.dart';
import 'package:entity_sync/moor_sync.dart';
import 'package:http/http.dart' as http;

// ignore: import_of_legacy_library_into_null_safe
import 'package:mockito/mockito.dart';
import 'package:moor/ffi.dart';
import 'package:test/test.dart';
import 'endpoints_test.mocks.dart';
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
      expect(entities.length, equals(4));

      expect(entities[3].id, equals(4));
      expect(entities[3].uuid, equals('00000000-0000-0000-0000-000000000004'));
      expect(entities[3].name, equals('UpdatedTestName'));

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
      expect(entities.length, equals(4));

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

    test('Test storage.isEmpty', () async {
      expect(
        await MoorStorage(
          database.testMoorEntities,
          database,
          TestMoorEntityProxyFactory(),
        ).isEmpty(),
        true,
      );
      await database.into(database.testMoorEntities).insert(
            TestMoorEntitiesCompanion.insert(
              name: 'test1',
              created: DateTime.now(),
            ),
          );

      expect(
        await MoorStorage(
          database.testMoorEntities,
          database,
          TestMoorEntityProxyFactory(),
        ).isEmpty(),
        false,
      );
    });

    test('Test MoorStorage.containsOnlyInstances', () async {
      final defaultInstances = [
        TestMoorEntityProxy(
          created: Value(DateTime.now()),
          name: Value('test'),
          shouldSync: Value(true),
          uuid: Value('39c9499b-4db1-423f-9400-18d43ff1436e'),
        ),
        TestMoorEntityProxy(
          created: Value(DateTime.now()),
          name: Value('test'),
          shouldSync: Value(true),
          uuid: Value('39c9499b-4db1-423f-9400-18d43ff1436d'),
        ),
      ];
      expect(
        await MoorStorage(
          database.testMoorEntities,
          database,
          TestMoorEntityProxyFactory(),
        ).containsOnlyInstances(defaultInstances),
        false,
      );
      await database
          .into(database.testMoorEntities)
          .insert(defaultInstances.first);
      expect(
        await MoorStorage(
          database.testMoorEntities,
          database,
          TestMoorEntityProxyFactory(),
        ).containsOnlyInstances(defaultInstances),
        false,
      );
      await database
          .into(database.testMoorEntities)
          .insert(defaultInstances.last);
      expect(
        await MoorStorage(
          database.testMoorEntities,
          database,
          TestMoorEntityProxyFactory(),
        ).containsOnlyInstances(defaultInstances),
        true,
      );
    });

    tearDown(() async {
      await database.close();
    });
  });
}

Future<SyncResult> localOutdatedDataSync(
  TestDatabase database,
  bool readOnlyEndpoint,
) async {
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
  ).toCompanion(true);
  final postTestProxy = TestMoorEntityProxy(
      id: postTestEntity.id,
      name: postTestEntity.name,
      created: postTestEntity.created,
      shouldSync: postTestEntity.shouldSync);
  final postTestSerializer =
      BaseTestMoorEntitySerializer(instance: postTestProxy);
  final postTestRepresentation = postTestSerializer.toRepresentationString();

  final postTestEntityUpdated = TestMoorEntity(
    id: 4,
    name: 'OutdatedTestName',
    created: nowWithoutSubsecondPrecision,
    shouldSync: true,
    uuid: '00000000-0000-0000-0000-000000000004',
  ).toCompanion(true);
  final postTestProxyUpdated = TestMoorEntityProxy(
    id: postTestEntityUpdated.id,
    name: postTestEntityUpdated.name,
    created: postTestEntityUpdated.created,
    shouldSync: postTestEntityUpdated.shouldSync,
    uuid: postTestEntityUpdated.uuid,
  );
  final postTestSerializerUpdated = BaseTestMoorEntitySerializer(
    instance: postTestProxyUpdated,
  );
  final postTestRepresentationUpdated =
      postTestSerializerUpdated.toRepresentationString();

  final postFailureTestEntity = TestMoorEntity(
    id: 3,
    name: 'FailedTestName',
    created: nowWithoutSubsecondPrecision.subtract(Duration(days: 31)),
    shouldSync: true,
  ).toCompanion(true);
  final postFailureTestProxy = TestMoorEntityProxy(
    id: postFailureTestEntity.id,
    name: postFailureTestEntity.name,
    created: postFailureTestEntity.created,
    shouldSync: postFailureTestEntity.shouldSync,
  );
  final postFailureTestSerializer = BaseTestMoorEntitySerializer(
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
  final postUpdatedResponseBody = '{'
      '"uuid": "00000000-0000-0000-0000-000000000004", '
      '"id": 4, '
      '"name": "UpdatedTestName", '
      '"created": "2020-08-07T12:45:15.123456"'
      '}';
  final postFailureResponseBody = '{}';

  final statusCode = 200;
  final failureStatusCode = 401;
  final notFoundStatusCode = 400;

  when(client.get(Uri.parse(url), headers: {}))
      .thenAnswer((a) async => http.Response(getResponseBody, statusCode));
  when(client.get(Uri.parse('${url}1'), headers: {}))
      .thenAnswer((a) async => http.Response(postResponseBody, statusCode));
  when(client.get(Uri.parse('${url}4'), headers: {}))
      .thenAnswer((a) async => http.Response(postUpdatedResponseBody, statusCode));
  when(client.get(Uri.parse('${url}3'), headers: {})).thenAnswer(
    (a) async => http.Response(
      postFailureResponseBody,
      notFoundStatusCode,
    ),
  );
  when(client.post(Uri.parse(url), body: postTestRepresentation, headers: {}))
      .thenAnswer((a) async => http.Response(postResponseBody, statusCode));
  when(client.post(Uri.parse(url),
          body: postTestRepresentationUpdated, headers: {}))
      .thenAnswer(
          (a) async => http.Response(postUpdatedResponseBody, statusCode));
  when(client.post(
    Uri.parse(url),
    body: postFailureTestRepresentation,
    headers: {},
  )).thenAnswer(
    (a) async => http.Response(
      postFailureResponseBody,
      failureStatusCode,
    ),
  );

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

  await database.into(database.testMoorEntities).insert(postTestEntityUpdated);
  entities = await database.getTestMoorEntities();
  expect(entities, isNotNull);
  expect(entities.length, equals(3));

  /// Create the endpoint, storage and sync controller
  final endpoint = RestfulApiEndpoint<TestMoorEntityProxy>(
      url, BaseTestMoorEntitySerializer(),
      client: client, readOnly: readOnlyEndpoint, headers: {});
  final factory = TestMoorEntityProxyFactory();
  final storage = MoorStorage<TestMoorEntityProxy>(
      database.testMoorEntities, database, factory);
  final syncController = SyncController<TestMoorEntityProxy>(endpoint, storage);

  /// Perform the sync
  return await syncController.sync();
}
