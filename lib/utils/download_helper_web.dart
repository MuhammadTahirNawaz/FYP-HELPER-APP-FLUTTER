// Web implementation using package:web.
import 'dart:js_interop';
import 'package:web/web.dart' as web;

Future<void> saveFile(String filename, String content, {String mime = 'text/csv'}) async {
  final encoded = Uri.encodeComponent(content);
  final dataUrl = 'data:$mime;charset=utf-8,$encoded'.toJS;
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  anchor
    ..href = dataUrl.toDart
    ..download = filename
    ..style.display = 'none';

  web.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
}
