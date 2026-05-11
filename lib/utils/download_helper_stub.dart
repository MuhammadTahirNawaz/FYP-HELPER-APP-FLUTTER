// Non-web implementation: use file_selector to pick save path and dart:io to write
import 'dart:io' as io;
import 'package:file_selector/file_selector.dart';

Future<void> saveFile(String filename, String content, {String mime = 'text/csv'}) async {
  final location = await getSaveLocation(suggestedName: filename);
  if (location == null) return;
  final file = io.File(location.path);
  await file.writeAsString(content);
}
