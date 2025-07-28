import 'package:utils/src/number_format.dart';

extension NumFormatter on num {
  String toFormatted({int decimalPlaces = 2}) => NumberFormatter.format(value: this, decimalPlaces: decimalPlaces);

  String toCompact() => NumberFormatter.formatCompact(toString());

  String toPercent({int decimalPlaces = 2}) => NumberFormatter.formatPercentage(abs(), decimalPlaces: decimalPlaces);

  String toNepaliUnit({int decimalPlaces = 2}) => NumberFormatter.formatToNepaliUnits(value: this, decimalPlaces: decimalPlaces);
}
