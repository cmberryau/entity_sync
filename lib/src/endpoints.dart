import 'dart:convert';
import 'dart:io';

import 'package:entity_sync/entity_sync.dart';
import 'package:entity_sync/src/paginators.dart';
import 'package:entity_sync/src/serialization.dart';
import 'package:entity_sync/src/sync.dart';
import 'package:http/http.dart' as http;

/// Represents the result of an operation with an endpoint
class EndpointResult<TSyncable extends SyncableMixin> {
  final http.Response response;
  final List<TSyncable> instances;
  final List<Exception> errors = [];

  EndpointResult(this.response, this.instances);

  void addError(Exception exception) => errors.add(exception);

  /// Was the endpoint operation successful?
  bool get successful =>
      response.statusCode >= 200 && response.statusCode < 300 && errors.isEmpty;
}

/// Represents an entity endpoint
/// Responsible for pulling & pushing entities
abstract class Endpoint<TSyncable extends SyncableMixin> {
  final Serializer<TSyncable> serializer;
  final bool readOnly;

  Endpoint(this.serializer, {this.readOnly = false});

  /// Pushes a single entity and returns any updates
  Future<EndpointResult<TSyncable>> push(TSyncable instance) async {
    /// Get the representation of the instance
    serializer.instance = instance;
    final body = serializer.toRepresentation();

    return pushJson(body, skipValidation: true);
  }

  /// Pushes a single entity that is already encoded in json
  Future<EndpointResult<TSyncable>> pushJson(
    Map<String, dynamic> data, {
    bool skipValidation = false,
  });

  /// Pulls and returns a single entity
  Future<EndpointResult<TSyncable>> pull(TSyncable instance);

  /// Pulls and returns multiple entities
  Future<EndpointResult<TSyncable>> pullAll({DateTime? since});

  Future<EndpointResult<TSyncable>> pullOneByRemoteKey({
    required String remoteKey,
  });
}

/// Represents a restful api endpoint
class RestfulApiEndpoint<TSyncable extends SyncableMixin>
    extends Endpoint<TSyncable> {
  final String url;
  final Map<String, String> headers;
  final http.Client client;
  final Paginator? paginator;

  RestfulApiEndpoint(
    this.url,
    Serializer<TSyncable> serializer, {
    required this.client,
    this.paginator,
    readOnly = false,
    this.headers = const {},
  }) : super(
          serializer,
          readOnly: readOnly,
        );

  @override
  Future<EndpointResult<TSyncable>> pushJson(
    Map<String, dynamic> data, {
    bool skipValidation = false,
  }) async {
    /// Validate the incoming data
    serializer.instance = null;
    serializer.data = data;

    if (!skipValidation && !serializer.isValid()) {
      throw ArgumentError('Invalid json provided');
    }

    final representation = serializer.toRepresentationString(
      skipValidation: skipValidation,
    );
    final response = await client.post(
      Uri.parse(url),
      headers: headers,
      body: representation,
    );

    final result = EndpointResult<TSyncable>(response, []);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final instance = _responseToInstance(serializer, response);

      if (instance != null) {
        result.instances.add(instance);

        return result;
      }

      result.addError(
        HttpException('Response is ok but push instance is null'),
      );
    }

    result.addError(HttpException('Response status code is not 200 or 201.'));

    return result;
  }

  @override
  Future<EndpointResult<TSyncable>> pull(instance) async {
    final response = await client.get(_instanceUri(instance), headers: headers);

    final result = EndpointResult<TSyncable>(response, []);

    if (response.statusCode == 200) {
      final pulledInstance = _responseToInstance(serializer, response);
      if (pulledInstance != null) {
        result.instances.add(pulledInstance);

        return result;
      }

      result.addError(
        HttpException('Response is 200 but pulled instance is null'),
      );
    }

    result.addError(HttpException('Response is not 200.'));

    return result;
  }

  @override
  Future<EndpointResult<TSyncable>> pullAll({DateTime? since}) async {
    // if we have a paginator, use it
    final paginator = this.paginator;
    if (paginator != null) {
      // clone the paginator for local use
      final localPaginator = paginator.clone();
      // get the initial set of instances
      var result = await _pullAll(paginator: localPaginator, since: since);
      // cache the initial response
      var statusCode = result.response.statusCode;
      var instances = result.instances;

      while (result.instances.isNotEmpty &&
          result.instances.length == localPaginator.pageSize) {
        // move to the next page
        localPaginator.next();
        // get the next set of instances
        result = await _pullAll(paginator: localPaginator, since: since);

        // response should remain the same
        if (result.response.statusCode != statusCode) {
          final endpointResult = EndpointResult<TSyncable>(
            result.response,
            instances,
          );
          endpointResult.addError(
            HttpException('Response should remain the same when paginating.'),
          );
        }

        // extend the instances list
        instances = instances + result.instances;
      }

      return EndpointResult<TSyncable>(result.response, instances);
    } else {
      // otherwise, just do a normal pull
      return _pullAll(since: since);
    }
  }

  Future<EndpointResult<TSyncable>> _pullAll({
    Paginator? paginator,
    DateTime? since,
  }) async {
    // form the url
    var finalUrl = url;
    if (since != null) {
      finalUrl = '$finalUrl?${_sinceSnippet(since)}';

      if (paginator != null) {
        finalUrl = '$finalUrl&${paginator.params()}';
      }
    } else {
      if (paginator != null) {
        finalUrl = '$finalUrl?${paginator.params()}';
      }
    }

    final response = await client.get(Uri.parse(finalUrl), headers: headers);

    if (response.statusCode == 200) {
      final instances = _responseToInstances(serializer, response);
      return EndpointResult<TSyncable>(response, instances);
    }

    final result = EndpointResult<TSyncable>(response, []);
    result.addError(HttpException('Response is not 200'));

    return result;
  }

  List<TSyncable> _responseToInstances(
      Serializer<TSyncable> serializer, http.Response response) {
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
        final instance = serializer.toInstance();
        if (instance != null) {
          instances.add(instance);
        }
      }
    }

    return instances;
  }

  TSyncable? _responseToInstance(
      Serializer<TSyncable> serializer, http.Response response) {
    /// Swap out the serializer to use the incoming data
    serializer.instance = null;
    serializer.data = json.decode(response.body);

    /// If the serializer is valid
    if (serializer.isValid()) {
      return serializer.toInstance();
    }

    return null;
  }

  Uri _instanceUri(TSyncable instance) {
    return Uri.parse('$url${instance.getKeyRepresentation()}');
  }

  Uri _uriFromRemoteKey(String remoteKey) {
    return Uri.parse('$url$remoteKey}');
  }

  String _sinceSnippet(DateTime since) {
    return 'modified__gt=${Uri.encodeComponent(since.toIso8601String())}';
  }

  @override
  Future<EndpointResult<TSyncable>> pullOneByRemoteKey({
    required String remoteKey,
  }) async {
    final response = await client.get(
      _uriFromRemoteKey(remoteKey),
      headers: headers,
    );

    final instance = _responseToInstance(serializer, response);

    final result = EndpointResult<TSyncable>(response, []);

    if (instance != null) {
      result.instances.add(instance);
    }

    return result;
  }
}
