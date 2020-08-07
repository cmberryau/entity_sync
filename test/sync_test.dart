import 'package:test/test.dart';

import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

import 'package:entity_sync/src/sync.dart';
import 'serialization_test.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  group('Test RestfulApiSyncEndpoint', () {
    setUp(() {

    });

    test('Test RestfulApiSyncEndpoint.pull', () async {
      /// Set up the mock client
      final client = MockClient();
      final url = 'https://www.example.com/test-entity';
      final body = '{"id": 1, "name": "TestName", "created": "2020-08-07T12:30:15.123456"}';
      final statusCode = 200;
      when(client.get('${url}/1')).thenAnswer((_) async => http.Response(body, statusCode));

      /// Test the mock client
      final response = await client.get('${url}/1');
      expect(response, isNotNull);
      expect(response, isA<http.Response>());
      expect(response.body, equals(body));
      expect(response.statusCode, equals(statusCode));

      /// Create the endpoint and an 'outdated' instance
      final endpoint = RestfulApiEndpoint<TestEntity>(url, client: client);
      final instance = TestEntity(1, 'OutdatedName', DateTime.now());
      final serializer = TestEntitySerializer();

      /// Pull the entity using the endpoint
      final result = await endpoint.pull(instance, serializer);

      /// Test the results of pulling the entity
      expect(result, isNotNull);
      expect(result, isA<EndpointResult>());
      expect(result.response, isNotNull);
      expect(result.response, isA<http.Response>());
      expect(result.response.statusCode, equals(200));

      expect(result.instance, isNotNull);
      expect(result.instance, isA<TestEntity>());
      expect(result.instance.id, equals(1));
      expect(result.instance.name, equals('TestName'));
      expect(result.instance.created, DateTime.parse("2020-08-07T12:30:15.123456"));
    });

    test('Test RestfulApiSyncEndpoint.push', () async {
      /// Set up the mock client
      final client = MockClient();
      final url = 'https://www.example.com/test-entity';
      final body = '{"id": 1, "name": "TestName", "created": "2020-08-07T12:30:15.123456"}';
      final statusCode = 200;

      /// Create the endpoint and an 'outdated' instance
      final endpoint = RestfulApiEndpoint<TestEntity>(url, client: client);
      final instance = TestEntity(1, 'OutdatedName', DateTime.now());
      final mockTestSerializer = TestEntitySerializer(instance:instance);

      when(client.post('${url}/1', body:mockTestSerializer.toRepresentation()))
          .thenAnswer((_) async => http.Response(body, statusCode));

      /// Pull the entity using the endpoint
      final serializer = TestEntitySerializer();
      final result = await endpoint.push(instance, serializer);

      /// Test the results of pulling the entity
      expect(result, isNotNull);
      expect(result, isA<EndpointResult>());
      expect(result.response, isNotNull);
      expect(result.response, isA<http.Response>());
      expect(result.response.statusCode, equals(200));

      expect(result.instance, isNotNull);
      expect(result.instance, isA<TestEntity>());
      expect(result.instance.id, equals(1));
      expect(result.instance.name, equals('TestName'));
      expect(result.instance.created, DateTime.parse("2020-08-07T12:30:15.123456"));
    });
  });
}
