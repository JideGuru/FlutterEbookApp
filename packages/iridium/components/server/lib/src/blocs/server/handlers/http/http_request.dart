import 'package:mno_server/mno_server.dart';
import 'package:universal_io/io.dart' as io;

class HttpRequest extends Request<HttpResponse> {
  io.HttpRequest request;

  HttpRequest(this.request);

  @override
  Uri get uri => request.uri;

  @override
  HttpResponse get response => HttpResponse(request.response);

  @override
  String? getHeader(String name) => request.headers.value(name);
}
