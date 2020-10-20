import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import 'paginators.dart';
import 'serialization.dart';
import 'sync.dart';

/// Represents the result of an operation with an endpoint
class EndpointResult<TSyncable extends SyncableMixin> {
  http.Response response;
  List<TSyncable> instances;

  EndpointResult(this.response, this.instances);

  /// Was the endpoint operation successful?
  bool get successful =>
      response.statusCode >= 200 && response.statusCode < 300;
}

/// Represents an entity endpoint
/// Responsible for pulling & pushing entities
abstract class Endpoint<TSyncable extends SyncableMixin> {
  final Serializer<TSyncable> serializer;
  final bool readOnly;

  Endpoint(this.serializer, {this.readOnly = false});

  /// Pushes a single entity and returns any updates
  Future<EndpointResult<TSyncable>> push(instance, [serializer]) async {
    serializer = _getSerializer(serializer);

    /// Get the representation of the instance
    serializer.instance = instance;
    final body = serializer.toRepresentation();

    return pushJson(body, serializer, true);
  }

  /// Pushes a single entity that is already encoded in json
  Future<EndpointResult<TSyncable>> pushJson(Map<String, dynamic> data,
      [serializer, skipValidation = false]);

  /// Pulls and returns a single entity
  Future<EndpointResult<TSyncable>> pull(TSyncable instance,
      [Serializer<TSyncable> serializer]);

  /// Pulls and returns multiple entities
  Future<EndpointResult<TSyncable>> pullAll({
    Serializer<TSyncable> serializer,
    DateTime since,
  });

  Serializer<SyncableMixin> _getSerializer(
      Serializer<SyncableMixin> serializer) {
    if (serializer == null) {
      return this.serializer;
    }

    return serializer;
  }
}

