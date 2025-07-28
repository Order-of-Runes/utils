import 'package:intl/intl.dart';

class NumberFormatter {
  /// Format number with comma and fixed decimals
  static String format({required num value, int decimalPlaces = 2, bool useComma = true}) {
    final isInteger = value == value.roundToDouble();
    final digits = isInteger ? 0 : decimalPlaces;
    final pattern = useComma ? (isInteger
        ? '#,##0' : '#,##0.${'0' * decimalPlaces}')
        : (isInteger ? '0' : '#.${'0' * decimalPlaces}');

    final formatter = NumberFormat.currency(
      decimalDigits: digits,
      symbol: '',
      customPattern: pattern,
    );
    return formatter.format(value);
  }

  /// Compact format (e.g., 1.2K, 3.4M)
  static String formatCompact(String value) {
    return NumberFormat.compact().format(value);
  }

  /// Format as percentage
  static String formatPercentage(num value, {int decimalPlaces = 1}) {
    return '${value.toStringAsFixed(decimalPlaces)}%';
  }

  static String formatToNepaliUnits({required num value, int decimalPlaces = 2}) {
    const units = [
      {'label': 'Ar', 'value': 1000000000},
      {'label': 'Cr', 'value': 10000000},
      {'label': 'L', 'value': 100000},
    ];

    for (final unit in units) {
      final threshold = unit['value'] as num;
      if (value >= threshold) {
        return '${(value / threshold).toStringAsFixed(decimalPlaces)} ${unit['label']}';
      }
    }

    if (value is int || value == value.truncateToDouble()) {
      return value.toInt().toString();
    } else {
      return value.toString();
    }
  }

}
