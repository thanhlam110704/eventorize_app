import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class DateTimeConverter {
  static Future<void> initialize() async {
    await initializeDateFormatting('vi_VN', null);
  }

  static String formatDateTime(
    DateTime? dateTime, {
    String pattern = 'E, dd \'thg\' M, HH:mm',
    String fallback = 'Ngày giờ không hợp lệ',
  }) {
    if (dateTime == null) {
      return fallback;
    }

    try {
      final formatter = DateFormat(pattern, 'vi_VN');
      return formatter.format(dateTime);
    } catch (e) {
      return fallback;
    }
  }

  static String formatDateRange(
    DateTime? startDate,
    DateTime? endDate, {
    String pattern = 'E, dd \'thg\' M, HH:mm',
    String separator = ' - ',
    String fallback = 'Khoảng ngày giờ không hợp lệ',
  }) {
    if (startDate == null || endDate == null) {
      return fallback;
    }

    try {
      final formatter = DateFormat(pattern, 'vi_VN');
      final formattedStart = formatter.format(startDate);
      if (startDate.year == endDate.year &&
          startDate.month == endDate.month &&
          startDate.day == endDate.day) {
        final timeFormatter = DateFormat('HH:mm', 'vi_VN');
        final formattedEndTime = timeFormatter.format(endDate);
        return '$formattedStart$separator$formattedEndTime';
      }
      final formattedEnd = formatter.format(endDate);
      return '$formattedStart$separator$formattedEnd';
    } catch (e) {
      return fallback;
    }
  }

  static String formatDateString(
    String? dateString, {
    String pattern = 'E, dd \'thg\' M, HH:mm',
    String fallback = 'Ngày giờ không hợp lệ',
  }) {
    if (dateString == null) {
      return fallback;
    }

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
    String pattern = 'E, dd \'thg\' M, HH:mm',
    String separator = ' - ',
    String fallback = 'Khoảng ngày giờ không hợp lệ',
  }) {
    if (startDateStr == null || endDateStr == null) {
      return fallback;
    }

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