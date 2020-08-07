import 'dart:mirrors';

import 'package:http/http.dart' as http;

import 'serialization.dart';

/// Represents the result of an operation with an endpoint
class EndpointResult<TSyncable extends SyncableMixin> {
  http.Response response;

  EndpointResult(this.response);
}

/// Represents an entity endpoint
/// Responsible for pulling & pushing entities
abstract class Endpoint<TSyncable extends SyncableMixin,
                        TSerializer extends Serializer<TSyncable>> {
  /// Pushes a single entity and returns any updates
  Future<EndpointResult<TSyncable>> push(TSyncable instance);

  /// Pulls and returns a single entity
  Future<EndpointResult<TSyncable>> pull(TSyncable instance);
}

/// Represents a restful api endpoint
class RestfulApiEndpoint<TSyncable extends SyncableMixin,
                         TSerializer extends Serializer<TSyncable>>
    extends Endpoint {
  final String url;
  http.Client client;

  RestfulApiEndpoint(this.url, {http.Client client}) {
    this.client = client ??= http.Client();
  }

  @override
  Future<EndpointResult<TSyncable>> push(instance) async {
    final response = await client.get(_instanceUrl(instance));
    return EndpointResult<TSyncable>(response);
  }

  @override
  Future<EndpointResult<TSyncable>> pull(instance) async {
    final response = await client.get(_instanceUrl(instance));
    return EndpointResult<TSyncable>(response);
  }

  String _instanceUrl(TSyncable instance) {
    return '${url}/${instance.getKeyRepresentation()}';
  }
}

/// Added to a class to support syncing
/// Syncable classes also must be serializable
abstract class SyncableMixin implements SerializableMixin {
  /// Gets the key field of the entity
  SerializableField getKeyField() {
    return reflect(this).getField(Symbol('keyField')).reflectee;
  }

  /// Gets the flag field of the entity
  BoolField getFlagField() {
    return reflect(this).getField(Symbol('flagField')).reflectee;
  }

  /// Gets the key value of the entity
  dynamic getKeyValue(SerializableField keyField) {
    return reflect(this).getField(Symbol(keyField.name)).reflectee;
  }

  /// Gets the flag value of the entity
  bool getFlagValue(BoolField flagField) {
    return reflect(this).getField(Symbol(flagField.name)).reflectee;
  }

  /// Gets the representation of the key of the entity
  dynamic getKeyRepresentation() {
    final keyField = getKeyField();
    final keyValue = getKeyValue(keyField);

    return keyField.toRepresentation(keyValue);
  }

  @override
  dynamic getFieldValue(String fieldName);
}