import 'package:intl/intl.dart';

class FormatUtils {
  // Chuyển số thành định dạng: 150.000đ
  static String formatMoney(dynamic amount) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    return formatter.format(amount);
  }
}