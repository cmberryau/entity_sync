import 'dart:convert';
import 'dart:io';

import 'package:entity_sync/src/interceptors.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:http/io_client.dart';

const FAILED_HTTP_ERROR_CODE_THRESHOLD = 300;

class EntitySyncHttpClient extends http.BaseClient {
  http.Client _client = IOClient(HttpClient());
  Interceptor interceptor;

  EntitySyncHttpClient(
      {this.interceptor = const Interceptor(), http.Client? client}) {
    if (client != null) {
      _client = client;
    }
  }

  @override
  Future<Response> head(Uri url, {Map<String, String>? headers}) async {
    final response = await super.head(url, headers: headers);
    final interceptedRes = await interceptor.onResponse(response);

    _checkStatusCode(interceptedRes);

    return interceptedRes;
  }

  @override
  Future<Response> get(Uri url, {Map<String, String>? headers}) async {
    final response = await super.get(url, headers: headers);
    final interceptedRes = await interceptor.onResponse(response);

    _checkStatusCode(interceptedRes);

    return interceptedRes;
  }

  @override
  Future<Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final response = await super.post(
      url,
      headers: headers,
      body: body,
      encoding: encoding,
    );
    final interceptedRes = await interceptor.onResponse(response);

    _checkStatusCode(interceptedRes);

    return interceptedRes;
  }

  @override
  Future<Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final response = await super.put(
      url,
      headers: headers,
      body: body,
      encoding: encoding,
    );
    final interceptedRes = await interceptor.onResponse(response);

    _checkStatusCode(interceptedRes);

    return interceptedRes;
  }

  @override
  Future<Response> patch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final response = await super.patch(
      url,
      headers: headers,
      body: body,
      encoding: encoding,
    );
    final interceptedRes = await interceptor.onResponse(response);

    _checkStatusCode(interceptedRes);

    return interceptedRes;
  }

  @override
  Future<Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final response = await super.delete(
      url,
      headers: headers,
      body: body,
      encoding: encoding,
    );
    final interceptedRes = await interceptor.onResponse(response);

    _checkStatusCode(interceptedRes);

    return interceptedRes;
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    try {
      final response = await _client.send(await interceptor.onRequest(request));

      return response;
    } on Error catch (e) {
      await interceptor.onError(e);
      rethrow;
    } on Exception catch (e) {
      await interceptor.onException(e);
      rethrow;
    }
  }

  @override
  void close() {
    _client.close();
  }

  void _checkStatusCode(Response interceptedRes) {
    if (interceptedRes.statusCode > FAILED_HTTP_ERROR_CODE_THRESHOLD) {
      final failedMessageString = 'Response is ${interceptedRes.statusCode}';

      interceptor.onException(
        HttpExceptionWithResponse(failedMessageString, interceptedRes),
      );
    }
  }
}

class HttpExceptionWithResponse extends HttpException {
  final Response response;

  HttpExceptionWithResponse(String message, this.response) : super(message);
}
