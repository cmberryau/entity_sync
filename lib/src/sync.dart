import 'dart:io';
import 'dart:mirrors';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'serialization.dart';

/// Represents the result of an operation with an endpoint
class EndpointResult<TSyncable extends SyncableMixin> {
  http.Response response;
  TSyncable instance;

  EndpointResult(this.response, this.instance);
}

/// Represents an entity endpoint
/// Responsible for pulling & pushing entities
abstract class Endpoint<TSyncable extends SyncableMixin> {
  /// Pushes a single entity and returns any updates
  Future<EndpointResult<TSyncable>> push(TSyncable instance,
      Serializer<TSyncable> serializer);

  /// Pulls and returns a single entity
  Future<EndpointResult<TSyncable>> pull(TSyncable instance,
      Serializer<TSyncable> serializer);
}

/// Represents a restful api endpoint
class RestfulApiEndpoint<TSyncable extends SyncableMixin> extends Endpoint {
  final String url;
  http.Client client;

  RestfulApiEndpoint(this.url, {http.Client client}) {
    this.client = client ??= http.Client();
  }

  @override
  Future<EndpointResult<TSyncable>> push(instance, serializer) async {
    /// Get the representation of the instance
    serializer.instance = instance;
    final body = serializer.toRepresentation();

    try {
      final response = await client.post(url, body: body);

      if (response.statusCode == 200) {
        instance = _responseToInstance(serializer, response, instance);
      }
      return EndpointResult<TSyncable>(response, instance);

    } on HttpException catch(e) {
      print(e);
      rethrow;
    }
  }

  @override
  Future<EndpointResult<TSyncable>> pull(instance, serializer) async {
    try {
      final response = await client.get(_instanceUrl(instance));

      if (response.statusCode == 200) {
        instance = _responseToInstance(serializer, response, instance);
      }
      return EndpointResult<TSyncable>(response, instance);

    } on HttpException catch (e) {
      print(e);
      rethrow;
    }
  }

  SyncableMixin _responseToInstance(Serializer<SyncableMixin> serializer,
      http.Response response, SyncableMixin instance) {
    /// Swap out the serializer to use the incoming data
    serializer.instance = null;
    serializer.data = json.decode(response.body);

    /// If the serializer is valid
    if (serializer.isValid()) {
      instance = serializer.toInstance();
    } else {
      instance = null;
    }

    return instance;
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