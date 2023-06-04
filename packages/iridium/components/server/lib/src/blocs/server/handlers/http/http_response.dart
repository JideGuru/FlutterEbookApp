import 'package:mno_server/mno_server.dart';
import 'package:universal_io/io.dart' as io;

class HttpResponse extends Response<io.HttpResponse> {
  @override
  io.HttpResponse response;

  HttpResponse(this.response);

  @override
  set statusCode(int value) => response.statusCode = value;

  @override
  void add(List<int> data) => response.add(data);

  @override
  Future addStream(Stream<List<int>> stream) => response.addStream(stream);

  @override
  void write(Object? object) => response.write(object);

  @override
  set contentType(io.ContentType? value) =>
      response.headers.contentType = value;

  @override
  void setHeader(String name, Object value) =>
      response.headers.add(name, value);

  @override
  String? getHeader(String name) => response.headers.value(name);

  @override
  Future flush() => response.flush();

  @override
  Future close() => response.close();
}