/// Represents a restful api endpoint
class RestfulApiEndpoint<TSyncable extends SyncableMixin>
    extends Endpoint<TSyncable> {
  final String url;
  final Map<String, String> headers;
  http.Client client;
  static const String ModifiedKeyDefault = 'modified';
  String modifiedKey;
  final Paginator paginator;

  RestfulApiEndpoint(this.url, serializer,
      {http.Client client,
      modifiedKey,
      this.paginator,
      readOnly = false,
      this.headers = const {}})
      : super(serializer, readOnly: readOnly) {
    this.client = client ??= http.Client();
    this.modifiedKey = modifiedKey ??= ModifiedKeyDefault;
  }

  @override
  Future<EndpointResult<TSyncable>> pushJson(Map<String, dynamic> data,
      [serializer, skipValidation = false]) async {
    serializer = _getSerializer(serializer);

    /// Validate the incoming data
    serializer.instance = null;
    serializer.data = data;

    if (!skipValidation && !serializer.isValid()) {
      throw ArgumentError('Invalid json provided');
    }

    try {
      final representation =
          serializer.toRepresentationString(skipValidation: skipValidation);
      final response =
          await client.post(url, headers: headers, body: representation);

      TSyncable instance;
      if (response.statusCode == 200 || response.statusCode == 201) {
        instance = _responseToInstance(serializer, response);
      }
      return EndpointResult<TSyncable>(response, [instance]);
    } on HttpException catch (e) {
      print(e);
      rethrow;
    }
  }

  @override
  Future<EndpointResult<TSyncable>> pull(instance, [serializer]) async {
    serializer = _getSerializer(serializer);

    try {
      final response =
          await client.get(_instanceUrl(instance), headers: headers);
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
  Future<EndpointResult<TSyncable>> pullAll({
    Serializer<SyncableMixin> serializer,
    DateTime since}) async {
    serializer = _getSerializer(serializer);

    // if we have a paginator, use it
    if (paginator != null) {
      // clone the paginator for local use
      final localPaginator = paginator.clone();
      // get the initial set of instances
      var result = await _pullAll(serializer, localPaginator);
      // cache the initial response
      var response = result.response;
      var instances = result.instances;

      while(result.instances.isNotEmpty) {
        // move to the next page
        localPaginator.next();
        // get the next set of instances
        result = await _pullAll(serializer, localPaginator, since);
        // response should remain the same
        if (result.response != response) {
          throw UnimplementedError();
        }
        // extend the instances list
        instances = instances + result.instances;
      }

      return EndpointResult<TSyncable>(response, instances);
    } else {
      // otherwise, just do a normal pull
      return _pullAll(serializer, null, since);
    }
  }

  Future<EndpointResult<TSyncable>> _pullAll(Serializer serializer,
      [Paginator paginator, DateTime since]) async {
    try {
      final finalUrl = '${url}${paginator == null ? '' : paginator.params()}';

      final response = await client.get(
          _makeSinceUrl(finalUrl, since),
          headers: headers
      );

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

  List<TSyncable> _responseToInstances(
      Serializer<SyncableMixin> serializer, http.Response response) {
    /// Swap out the serializer to use the incoming data
    serializer.instance = null;
    dynamic instancesData = json.decode(response.body);
    final instances = <TSyncable>[];
    // TODO: This is a temprorarily patch. Need to have a custom mapping.
    if (!(instancesData is List)) {
      instancesData = instancesData['results'];
    }
    for (var instanceData in instancesData) {
      serializer.data = instanceData;

      /// If the serializer is valid
      if (serializer.isValid()) {
        instances.add(serializer.toInstance());
      }
    }

    return instances;
  }

  SyncableMixin _responseToInstance(
      Serializer<SyncableMixin> serializer, http.Response response) {
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
    return '${url}${instance.getKeyRepresentation()}';
  }

  String _makeSinceUrl(url, DateTime since) {
    if (since == null) {
      return url;
    }
    return '${url}?modified__gt=${Uri.encodeComponent(since.toIso8601String())}';
  }
}

class EntitySyncHttpClient extends http.BaseClient {
  http.Client _client;
  Interceptor interceptor;

  EntitySyncHttpClient({this.interceptor, http.Client client}) {
    interceptor ??= Interceptor();
    _client = client ?? IOClient(HttpClient());
  }

  @override
  Future<http.Response> head(url, {Map<String, String> headers}) async {
    final response = await super.head(url, headers: headers);
    return await interceptor.onResponse(response);
  }

  @override
  Future<http.Response> get(url, {Map<String, String> headers}) async {
    final response = await super.get(url, headers: headers);
    return await interceptor.onResponse(response);
  }

  @override
  Future<http.Response> post(url,
      {Map<String, String> headers, body, Encoding encoding}) async {
    final response =
        await super.post(url, headers: headers, body: body, encoding: encoding);
    return await interceptor.onResponse(response);
  }

  @override
  Future<http.Response> put(url,
      {Map<String, String> headers, body, Encoding encoding}) async {
    final response =
        await super.put(url, headers: headers, body: body, encoding: encoding);
    return await interceptor.onResponse(response);
  }

  @override
  Future<http.Response> patch(url,
      {Map<String, String> headers, body, Encoding encoding}) async {
    final response = await super
        .patch(url, headers: headers, body: body, encoding: encoding);
    return await interceptor.onResponse(response);
  }

  @override
  Future<http.Response> delete(url, {Map<String, String> headers}) async {
    final response = await super.delete(url, headers: headers);
    return await interceptor.onResponse(response);
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    try {
      final response = await _client.send(await interceptor.onRequest(request));

      return response;
    } catch (err) {
      await interceptor.onError(err);

      rethrow;
    }
  }

  @override
  void close() {
    _client.close();
  }
}

class Interceptor {
  Future<http.Request> onRequest(http.Request request) async {
    return request;
  }

  Future<http.Response> onResponse(http.Response response) async {
    return response;
  }

  Future onError(Error error) async {}
}
