bool isStudentDeadlinePassed(String? dateStr, String? timeStr) {
  if (dateStr == null || dateStr.isEmpty) return false;
  try {
    final date = DateTime.parse(dateStr);
    int hour = 23;
    int minute = 59;

    if (timeStr != null && timeStr.isNotEmpty) {
      final parts = timeStr.trim().split(' ');
      final timeParts = parts[0].split(':');
      hour = int.parse(timeParts[0]);
      minute = int.parse(timeParts[1]);
      if (parts.length > 1 && parts[1].toUpperCase() == 'PM' && hour < 12) {
        hour += 12;
      } else if (parts.length > 1 && parts[1].toUpperCase() == 'AM' && hour == 12) {
        hour = 0;
      }
    }

    final deadline = DateTime(date.year, date.month, date.day, hour, minute);
    final buffer = (timeStr != null && timeStr.contains(':'))
        ? const Duration(hours: 2)
        : Duration.zero;
    return DateTime.now().isAfter(deadline.add(buffer));
  } catch (_) {
    return false;
  }
}
