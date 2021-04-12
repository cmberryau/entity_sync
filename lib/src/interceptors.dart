import 'package:http/http.dart' as http;

class Interceptor {
  const Interceptor();

  Future<http.BaseRequest> onRequest(http.BaseRequest request) async {
    return request;
  }

  Future<http.Response> onResponse(http.Response response) async {
    return response;
  }

  Future onError(Error error) async {}

  Future onException(Exception exception) async {}
}
