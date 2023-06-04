import 'package:mno_webview/webview.dart';
import 'package:mno_server/mno_server.dart';

class AndroidRequest extends Request<AndroidResponse> {
  WebResourceRequest request;
  AndroidResponse? _response;

  AndroidRequest(this.request);

  @override
  Uri get uri => Uri(
        path: request.url.path,
        query: request.url.query,
        fragment: request.url.fragment.isNotEmpty ? request.url.fragment : null,
      );

  @override
  AndroidResponse get response => _response ??= AndroidResponse();

  @override
  String? getHeader(String name) => request.headers![name];
}
