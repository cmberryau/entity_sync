import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'serialization.dart';
import 'sync.dart';

/// Represents the result of an operation with an endpoint
class EndpointResult<TSyncable extends SyncableMixin> {
  http.Response response;
  List<TSyncable> instances;

  EndpointResult(this.response, this.instances);

  /// Was the endpoint operation successful?
  bool get successful => response.statusCode >= 200 && response.statusCode < 300;
}

/// Represents an entity endpoint
/// Responsible for pulling & pushing entities
abstract class Endpoint<TSyncable extends SyncableMixin> {
  final Serializer<TSyncable> serializer;

  Endpoint(this.serializer);

  /// Pushes a single entity and returns any updates
  Future<EndpointResult<TSyncable>> push(instance, [serializer]) async {
    serializer = _getSerializer(serializer);

    /// Get the representation of the instance
    serializer.instance = instance;
    final body = serializer.toRepresentation();

    return pushJson(body, serializer);
  }

  /// Pushes a single entity that is already encoded in json
  Future<EndpointResult<TSyncable>> pushJson(Map<String, dynamic> data,
      [serializer]);

  /// Pulls and returns a single entity
  Future<EndpointResult<TSyncable>> pull(TSyncable instance,
      [Serializer<TSyncable> serializer]);

  /// Pulls and returns a single entity
  Future<EndpointResult<TSyncable>> pullAll([Serializer<TSyncable> serializer]);

  /// Pulls and returns a single entity
  Future<EndpointResult<TSyncable>> pullAllSince([DateTime since,
      Serializer<TSyncable> serializer]);

  Serializer<SyncableMixin> _getSerializer(Serializer<SyncableMixin> serializer) {
    if (serializer == null) {
      return this.serializer;
    }

    return serializer;
  }
}

/// Represents a restful api endpoint
class RestfulApiEndpoint<TSyncable extends SyncableMixin> extends Endpoint<TSyncable> {
  final String url;
  http.Client client;
  static const String ModifiedKeyDefault = 'modified';
  String modifiedKey;

  RestfulApiEndpoint(this.url, serializer, {http.Client client, modifiedKey})
      : super(serializer) {
    this.client = client ??= http.Client();
    this.modifiedKey = modifiedKey ??= ModifiedKeyDefault;
  }

  @override
  Future<EndpointResult<TSyncable>> pushJson(Map<String, dynamic> data,
      [serializer]) async {
    serializer = _getSerializer(serializer);

    /// Validate the incoming data
    serializer.instance = null;
    serializer.data = data;

    if (!serializer.isValid()) {
      throw ArgumentError('Invalid json provided');
    }

    try {
      final representation = serializer.toRepresentationString();
      final response = await client.post(url, body: representation);

      TSyncable instance;
      if (response.statusCode == 200) {
        instance = _responseToInstance(serializer, response);
      }
      return EndpointResult<TSyncable>(response, [instance]);

    } on HttpException catch(e) {
      print(e);
      rethrow;
    }
  }

  @override
  Future<EndpointResult<TSyncable>> pull(instance, [serializer]) async {
    serializer = _getSerializer(serializer);

    try {
      final response = await client.get(_instanceUrl(instance));

      if (response.statusCode == 200) {
        instance = _responseToInstance(serializer, response);
      }
      return EndpointResult<TSyncable>(response, [instance]);

    } on HttpException catch (e) {
      print(e);
      rethrow;
    }
  }

  @override
  Future<EndpointResult<TSyncable>> pullAll([serializer]) async {
    serializer = _getSerializer(serializer);

    try {
      final response = await client.get(url);

      if (response.statusCode == 200) {
        final instances = _responseToInstances(serializer, response);
        return EndpointResult<TSyncable>(response, instances);
      }
      return EndpointResult<TSyncable>(response, []);

    } on HttpException catch (e) {
      print(e);
      rethrow;
    }
  }

  @override
  Future<EndpointResult<TSyncable>> pullAllSince([DateTime since,
      Serializer<SyncableMixin> serializer]) async {
    serializer = _getSerializer(serializer);
    if (since == null) {
      return pullAll(serializer);
    }

    try {
      final response = await client.get(_makeSinceUrl(url, since));

      if (response.statusCode == 200) {
        final instances = _responseToInstances(serializer, response);
        return EndpointResult<TSyncable>(response, instances);
      }
      return EndpointResult<TSyncable>(response, []);

    } on HttpException catch (e) {
      print(e);
      rethrow;
    }
  }

  List<TSyncable> _responseToInstances(Serializer<SyncableMixin> serializer,
      http.Response response) {
    /// Swap out the serializer to use the incoming data
    serializer.instance = null;
    var instancesData = json.decode(response.body);

    final instances = <TSyncable>[];
    for (var instanceData in instancesData) {
      serializer.data = instanceData;

      /// If the serializer is valid
      if (serializer.isValid()) {
        instances.add(serializer.toInstance());
      }
    }

    return instances;
  }

  SyncableMixin _responseToInstance(Serializer<SyncableMixin> serializer,
      http.Response response) {
    /// Swap out the serializer to use the incoming data
    serializer.instance = null;
    serializer.data = json.decode(response.body);

    /// If the serializer is valid
    if (serializer.isValid()) {
      return serializer.toInstance();
    }

    return null;
  }

  String _instanceUrl(TSyncable instance) {
    return '${url}/${instance.getKeyRepresentation()}';
  }

  String _makeSinceUrl(url, DateTime since) {
    return '${url}/?modified__gt=${Uri.encodeComponent(since.toIso8601String())}';
  }
}
