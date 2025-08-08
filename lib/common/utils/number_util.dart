import 'package:intl/intl.dart';

class NumberUtil {
  static String compact(num number, {String? locale}) {
    return NumberFormat.compact(locale: locale).format(number);
  }
}
