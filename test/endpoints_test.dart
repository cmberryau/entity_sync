import 'package:test/test.dart';
import 'package:http/http.dart' as http;

import 'package:mockito/mockito.dart';

import 'package:entity_sync/entity_sync.dart';

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

    test('Test RestfulApiEndpoint.pullAll with since parameter', () async {
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

    test('Test RestfulApiEndpoint.pullAll with RestfulApiEndpointPaginator', () async {
      /// Set up the mock client
      final client = MockClient();
      final url = 'https://www.example.com/test-entity/';
      final statusCode = 200;
      final expectedFirstBody =
          '['
            '{"id": 1, "name": "TestNameOne", "created": "2020-08-07T12:30:15.123456"},'
            '{"id": 2, "name": "TestNameTwo", "created": "2020-08-10T12:30:15.123456"},'
            '{"id": 3, "name": "TestNameThree", "created": "2020-08-10T12:30:15.123456"},'
            '{"id": 4, "name": "TestNameFour", "created": "2020-08-10T12:30:15.123456"},'
            '{"id": 5, "name": "TestNameFive", "created": "2020-08-10T12:30:15.123456"},'
            '{"id": 6, "name": "TestNameSix", "created": "2020-08-10T12:30:15.123456"},'
            '{"id": 7, "name": "TestNameSeven", "created": "2020-08-10T12:30:15.123456"},'
            '{"id": 8, "name": "TestNameEight", "created": "2020-08-10T12:30:15.123456"},'
            '{"id": 9, "name": "TestNameNine", "created": "2020-08-10T12:30:15.123456"},'
            '{"id": 10, "name": "TestNameTen", "created": "2020-08-10T12:30:15.123456"}'
          ']';

      final expectedFirstGetUrl = '${url}?offset=0&limit=10';
      when(client.get(expectedFirstGetUrl))
          .thenAnswer((_) async => http.Response(expectedFirstBody, statusCode));

      /// Test the mock client
      var response = await client.get(expectedFirstGetUrl);
      expect(response, isNotNull);
      expect(response, isA<http.Response>());
      expect(response.body, equals(expectedFirstBody));
      expect(response.statusCode, equals(statusCode));

      final expectedSecondBody =
          '['
            '{"id": 11, "name": "TestNameEleven", "created": "2020-08-07T12:30:15.123456"},'
            '{"id": 12, "name": "TestNameTwelve", "created": "2020-08-10T12:30:15.123456"},'
            '{"id": 13, "name": "TestNameThirteen", "created": "2020-08-10T12:30:15.123456"}'
          ']';

      final expectedSecondGetUrl = '${url}?offset=10&limit=10';
      when(client.get(expectedSecondGetUrl))
          .thenAnswer((_) async => http.Response(expectedSecondBody, statusCode));

      /// Test the mock client
      response = await client.get(expectedSecondGetUrl);
      expect(response, isNotNull);
      expect(response, isA<http.Response>());
      expect(response.body, equals(expectedSecondBody));
      expect(response.statusCode, equals(statusCode));

      /// Create the endpoint and an 'outdated' instance
      final serializer = TestEntitySerializer();
      final paginator = RestfulApiPaginator(10);
      final endpoint = RestfulApiEndpoint<TestEntity>(url, serializer,
          client: client, paginator: paginator, headers: null);

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
      expect(result.instances.length, equals(13));

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

      expect(result.instances[2], isNotNull);
      expect(result.instances[2], isA<TestEntity>());
      expect(result.instances[2].id, equals(3));
      expect(result.instances[2].name, equals('TestNameThree'));
      expect(result.instances[2].created,
          DateTime.parse("2020-08-10T12:30:15.123456"));

      expect(result.instances[3], isNotNull);
      expect(result.instances[3], isA<TestEntity>());
      expect(result.instances[3].id, equals(4));
      expect(result.instances[3].name, equals('TestNameFour'));
      expect(result.instances[3].created,
          DateTime.parse("2020-08-10T12:30:15.123456"));

      expect(result.instances[4], isNotNull);
      expect(result.instances[4], isA<TestEntity>());
      expect(result.instances[4].id, equals(5));
      expect(result.instances[4].name, equals('TestNameFive'));
      expect(result.instances[4].created,
          DateTime.parse("2020-08-10T12:30:15.123456"));

      expect(result.instances[5], isNotNull);
      expect(result.instances[5], isA<TestEntity>());
      expect(result.instances[5].id, equals(6));
      expect(result.instances[5].name, equals('TestNameSix'));
      expect(result.instances[5].created,
          DateTime.parse("2020-08-10T12:30:15.123456"));

      expect(result.instances[6], isNotNull);
      expect(result.instances[6], isA<TestEntity>());
      expect(result.instances[6].id, equals(7));
      expect(result.instances[6].name, equals('TestNameSeven'));
      expect(result.instances[6].created,
          DateTime.parse("2020-08-10T12:30:15.123456"));

      expect(result.instances[7], isNotNull);
      expect(result.instances[7], isA<TestEntity>());
      expect(result.instances[7].id, equals(8));
      expect(result.instances[7].name, equals('TestNameEight'));
      expect(result.instances[7].created,
          DateTime.parse("2020-08-10T12:30:15.123456"));

      expect(result.instances[8], isNotNull);
      expect(result.instances[8], isA<TestEntity>());
      expect(result.instances[8].id, equals(9));
      expect(result.instances[8].name, equals('TestNameNine'));
      expect(result.instances[8].created,
          DateTime.parse("2020-08-10T12:30:15.123456"));

      expect(result.instances[9], isNotNull);
      expect(result.instances[9], isA<TestEntity>());
      expect(result.instances[9].id, equals(10));
      expect(result.instances[9].name, equals('TestNameTen'));
      expect(result.instances[9].created,
          DateTime.parse("2020-08-10T12:30:15.123456"));

      expect(result.instances[10], isNotNull);
      expect(result.instances[10], isA<TestEntity>());
      expect(result.instances[10].id, equals(11));
      expect(result.instances[10].name, equals('TestNameEleven'));
      expect(result.instances[10].created,
          DateTime.parse("2020-08-07T12:30:15.123456"));

      expect(result.instances[11], isNotNull);
      expect(result.instances[11], isA<TestEntity>());
      expect(result.instances[11].id, equals(12));
      expect(result.instances[11].name, equals('TestNameTwelve'));
      expect(result.instances[11].created,
          DateTime.parse("2020-08-10T12:30:15.123456"));

      expect(result.instances[12], isNotNull);
      expect(result.instances[12], isA<TestEntity>());
      expect(result.instances[12].id, equals(13));
      expect(result.instances[12].name, equals('TestNameThirteen'));
      expect(result.instances[12].created,
          DateTime.parse("2020-08-10T12:30:15.123456"));
    });
  });
}
