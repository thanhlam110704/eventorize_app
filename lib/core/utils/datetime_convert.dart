import 'package:intl/intl.dart';


class DateTimeConverter {
  static String formatDateTime(
    DateTime? dateTime, {
    String pattern = 'E, MMM d, HH:mm',
    String fallback = 'Invalid date',
  }) {
    if (dateTime == null) return fallback;

    try {
      final formatter = DateFormat(pattern);
      return formatter.format(dateTime);
    } catch (e) {
      return fallback;
    }
  }

  static String formatDateRange(
    DateTime? startDate,
    DateTime? endDate, {
    String pattern = 'E, MMM d, HH:mm',
    String separator = ' - ',
    String fallback = 'Invalid date range',
  }) {
    if (startDate == null || endDate == null) return fallback;

    try {
      final formatter = DateFormat(pattern);
      final formattedStart = formatter.format(startDate);
      final formattedEnd = formatter.format(endDate);
      return '$formattedStart$separator$formattedEnd';
    } catch (e) {
      return fallback;
    }
  }

  
  static String formatDateString(
    String? dateString, {
    String pattern = 'E, MMM d, HH:mm',
    String fallback = 'Invalid date',
  }) {
    if (dateString == null) return fallback;

    try {
      final dateTime = DateTime.parse(dateString);
      return formatDateTime(dateTime, pattern: pattern, fallback: fallback);
    } catch (e) {
      return fallback;
    }
  }

  static String formatDateRangeString(
    String? startDateStr,
    String? endDateStr, {
    String pattern = 'E, MMM d, HH:mm',
    String separator = ' - ',
    String fallback = 'Invalid date range',
  }) {
    if (startDateStr == null || endDateStr == null) return fallback;

    try {
      final startDate = DateTime.parse(startDateStr);
      final endDate = DateTime.parse(endDateStr);
      return formatDateRange(
        startDate,
        endDate,
        pattern: pattern,
        separator: separator,
        fallback: fallback,
      );
    } catch (e) {
      return fallback;
    }
  }
}