import 'package:intl/intl.dart';

class DateFormatter {
  static String getVerboseDateTimeRepresentation(DateTime dateTime, bool twentyfour, {bool dateOnly = false}) {
    DateTime now = DateTime.now();
    DateTime justNow = now.subtract(Duration(minutes: 1));
    DateTime localDateTime = dateTime.toLocal();
    
    String timeFormat = twentyfour ? 'HH:mm' : 'hh:mm a';
    String formattedTime = DateFormat(timeFormat).format(localDateTime);

    if (localDateTime.isAfter(now)) {
      if (_isSameDay(localDateTime, now)) {
        return dateOnly ? "Today" : "Today, $formattedTime";
      }

      DateTime tomorrow = now.add(Duration(days: 1));
      if (_isSameDay(localDateTime, tomorrow)) {
        return dateOnly ? "Tomorrow" : "Tomorrow, $formattedTime";
      }

      if (localDateTime.difference(now).inDays < 6) {
        String weekday = DateFormat('EEEE').format(localDateTime);
        return dateOnly ? "On $weekday" : "On $weekday, $formattedTime";
      }

      if (localDateTime.year == now.year) {
        String d = DateFormat('Md').format(dateTime);
        return dateOnly ? d : "$d, $formattedTime";
      }

      String d = DateFormat('yMd').format(dateTime);
      return dateOnly ? d : "$d, $formattedTime";
    }

    if (!localDateTime.difference(justNow).isNegative) {
      return dateOnly ? DateFormat('Md').format(dateTime) : "Now";
    }

    if (_isSameDay(localDateTime, now)) {
      return dateOnly ? "Today" : "Today, $formattedTime";
    }

    DateTime yesterday = now.subtract(Duration(days: 1));
    if (_isSameDay(localDateTime, yesterday)) {
      return "Yesterday";
    }

    if (now.difference(localDateTime).inDays < 7) {
      String weekday = DateFormat('EEEE').format(localDateTime);
      return "Last $weekday";
    }

    if (now.difference(localDateTime).inDays < 360) {
      return DateFormat('Md').format(dateTime);
    }

    return DateFormat('yMd').format(dateTime);
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.day == b.day && a.month == b.month && a.year == b.year;
  }
}
