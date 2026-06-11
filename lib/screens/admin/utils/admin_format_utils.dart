import 'package:url_launcher/url_launcher.dart';

void openAdminDocumentUrl(String url) {
  launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}

String formatAdminBytes(int bytes) {
  const units = ['B', 'KB', 'MB', 'GB', 'TB'];
  var size = bytes.toDouble();
  var unitIndex = 0;
  while (size >= 1024 && unitIndex < units.length - 1) {
    size /= 1024;
    unitIndex += 1;
  }
  final decimals = size < 10 && unitIndex > 0 ? 1 : 0;
  return '${size.toStringAsFixed(decimals)} ${units[unitIndex]}';
}

String formatAdminTimestamp(Object? value) {
  if (value is! int) {
    return 'Unknown';
  }
  final date = DateTime.fromMillisecondsSinceEpoch(value).toLocal();
  final yyyy = date.year.toString().padLeft(4, '0');
  final mm = date.month.toString().padLeft(2, '0');
  final dd = date.day.toString().padLeft(2, '0');
  final hh = date.hour.toString().padLeft(2, '0');
  final min = date.minute.toString().padLeft(2, '0');
  return '$yyyy-$mm-$dd $hh:$min';
}

int adminTimestampToInt(Object? value) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) {
    final i = int.tryParse(value);
    if (i != null) return i;
    final d = double.tryParse(value);
    if (d != null) return d.toInt();
  }
  return 0;
}
