import 'package:universal_io/io.dart';

abstract class Response<T> {
  T get response;

  set statusCode(int value);

  void setHeader(String name, Object value);

  String? getHeader(String name);

  set contentType(ContentType? value);

  void add(List<int> data);

  Future addStream(Stream<List<int>> stream);

  void write(Object? object);

  Future flush() async {}

  Future close() async {}
}
