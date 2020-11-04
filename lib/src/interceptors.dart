import 'package:http/http.dart' as http;

class Interceptor {
  Future<http.Request> onRequest(http.Request request) async {
    return request;
  }

  Future<http.Response> onResponse(http.Response response) async {
    return response;
  }

  Future onError(Error error) async {}
}
