import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import 'package:entity_sync/src/interceptors.dart';

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
}
