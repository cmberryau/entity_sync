import 'dart:convert';

import 'package:entity_sync/entity_sync.dart';
import 'package:entity_sync/moor_sync.dart';
import 'package:mockito/mockito.dart';
import 'package:moor/ffi.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;

import 'endpoints_test.mocks.dart';
import 'models/database.dart';
import 'models/related_entities.dart';

void main() {
  late TestDatabase database;
  late MockClient client;

  final firstRelatedUrl = 'https://www.example.com/first-related-entity/';
  final secondRelatedUrl = 'https://www.example.com/second-related-entity/';

  group('Test SyncController.sync with related entities', () {
    setUp(() {
      database = TestDatabase(VmDatabase.memory());
      client = MockClient();

      final statusCode = 200;

      final secondRelatedResponseBody1 = json.encode({
        'id': 1,
        'uuid': '1',
      });
      final secondRelatedResponseBody2 = json.encode({
        'id': 2,
        'uuid': '2',
      });
      when(client.get(Uri.parse('${secondRelatedUrl}1'), headers: {}))
          .thenAnswer(
        (a) async => http.Response(
          secondRelatedResponseBody1,
          statusCode,
        ),
      );
      when(client.get(Uri.parse('${secondRelatedUrl}2'), headers: {}))
          .thenAnswer(
        (a) async => http.Response(
          secondRelatedResponseBody2,
          statusCode,
        ),
      );

      final firstRelatedResponseBody = json.encode([
        {'id': 1, 'uuid': '1', 'relatedEntity': '1'},
        {'id': 2, 'uuid': '2', 'relatedEntity': '2'}
      ]);
      when(client.get(Uri.parse(firstRelatedUrl), headers: {})).thenAnswer(
        (realInvocation) async => http.Response(
          firstRelatedResponseBody,
          statusCode,
        ),
      );
    });

    test(
      'Test pulling remote data case with empty related entities',
      () async {
        final endpoint = RestfulApiEndpoint<FirstRelatedEntityProxy>(
            firstRelatedUrl, BaseFirstRelatedEntitySerializer(),
            client: client, readOnly: true, headers: {});
        final factory = FirstRelatedEntityProxyFactory();
        final storage = MoorStorage<FirstRelatedEntityProxy>(
          database.firstRelatedEntities,
          database,
          factory,
        );

        final secondEndpoint = RestfulApiEndpoint<SecondRelatedEntityProxy>(
            secondRelatedUrl, BaseSecondRelatedEntitySerializer(),
            client: client, readOnly: true, headers: {});
        final secondFactory = SecondRelatedEntityProxyFactory();
        final secondStorage = MoorStorage<SecondRelatedEntityProxy>(
          database.secondRelatedEntities,
          database,
          secondFactory,
        );

        final firstRelation = MoorRelation(
          database,
          'relatedEntity',
          database.secondRelatedEntities,
        );
        final syncController = SyncController<FirstRelatedEntityProxy>(
          endpoint,
          storage,
          relations: [
            SyncControllerRelation(firstRelation, secondEndpoint, secondStorage)
          ],
        );
        await syncController.sync();

        final secondRelatedEntities =
            await database.select(database.secondRelatedEntities).get();
        expect(secondRelatedEntities.length, 2);
      },
    );
  });
}
