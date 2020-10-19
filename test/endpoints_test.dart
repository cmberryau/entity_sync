import 'package:entity_sync/entity_sync.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'serialization_test.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  group('Test RestfulApiSyncEndpoint', () {
    setUp(() {});

    test('Test RestfulApiEndpoint.pull', () async {
      /// Set up the mock client
      final client = MockClient();
      final url = 'https://www.example.com/test-entity/';
      final body = '{"id": 1, "name": "TestName", '
          '"created": "2020-08-07T12:30:15.123456"}';
      final statusCode = 200;

      when(client.get('${url}1'))
          .thenAnswer((_) async => http.Response(body, statusCode));

      /// Test the mock client
      final response = await client.get('${url}1');
      expect(response, isNotNull);
      expect(response, isA<http.Response>());
      expect(response.body, equals(body));
      expect(response.statusCode, equals(statusCode));

      /// Create the endpoint and an 'outdated' instance
      final serializer = TestEntitySerializer();
      final endpoint = RestfulApiEndpoint<TestEntity>(url, serializer,
          client: client, headers: null);
      final instance = TestEntity(id: 1, name: 'OutdatedName', created: DateTime.now());

      /// Pull the entity using the endpoint
      final result = await endpoint.pull(instance, serializer);

      /// Test the results of pulling the entity
      expect(result, isNotNull);
      expect(result, isA<EndpointResult>());
      expect(result.response, isNotNull);
      expect(result.response, isA<http.Response>());
      expect(result.response.statusCode, equals(200));

      expect(result.instances, isNotNull);
      expect(result.instances, isA<List<TestEntity>>());
      expect(result.instances.length, equals(1));
      expect(result.instances[0], isNotNull);
      expect(result.instances[0], isA<TestEntity>());
      expect(result.instances[0].id, equals(1));
      expect(result.instances[0].name, equals('TestName'));
      expect(result.instances[0].created,
          DateTime.parse("2020-08-07T12:30:15.123456"));
    });

    test('Test RestfulApiEndpoint.pullAll', () async {
      /// Set up the mock client
      final client = MockClient();
      final url = 'https://www.example.com/test-entity/';
      final body =
          '[{"id": 1, "name": "TestNameOne", "created": "2020-08-07T12:30:15.123456"},'
          '{"id": 2, "name": "TestNameTwo", "created": "2020-08-10T12:30:15.123456"}]';
      final statusCode = 200;
      when(client.get('${url}'))
          .thenAnswer((_) async => http.Response(body, statusCode));

      /// Test the mock client
      final response = await client.get('${url}');
      expect(response, isNotNull);
      expect(response, isA<http.Response>());
      expect(response.body, equals(body));
      expect(response.statusCode, equals(statusCode));

      /// Create the endpoint and an 'outdated' instance
      final serializer = TestEntitySerializer();
      final endpoint = RestfulApiEndpoint<TestEntity>(url, serializer,
          client: client, headers: null);

      /// Pull all entities using the endpoint
      final result = await endpoint.pullAll(
          serializer: serializer
      );

      /// Test the results of pulling the entity
      expect(result, isNotNull);
      expect(result, isA<EndpointResult>());
      expect(result.response, isNotNull);
      expect(result.response, isA<http.Response>());
      expect(result.response.statusCode, equals(200));

      expect(result.instances, isNotNull);
      expect(result.instances, isA<List<TestEntity>>());
      expect(result.instances.length, equals(2));

      expect(result.instances[0], isNotNull);
      expect(result.instances[0], isA<TestEntity>());
      expect(result.instances[0].id, equals(1));
      expect(result.instances[0].name, equals('TestNameOne'));
      expect(result.instances[0].created,
          DateTime.parse("2020-08-07T12:30:15.123456"));

      expect(result.instances[1], isNotNull);
      expect(result.instances[1], isA<TestEntity>());
      expect(result.instances[1].id, equals(2));
      expect(result.instances[1].name, equals('TestNameTwo'));
      expect(result.instances[1].created,
          DateTime.parse("2020-08-10T12:30:15.123456"));
    });

    test('Test RestfulApiEndpoint.push', () async {
      /// Set up the mock client
      final client = MockClient();
      final url = 'https://www.example.com/test-entity/';
      final body =
          '{"id": 1, "name": "TestName", "created": "2020-08-07T12:30:15.123456"}';
      final statusCode = 200;

      /// Create the endpoint and an 'outdated' instance
      final serializer = TestEntitySerializer();
      final endpoint = RestfulApiEndpoint<TestEntity>(url, serializer,
          client: client, headers: null);
      final instance =
          TestEntity(id: 1, name: 'OutdatedName', created: DateTime.now());
      final mockTestSerializer = TestEntitySerializer(instance: instance);

      when(client.post('${url}',
              body: mockTestSerializer.toRepresentationString()))
          .thenAnswer((_) async => http.Response(body, statusCode));

      /// Push the entity using the endpoint
      final result = await endpoint.push(instance, serializer);

      /// Test the results of pulling the entity
      expect(result, isNotNull);
      expect(result.response, isNotNull);
      expect(result.response, isA<http.Response>());
      expect(result.response.statusCode, equals(200));

      expect(result.instances, isNotNull);
      expect(result.instances, isA<List<TestEntity>>());
      expect(result.instances.length, equals(1));
      expect(result.instances[0], isNotNull);
      expect(result.instances[0], isA<TestEntity>());
      expect(result.instances[0].id, equals(1));
      expect(result.instances[0].name, equals('TestName'));
      expect(result.instances[0].created,
          DateTime.parse("2020-08-07T12:30:15.123456"));
    });

    test('Test RestfulApiEndpoint.pullAllSince', () async {
      /// Set up the mock client
      final client = MockClient();
      final url = 'https://www.example.com/test-entity/';
      final body =
          '[{"id": 1, "name": "TestNameOne", "created": "2020-08-07T12:30:15.123456"},'
          '{"id": 2, "name": "TestNameTwo", "created": "2020-08-10T12:30:15.123456"}]';
      final statusCode = 200;
      when(client.get('${url}?modified__gt=2020-01-02T04%3A30%3A45.123456Z'))
          .thenAnswer((_) async => http.Response(body, statusCode));

      /// Test the mock client
      final response = await client
          .get('${url}?modified__gt=2020-01-02T04%3A30%3A45.123456Z');
      expect(response, isNotNull);
      expect(response, isA<http.Response>());
      expect(response.body, equals(body));
      expect(response.statusCode, equals(statusCode));

      /// Create the endpoint and an 'outdated' instance
      final serializer = TestEntitySerializer();
      final endpoint = RestfulApiEndpoint<TestEntity>(url, serializer,
          client: client, headers: null);

      /// Pull all entities using the endpoint
      final since = DateTime.utc(2020, 01, 02, 04, 30, 45, 123, 456);
      final result = await endpoint.pullAll(since: since);

      /// Test the results of pulling the entity
      expect(result, isNotNull);
      expect(result, isA<EndpointResult>());
      expect(result.response, isNotNull);
      expect(result.response, isA<http.Response>());
      expect(result.response.statusCode, equals(200));

      expect(result.instances, isNotNull);
      expect(result.instances, isA<List<TestEntity>>());
      expect(result.instances.length, equals(2));

      expect(result.instances[0], isNotNull);
      expect(result.instances[0], isA<TestEntity>());
      expect(result.instances[0].id, equals(1));
      expect(result.instances[0].name, equals('TestNameOne'));
      expect(result.instances[0].created,
          DateTime.parse("2020-08-07T12:30:15.123456"));

      expect(result.instances[1], isNotNull);
      expect(result.instances[1], isA<TestEntity>());
      expect(result.instances[1].id, equals(2));
      expect(result.instances[1].name, equals('TestNameTwo'));
      expect(result.instances[1].created,
          DateTime.parse("2020-08-10T12:30:15.123456"));
    });
  });
}
