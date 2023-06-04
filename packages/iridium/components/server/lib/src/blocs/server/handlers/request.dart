import 'package:mno_server/mno_server.dart';

abstract class Request<T extends Response> {
  Uri get uri;

  T get response;

  String? getHeader(String name);
}
