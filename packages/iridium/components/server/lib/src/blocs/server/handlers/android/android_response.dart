import 'dart:typed_data';

import 'package:dfunc/dfunc.dart';
import 'package:mno_webview/webview.dart';
import 'package:mno_server/mno_server.dart';
import 'package:universal_io/io.dart' as io;
import 'package:universal_io/io.dart';

class AndroidResponse extends Response<WebResourceResponse> {
  @override
  WebResourceResponse response;

  AndroidResponse()
      : response = WebResourceResponse(
          statusCode: HttpStatus.ok,
          reasonPhrase: HttpStatus.ok.findReasonPhrase(),
          headers: {},
        );

  @override
  set statusCode(int value) {
    response.statusCode = value;
    response.reasonPhrase = value.findReasonPhrase();
  }

  @override
  void add(List<int> data) {
    if (data is Uint8List) {
      response.data = data;
    } else {
      response.data = Uint8List.fromList(data);
    }
  }

  @override
  Future addStream(Stream<List<int>> stream) =>
      stream.toList().then((dataArray) {
        List<int> allData = [];
        for (List<int> data in dataArray) {
          allData.addAll(data);
        }
        response.data = Uint8List.fromList(allData);
      });

  @override
  void write(Object? object) => add(object.toString().codeUnits);

  @override
  set contentType(io.ContentType? value) => value?.let((it) {
        setHeader(HttpHeaders.contentTypeHeader, it.value);
      });

  @override
  void setHeader(String name, Object value) =>
      response.headers![name] = value.toString();

  @override
  String? getHeader(String name) => response.headers![name];
}

extension IntExt on int {
  String findReasonPhrase() {
    switch (this) {
      case HttpStatus.continue_:
        return "Continue";
      case HttpStatus.switchingProtocols:
        return "Switching Protocols";
      case HttpStatus.ok:
        return "OK";
      case HttpStatus.created:
        return "Created";
      case HttpStatus.accepted:
        return "Accepted";
      case HttpStatus.nonAuthoritativeInformation:
        return "Non-Authoritative Information";
      case HttpStatus.noContent:
        return "No Content";
      case HttpStatus.resetContent:
        return "Reset Content";
      case HttpStatus.partialContent:
        return "Partial Content";
      case HttpStatus.multipleChoices:
        return "Multiple Choices";
      case HttpStatus.movedPermanently:
        return "Moved Permanently";
      case HttpStatus.found:
        return "Found";
      case HttpStatus.seeOther:
        return "See Other";
      case HttpStatus.notModified:
        return "Not Modified";
      case HttpStatus.useProxy:
        return "Use Proxy";
      case HttpStatus.temporaryRedirect:
        return "Temporary Redirect";
      case HttpStatus.badRequest:
        return "Bad Request";
      case HttpStatus.unauthorized:
        return "Unauthorized";
      case HttpStatus.paymentRequired:
        return "Payment Required";
      case HttpStatus.forbidden:
        return "Forbidden";
      case HttpStatus.notFound:
        return "Not Found";
      case HttpStatus.methodNotAllowed:
        return "Method Not Allowed";
      case HttpStatus.notAcceptable:
        return "Not Acceptable";
      case HttpStatus.proxyAuthenticationRequired:
        return "Proxy Authentication Required";
      case HttpStatus.requestTimeout:
        return "Request Time-out";
      case HttpStatus.conflict:
        return "Conflict";
      case HttpStatus.gone:
        return "Gone";
      case HttpStatus.lengthRequired:
        return "Length Required";
      case HttpStatus.preconditionFailed:
        return "Precondition Failed";
      case HttpStatus.requestEntityTooLarge:
        return "Request Entity Too Large";
      case HttpStatus.requestUriTooLong:
        return "Request-URI Too Long";
      case HttpStatus.unsupportedMediaType:
        return "Unsupported Media Type";
      case HttpStatus.requestedRangeNotSatisfiable:
        return "Requested range not satisfiable";
      case HttpStatus.expectationFailed:
        return "Expectation Failed";
      case HttpStatus.internalServerError:
        return "Internal Server Error";
      case HttpStatus.notImplemented:
        return "Not Implemented";
      case HttpStatus.badGateway:
        return "Bad Gateway";
      case HttpStatus.serviceUnavailable:
        return "Service Unavailable";
      case HttpStatus.gatewayTimeout:
        return "Gateway Time-out";
      case HttpStatus.httpVersionNotSupported:
        return "Http Version not supported";
      default:
        return "Status $this";
    }
  }
}
